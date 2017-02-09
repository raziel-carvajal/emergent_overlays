#!/bin/bash

USE_SINGLE_SOURCE=0

# configuring path to omnet++
. download-omnet.sh
source local-omnet-setenv.sh ${OMNET_PATH}

COMMANDS=( tar git make gcc g++ opp_run opp_makemake R Rscript python sem bison )

for C in "${COMMANDS[@]}"; do
   printf "sanity-check: Checking if $C is installed: "
   type ${C} >/dev/null 2>&1 || { echo >&2 "I require ${C}, but it's not installed.  Aborting."; exit 1; }
   printf "Ok\n"
done

#Checking Networkx: python lib for building topologies
echo "Checking if Networkx is installed (python library to cope with graphs)"
echo "import networkx" | python
if [ $? -ne 0 ]; then
  echo "Installing Python.Networkx"
  tar -xzf ../../tools/networkx-1.11.tar.gz -C ../../tools
  pushd ../../tools/networkx-1.11/ && python setup.py install && popd
fi
printf "Ok\n"

# installing omnetpp package for R if needed
install_r_dependencies=`Rscript checking-depencencies.R | awk '{ print $2 }'`
if [ "$install_r_dependencies" == "fail" ]; then
	echo "Installing package to read omnet files in R"
	Rscript installing-dependencies.R
fi

# saving omnet path because it is fine
echo "${OMNET_PATH}" > omnet.config

# Getting transmission range to build topologies
if [ ! -f "../../experiments/configs/common.ini" ]; then
   echo "Error: common configuration file for experiments does not exist"
   exit 1
fi

tPath='../../experiments/networks/builtTopologies/'
iniCommon='../../experiments/configs/common.ini'

Tx=`grep 'maxCommunicationRange' $iniCommon | grep -Eo '[0-9]{1,5}'`
echo "Building topologies with transmission range: $Tx"

# Tx is the radius of communication (not the diameter)

rm -fr $tPath'*.ned'

[ ! -d "$tPath" ] && mkdir "${tPath}"

ls $tPath/*.ned 2>/dev/null
isEmpty=$?
if [ $isEmpty -ne 0 ]; then
    # Check if the experimental area (based in range [$2, $3] args in doTopologies) must be given
    # as an input
    #python topologies/buildTopology.py --tx $Tx --min_d 5 --max_d 40 --idx 0 --mobility --distributed
    python topologies/buildTopology.py --tx $Tx --min_d 5 --max_d 35 --nodes 500 --non-uniform
    state=$?
    if [ $state -ne 0 ]; then
        echo >&2 "Error: the construction of topologies failed. Aborting."; exit 1;
    fi
    mv *.ned $tPath
    mv *.density $tPath
    mv *.mobility $tPath
    printf "Ok\n"
else
    printf "Topologies were already created, no need to create new ones.\n"
fi

printf "Building configurations (ini files) per algorithm and per topology\n"
# experiments/configs/builtConfigs
pPath='../protocols/'
cPath='../../experiments/configs/builtConfigs/'


[ ! -d "$cPath" ] &&	mkdir "${cPath}"


nr_msg=`grep 'nr_broadcast_msg' $iniCommon | awk -F '=' '{ print $2 }' | grep -Eo '[0-9]{1,7}'`
echo "The number of broadcasts is ${nr_msg}"


here=`pwd`
cd $pPath
protocols=`ls -d */`
cd $here
cd $tPath
topologiesFiles=`ls *.ned`
cd ${here}
#INFO: this is required to plot the proportion of collisions on each experiment
#WATCH_OUT: be sure that frequency of control messages is the same as in common.ini
ctrMsgsForColl=`grep "nr_hello_messages" ${pPath}mprt2/ini`
ctrMsgsForColl="${ctrMsgsForColl}\n"`grep "helloTime" ${pPath}mprt2/ini`
for t in $topologiesFiles; do
  srcId=`grep isCenter $tPath$t | grep -Eo '[0-9]{1,5}' | head -1`

  index=$(( ${#t} - 4 ))
  tName=${t:0:$index}
  mobFile="${t:0:$((index-3))}.mobility"
  for p in $protocols; do
  	pp="${pPath}$p"
  	if [ -d $pp ]; then
    	s=$(( ${#p} - 1))
    	p=${p:0:$s}
  		tId=$tName$p
  		cat $iniCommon >$tId
  		echo -e "[Config $tId]\nnetwork = builtTopologies.$tName" >>$tId
  		#cat $pPath$p'/ini' >> $tId
      FLAGS_CONFIG=""
      if [ $p == "fully_adaptive" ]; then
        FLAGS_CONFIG="--density-aware"
      fi
      python generateConfig.py $tName $tPath $pPath$p'/ini' $FLAGS_CONFIG >> $tId
      echo "*.host*.mobility.filename = \"${tPath}/$mobFile\"" >> $tId
      if [ "$USE_SINGLE_SOURCE" -eq "1" ]; then
        sed -i -e s/"SOURCE"/"hostR$srcId"/ $tId
        echo "*.host*.udpApp[0].single_source = true" >> $tId
      fi
      case ${p} in
        flooding)
          cat ${tId} >>"${tId}_forCol.ini"
          echo -e "${ctrMsgsForColl}" >>"${tId}_forCol.ini"
          mv "${tId}_forCol.ini" ${cPath}
          ;;
        abba2)
          cat ${tId} >>"${tId}_forCol.ini"
          echo -e "${ctrMsgsForColl}" >>"${tId}_forCol.ini"
          mv "${tId}_forCol.ini" ${cPath}
          ;;
      esac
  		mv $tId $tId'.ini'
  		mv $tId'.ini' $cPath
  	fi
  done
done
# TODO figure out why there is a file *-e
rm -fr n-*
printf "Ok\n"
