#!/bin/bash

COMMANDS=( tar git make gcc g++ opp_run opp_makemake R Rscript python sem bison )

for C in "${COMMANDS[@]}"; do
   printf "Checking if $C is installed: "
   type ${C} >/dev/null 2>&1 || { echo >&2 "I require ${C}, but it's not installed.  Aborting."; exit 1; }
   printf "Ok\n"
done

#Checking Networkx: python lib for building topologies
printf "Checking if Networkx is installed (python library to cope with graphs)\n"
echo "import networkx" | python
state=$?
if [ $state -ne 0 ]; then
    echo >&2 "Python.Networkx must be installed build network topologies. Aborting.";
    tar -xzvf ../../tools/networkx-1.11.tar.gz -C ../../tools
    cd ../../tools/networkx-1.11/ && sudo python setup.py install
    exit 1
fi
printf "Ok\n"

# Getting transmission range to build topologies
if [ ! -f "../../experiments/configs/common.ini" ]; then
   echo "Error: common configuration file for experiments does not exist"
   exit 1
fi

tPath='../../experiments/networks/builtTopologies/'
iniCommon='../../experiments/configs/common.ini'

Tx=`grep 'maxCommunicationRange' $iniCommon | grep -Eo '[0-9]{1,5}'`
printf "Building topologies with transmission range: $Tx\n"

# Tx is the radius of communication (not the diameter)

#rm -fr $tPath'*.ned'

if [ ! -d "$tPath" ]; then
	mkdir "${tPath}"
fi


ls $tPath/*.ned 2>/dev/null
isEmpty=$?
if [ $isEmpty -ne 0 ]; then
    # Check if the experimental area (based in range [$2, $3] args in doTopologies) must be given
    # as an input
    ./doTopologies.sh $Tx 5 5 $tPath
    state=$?
    if [ $state -ne 0 ]; then
        echo >&2 "Error: the construction of topologies failed. Aborting."; exit 1;
    fi
    printf "Ok\n"
else
    printf "Topologies were already created, no need to create new ones.\n"
fi

printf "Building configurations (ini files) per algorithm and per topology\n"
# experiments/configs/builtConfigs
pPath='../protocols/'
cPath='../../experiments/configs/builtConfigs/'


if [ ! -d "$cPath" ]; then
	mkdir "${cPath}"
fi


here=`pwd`
cd $pPath
protocols=`ls -d */`
cd $here
cd $tPath
topologiesFiles=`ls *.ned`
cd ${here}
for t in $topologiesFiles; do
    srcId=`grep isCenter $tPath$t | grep -Eo '[0-9]{1,5}' | head -1`
    index=$(( ${#t} - 4 ))
    tName=${t:0:$index}
    for p in $protocols; do
	pp="${pPath}$p"
	if [ -d $pp ]; then
        	s=$(( ${#p} - 1))
        	p=${p:0:$s}
		tId=$tName$p
		cat $iniCommon >$tId
		echo -e "[Config $tId]\nnetwork = builtTopologies.$tName" >>$tId
		cat $pPath$p'/ini' >>$tId
		sed -i -e s/"SOURCE"/"hostR$srcId"/ $tId
		mv $tId $tId'.ini'
		mv $tId'.ini' $cPath
	fi
    done
done
# TODO figure out why there is a file *-e
rm -fr n-*
printf "Ok\n"

# installing omnetpp package for R if needed
install_r_dependencies=`Rscript checking-depencencies.R | awk '{ print $2 }'`
if [ "$install_r_dependencies" == "fail" ]; then
	sudo Rscript installing-dependencies.R
fi
