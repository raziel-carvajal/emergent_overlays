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
regions=${DENSITY_REGIONS_NO}
nodes=${NODES_NO_PER_REGION}
tx=${NODES_TRANSMISSION_RANGE}
overlays=$(bc <<< "(${SIMULATION_TIME} * 60) / ${NODES_MOV_FREQ}")
generator="./make-mobility-trace-same-den.py"
#generator="./make-mobility-trace.py"
# remove all configurations and topologies
rm -f *.pdf *.ned *.mobility *.positions output \
  ../../../experiments/networks/built_topologies/n_* \
  ../../../experiments/configs/built_configs/n_* \
  ../../../experiments/configs/built_configs/cfgs_for_workers
${generator} --cma-w ${cma} --regions ${regions} \
  --nodes-no ${nodes} --transmission-range ${tx} --overlays-no ${overlays} \
  &> output
s=""
for f in `ls -t *.pdf`; do
  s="${f} ${s}"
done
pdfunite ${s} all.pdf
rm -f Position_*.pdf
./make-ned-file.py --cma-w ${cma} --transmission-range ${tx}

mobF=`file *.ned | awk -F ".ned" '{ print $1}'`
mv mobility-trace "${mobF}.mobility"
mv distribution-per-density "${mobF}.positions"
mv all.pdf "${mobF}.pdf"
mv *.pdf *.ned *.mobility *.positions \
  ../../../experiments/networks/built_topologies

firsAtDenseA=`grep FIRST_NODE_AT_DENSE_AREA output | awk -F '=' '{print $2}' | tail -1`
lastAtSparsA=`grep LAST_NODE_AT_SPARSE_AREA output | awk -F '=' '{print $2}' | tail -1`
srcNodeId=`grep SOURCE_NODE_ID output | awk -F '=' '{print $2}' | tail -1`
rm -f output
echo "1st[${firsAtDenseA}] last[${lastAtSparsA}] src[${srcNodeId}]"

rm -f "../../../experiments/configs/in_common/config.xml"
cat "../../../experiments/configs/in_common/base_config" >config.xml
algoClassMap='../../../experiments/configs/in_common/algo_class_mapping'
algoClassName=`grep ${ALGO_AT_DENSE_AREA}  ${algoClassMap} | awk -F "=" '{print $2}'`
sed -i -e "s/ALGO_AT_DENSE_AREA/${algoClassName}/" config.xml
algoClassName=`grep ${ALGO_AT_SPARSE_AREA} ${algoClassMap} | awk -F "=" '{print $2}'`
sed -i -e "s/ALGO_AT_SPARSE_AREA/${algoClassName}/" config.xml
ctrlMsgFreq=`bc <<< "(${SIMULATION_TIME} * 60) / ${CONTROL_MSGS_NO}"`
sed -i -e "s/CTRL_MSG_FREQ/${ctrlMsgFreq}/" config.xml
mv config.xml "../../../experiments/configs/in_common"

cenPosXandY=`bc <<< "${cma} / 2"`
denseAreaWi=`bc <<< "${cma} / (${regions} + 1)"`
broaMsgFreq=`bc <<< "( (${SIMULATION_TIME} * 60) / ${BROADCAST_MSGS_NO} ) * 1.0"`
# TODO this warm up phase must be independent of the control messages frequency
warmUpPhase=`bc <<< "${ctrlMsgFreq} * 2.0"`
newSimTime=`bc<<<"${ctrlMsgFreq} * 2 + ${SIMULATION_TIME} * 60 + ${ctrlMsgFreq}"`
# TODO
WITH_MOBILITY=true
algorithms=`echo -e "${ALGO_AT_DENSE_AREA}\n${ALGO_AT_SPARSE_AREA}\nhybrid"`
cfgFile='../../../experiments/configs/in_common/common.ini'
cfgsForWorkers=""
for algo in ${algorithms} ; do
  cat "${cfgFile}" > iniFile
  sed -i -e "s/CONFIGURATION_NAME/${mobF}${algo}/" iniFile
  sed -i -e "s/TOPOLOGY_NAME/${mobF}/" iniFile
  sed -i -e "s/SIMULATION_TIME/${newSimTime}s/" iniFile
  sed -i -e "s/NODES_TRANSMISSION_RANGE/${NODES_TRANSMISSION_RANGE}m/" iniFile
  sed -i -e "s/SOURCE_NODE_ID/hostR${srcNodeId}/" iniFile
  sed -i -e "s/CENTER_POS_X/${cenPosXandY}/" iniFile
  sed -i -e "s/CENTER_POS_Y/${cenPosXandY}/" iniFile
  sed -i -e "s/DENSE_REGION_WIDTH/${denseAreaWi}/" iniFile
  sed -i -e "s/BROADCAST_MSGS_NO/${BROADCAST_MSGS_NO}/" iniFile
  sed -i -e "s/BROADCAST_MSG_INTERVAL/${broaMsgFreq}s/" iniFile
  sed -i -e "s/WITH_ADAPTATION/${WITH_ADAPTATION}/" iniFile
  sed -i -e "s/ADAPTATION_POLICY/${ADAPTATION_POLICY}/" iniFile
  sed -i -e "s/WITH_MOBILITY/${WITH_MOBILITY}/" iniFile
  sed -i -e "s/WARMUP_PHASE/${warmUpPhase}s/" iniFile
  if [ "${algo}" == "hybrid" ] ; then
    algoClassName=`grep ${ALGO_AT_SPARSE_AREA} ${algoClassMap} | awk -F "=" '{print $2}'`
	  for (( I=1; I<${firsAtDenseA}; I+=1 )); do
      echo "*.hostR${I}.udpApp[0].initialProtocol = \"${algoClassName}\"" >> iniFile
	  done
    algoClassName=`grep ${ALGO_AT_DENSE_AREA} ${algoClassMap} | awk -F "=" '{print $2}'`
    for (( I=${firsAtDenseA}; I<${firsAtDenseA}+${nodes}; I+=1 )); do
      echo "*.hostR${I}.udpApp[0].initialProtocol = \"${algoClassName}\"" >> iniFile
	  done
    algoClassName=`grep ${ALGO_AT_SPARSE_AREA} ${algoClassMap} | awk -F "=" '{print $2}'`
    for (( I=${firsAtDenseA}+${nodes}; I<=${lastAtSparsA}; I+=1 )); do
      echo "*.hostR${I}.udpApp[0].initialProtocol = \"${algoClassName}\"" >> iniFile
	  done
    # NOTE for the moment there is a source node positioned within the dense area
    algoClassName=`grep ${ALGO_AT_DENSE_AREA} ${algoClassMap} | awk -F "=" '{print $2}'`
    echo "*.hostR${srcNodeId}.udpApp[0].initialProtocol = \"${algoClassName}\"" >> iniFile
    cfgsForWorkers="${cfgsForWorkers}${mobF}${algo}.ini"
  else
    algoClassName=`grep ${algo} ${algoClassMap} | awk -F "=" '{print $2}'`
    echo -e "*.host*.udpApp[0].initialProtocol = \"${algoClassName}\"" >> iniFile
    cfgsForWorkers="${cfgsForWorkers}${mobF}${algo}.ini\n"
  fi
  mv iniFile "${mobF}${algo}.ini"
  mv "${mobF}${algo}.ini" ../../../experiments/configs/built_configs
done
builtCfgDir="../../../experiments/configs/built_configs"
echo -e "FOR WORKERS:\n ${cfgsForWorkers}"
echo -e "${cfgsForWorkers}" > "${builtCfgDir}/cfgs_for_workers"
