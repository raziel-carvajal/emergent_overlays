#!/bin/bash -
#===============================================================================
#
#          FILE: make-topology.sh
#
#         USAGE: ./make-topology.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 11/29/2017 18:25
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
cma=${COMM_AREA_LENGTH}
nodes=${NODES_NO_PER_REGION}
tx=${NODES_TRANSMISSION_RANGE}
overlays=$(bc <<< "scale=2; (${SIMULATION_TIME} * 60) / ${NODES_MOV_FREQ}")
overlays=$(bc <<< "${overlays}/1")

echo "Comm area length: ${cma}"
echo "Nodes No: ${nodes}"
echo "Tx of nodes: ${tx}"
echo "No of overlays: ${overlays}"

# remove all configurations and topologies
rm -rf *.pdf *.ned *.mobility *.positions output \
  ../../../experiments/networks/built_topologies/* \
  ../../../experiments/configs/built_configs/*

./gen_mobility_trace.py --area-length ${cma}  --nodes-no ${nodes} \
  --transmission-range ${tx} --trace-size ${overlays} >output

s=""
for f in `ls -t *.pdf`; do
  s="${f} ${s}"
done
pdfunite ${s} all.pdf
rm -f Position_*.pdf

./make-ned-file.py --cma-w ${cma} --transmission-range ${tx}

mobF=`ls *.ned | awk -F ".ned" '{ print $1}'`
mv mobility-trace "${mobF}.mobility"
mv distribution-per-density "${mobF}.positions"
mv all.pdf "${mobF}.pdf"
mv *.pdf *.ned *.mobility *.positions \
  ../../../experiments/networks/built_topologies

firsAtDenseA=`grep FIRST_NODE_AT_DENSE_AREA output | awk '{print $2}' | tail -1`
srcNodeId=`grep SOURCE_NODE_ID output | awk '{print $2}' | tail -1`
cenPosXandY=`grep X_POSITION_OF_CMA_CENTER output | awk '{print $2}' | tail -1`
denseAreaWi=`grep WIDTH_OF_DENSE_REGION output | awk '{print $2}' | tail -1`
echo "FIRST_NODE_AT_DENSE_AREA = ${firsAtDenseA}"
echo "          SOURCE_NODE_ID = ${srcNodeId}"
echo "X_POSITION_OF_CMA_CENTER = ${cenPosXandY}"
echo "   WIDTH_OF_DENSE_REGION = ${denseAreaWi}"
rm -f output

# rm -f "../../../experiments/configs/in_common/config.xml"
# cat "../../../experiments/configs/in_common/base_config" >config.xml
# algoClassName=`grep ${ALGO_AT_DENSE_AREA}  ${algoClassMap} | awk -F "=" '{print $2}'`
# sed -i -e "s/ALGO_AT_DENSE_AREA/${algoClassName}/" config.xml
# sed -i -e "s/ALGO_AT_SPARSE_AREA/${algoClassName}/" config.xml
# sed -i -e "s/CTRL_MSG_FREQ/${ctrlMsgInterval}/" config.xml
# mv config.xml "../../../experiments/configs/in_common"

ctrlMsgInterval=`bc <<< "scale=2; (${SIMULATION_TIME} * 60) / ${CONTROL_MSGS_NO}"`
echo "Ctrl message interval: ${ctrlMsgInterval}"
broaMsgInterval=`bc <<< "scale=2; (${SIMULATION_TIME} * 60 ) / ${BROADCAST_MSGS_NO}"`
# broaMsgInterval=`bc <<< "scale=2; x=(${SIMULATION_TIME} * 60 )/${BROADCAST_MSGS_NO}; if(x < 1.0) print "0",x else print x ;"`
echo "Broadcast message interval ${broaMsgInterval}"

# NOTE 2s more were added to allow experiment end without problems
SIMULATION_TIME=`bc<<<"scale=2; ${SIMULATION_TIME} * 60 + 2"`

cfgsForWorkers=""
cfgFile='../../../experiments/configs/in_common/common.ini'
algorithms=`echo -e "${ALGO_AT_DENSE_AREA}\n${ALGO_AT_SPARSE_AREA}\nhybrid"`
algoClassMap="../../../experiments/configs/in_common/algo_class_mapping"
for algo in ${algorithms} ; do
  cat "${cfgFile}" > iniFile
  #
  sed -i -e "s/CONFIGURATION_NAME/${mobF}${algo}/" iniFile
  sed -i -e "s/TOPOLOGY_NAME/${mobF}/" iniFile
  sed -i -e "s/SIMULATION_TIME/${SIMULATION_TIME}s/" iniFile
  sed -i -e "s/NODES_TRANSMISSION_RANGE/${NODES_TRANSMISSION_RANGE}m/" iniFile
  sed -i -e "s/SOURCE_NODE_ID/host${srcNodeId}/" iniFile
  sed -i -e "s/CENTER_POS_X/${cenPosXandY}/" iniFile
  sed -i -e "s/CENTER_POS_Y/${cenPosXandY}/" iniFile
  sed -i -e "s/DENSE_REGION_WIDTH/${denseAreaWi}/" iniFile

  ctrlMsgLowerInterval=`bc <<< "scale=2; ${ctrlMsgInterval} - 0.1"`
  sed -i -e "s/CTRL_MSG_INTERVAL/uniform(${ctrlMsgLowerInterval}s, ${ctrlMsgInterval}s)/" iniFile
  broaMsgLowerInterval=`bc <<< "scale=2; ${broaMsgInterval} - 0.1"`
  sed -i -e "s/BROADCAST_MSG_INTERVAL/uniform(${broaMsgLowerInterval}s, ${broaMsgInterval}s)/" iniFile

  sed -i -e "s/ADAPTATION_POLICY/${ADAPTATION_POLICY}/" iniFile
  sed -i -e "s/WITH_MOBILITY/${WITH_MOBILITY}/" iniFile
  sed -i -e "s/WITH_ADAPTATION/${WITH_ADAPTATION}/" iniFile

  algoCfgFpath="../../../experiments/configs/in_common/protocols"
  # concat attributes per algorithm
  if [[ -f ${algoCfgFpath}/${algo}.cfg ]]; then
    for opt in `cat ${algoCfgFpath}/${algo}.cfg` ; do
      echo "**.udpApp[0].${opt}" >> iniFile
    done
  fi

  # set the algorithm that nodes use to bootstrap
  if [ "${algo}" == "hybrid" ] ; then
    # set algorithm for nodes at sparse area
    i=1; let j=${firsAtDenseA}-1
    algoClassName=`grep ${ALGO_AT_SPARSE_AREA} ${algoClassMap} | awk -F "=" '{print $2}'`
    echo "*.host{${i}..${j}}.udpApp[0].typename=\"${algoClassName}\"" >> iniFile

    # set algorithm for nodes at dense area
    i=${firsAtDenseA}; let j=${firsAtDenseA}+${nodes}
    algoClassName=`grep ${ALGO_AT_DENSE_AREA} ${algoClassMap} | awk -F "=" '{print $2}'`
    echo "*.host{${i}..${j}}.udpApp[0].typename=\"${algoClassName}\"" >> iniFile
  else
    algoClassName=`grep ${algo} ${algoClassMap} | awk -F "=" '{print $2}'`
    echo -e "**.udpApp[0].typename=\"${algoClassName}\"" >> iniFile
  fi
  mv iniFile "${mobF}${algo}.ini"
  mv "${mobF}${algo}.ini" ../../../experiments/configs/built_configs

  # update list of jobs for workers (Docker container that executes one algorithm)
  cfgsForWorkers="${cfgsForWorkers}${mobF}${algo}.ini\n"
done

echo -e "Jobs for workers:\n ${cfgsForWorkers}"
echo -e "${cfgsForWorkers}" > "../../../experiments/configs/built_configs/cfgs_for_workers"
