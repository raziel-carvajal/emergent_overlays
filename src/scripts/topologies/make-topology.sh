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

let nodes=${NODES_AT_DENSE_AREA}+${NODES_AT_SPARSE_AREA}
tx=${NODES_TRANSMISSION_RANGE}
overlays=$(bc <<< "scale=2; (${SIMULATION_TIME} * 60) / ${NODES_MOV_FREQ}")
overlays=$(bc <<< "${overlays}/1")

echo "Comm area length: ${COMM_AREA_LENGTH} x ${COMM_AREA_WIDTH}"
echo "Nodes No: ${nodes}"
echo "Tx of nodes: ${tx}"
echo "No of overlays: ${overlays}"

# remove all configurations and topologies
rm -rf *.pdf *.ned *.mobility *.positions output mobility-trace \
  ../../../experiments/networks/built_topologies/* \
  ../../../experiments/configs/built_configs/*.ini \
  ../../../experiments/configs/built_configs/cfgs_for_workers

./gen_mobility_trace.py --cma-length ${COMM_AREA_LENGTH} \
	--cma-width ${COMM_AREA_WIDTH} --dense-area-length ${DENSE_AREA_LENGTH} \
	--dense-area-width ${DENSE_AREA_WIDTH} --nodes-at-dense ${NODES_AT_DENSE_AREA} \
  --nodes-at-sparse ${NODES_AT_SPARSE_AREA} --transmission-range ${tx} \
	--trace-size ${overlays} --motion-freq ${NODES_MOV_FREQ} >output

s=""
for f in `ls -t *.pdf`; do
  s="${f} ${s}"
done
pdfunite ${s} all.pdf
rm -f Position_*.pdf

nodesNoAtTrace=`wc -l mobility-trace | awk '{print $1}'`
let nodesNoAtTrace=nodesNoAtTrace-1
./make-ned-file.py --cma-len ${COMM_AREA_LENGTH} --cma-width ${COMM_AREA_WIDTH} \
	--transmission-range ${tx} --nodes ${nodesNoAtTrace}

mobF=`ls *.ned | awk -F ".ned" '{ print $1}'`
mv mobility-trace "${mobF}.mobility"
mv distribution-per-density "${mobF}.positions"
mv all.pdf "${mobF}.pdf"
mv *.pdf *.ned *.mobility *.positions \
  ../../../experiments/networks/built_topologies

firsAtDenseA=`grep FIRST_NODE_AT_DENSE_AREA output | awk '{print $2}' | tail -1`
srcNodeId=`grep SOURCE_NODE_ID output | awk '{print $2}' | tail -1`
cenPosX=`grep CMA_CENTER output | awk '{print $2}' | tail -1`
cenPosY=`grep CMA_CENTER output | awk '{print $3}' | tail -1`

echo "FIRST_NODE_AT_DENSE_AREA = ${firsAtDenseA}"
echo "          SOURCE_NODE_ID = ${srcNodeId}"
echo "              CMA_CENTER = ${cenPosX} x ${cenPosY}"
echo "  DENSE_REGION_DIMENSION = ${DENSE_AREA_LENGTH} x ${DENSE_AREA_WIDTH}"
rm -f output

broaMsgInterval=`bc <<< "scale=2; (${SIMULATION_TIME} * 60 ) / ${BROADCAST_MSGS_NO}"`
# broaMsgInterval=`bc <<< "scale=2; x=(${SIMULATION_TIME} * 60 )/${BROADCAST_MSGS_NO}; if(x < 1.0) print "0",x else print x ;"`
echo "Broadcast message interval ${broaMsgInterval}"

# NOTE 1s more were added to allow experiment end without problems
SIMULATION_TIME=`bc<<<"scale=2; ${SIMULATION_TIME} * 60 + 1"`

# configuration of mobility model when ${WITH_MOBILITY} = TRUE
mobModel="# mobility model\n"
if [[ "${WITH_MOBILITY}" == "true" ]]; then
	mobModel=${mobModel}"*.host*.mobilityType = \"BonnMotionMobility\"\n"
	traceFilePath="../../experiments/networks/built_topologies/"
	mobModel=${mobModel}"*.host*.mobility.traceFile = \"${traceFilePath}${mobF}.mobility\"\n"
	for (( i = 1; i <= ${nodesNoAtTrace}; i++ )); do
		mobModel=${mobModel}"*.host${i}.mobility.nodeId = ${i}\n"
	done
	mobModel=${mobModel}"**.udpApp[0].motionInterval=${NODES_MOV_FREQ}s\n"
fi
mobModel=${mobModel}"# concat all parameters of each algorithm\n"

cfgsForWorkers=""
# default configuration of INI file
cfgFile='../../../experiments/configs/in_common/common.ini'
algorithms=`echo -e "${ALGO_AT_DENSE_AREA}\n${ALGO_AT_SPARSE_AREA}\nhybrid"`
algoClassMap="../../../experiments/configs/in_common/algo_class_mapping"
let n=${nodes}+1
for algo in ${algorithms} ; do
  # add configuration of exepriment
	cat "${cfgFile}" > iniFile
	echo -e ${mobModel} >> iniFile

  sed -i -e "s/CONFIGURATION_NAME/${mobF}${algo}/" iniFile
	sed -i -e "s/TOPOLOGY_NAME/${mobF}/" iniFile
  sed -i -e "s/SIMULATION_TIME/${SIMULATION_TIME}s/" iniFile
  sed -i -e "s/NODES_TRANSMISSION_RANGE/${NODES_TRANSMISSION_RANGE}m/" iniFile
  sed -i -e "s/SOURCE_NODE_ID/host${srcNodeId}/" iniFile
  sed -i -e "s/CENTER_POS_X/${cenPosX}/" iniFile
  sed -i -e "s/CENTER_POS_Y/${cenPosY}/" iniFile
  sed -i -e "s/DENSE_REGION_WIDTH/${DENSE_AREA_WIDTH}/" iniFile
	sed -i -e "s/DENSE_REGION_LENGTH/${DENSE_AREA_LENGTH}/" iniFile
  sed -i -e "s/BROADCAST_MSG_INTERVAL/${broaMsgInterval}s/" iniFile
  sed -i -e "s/ADAPTATION_POLICY/${ADAPTATION_POLICY}/" iniFile

  algoCfgFpath="../../../experiments/configs/in_common/protocols"
  # concat attributes per algorithm
  if [[ -f ${algoCfgFpath}/${algo}.cfg ]]; then
    for opt in `cat ${algoCfgFpath}/${algo}.cfg` ; do
      echo "**.udpApp[0].${opt}" >> iniFile
    done
  fi
	# toatl number of nodes in the network
	echo "**.udpApp[0].nodesNo = ${n}" >> iniFile
  # set the algorithm that nodes use to bootstrap
  if [ "${algo}" == "hybrid" ] ; then
    # set algorithm for nodes at sparse area
    i=1; let j=${firsAtDenseA}-1
    algoClassName=`grep ${ALGO_AT_SPARSE_AREA} ${algoClassMap} | awk -F "=" '{print $2}'`
    echo "*.host{${i}..${j}}.udpApp[0].runningProtocolId = ${algoClassName}" >> iniFile
    # set algorithm for nodes at dense area
    i=${firsAtDenseA}; let j=${firsAtDenseA}+${NODES_AT_DENSE_AREA}
    algoClassName=`grep ${ALGO_AT_DENSE_AREA} ${algoClassMap} | awk -F "=" '{print $2}'`
    echo "*.host{${i}..${j}}.udpApp[0].runningProtocolId = ${algoClassName}" >> iniFile
  else
    algoClassName=`grep ${algo} ${algoClassMap} | awk -F "=" '{print $2}'`
    echo -e "**.udpApp[0].runningProtocolId = ${algoClassName}" >> iniFile
  fi
  mv iniFile "${mobF}${algo}.ini"
  mv "${mobF}${algo}.ini" ../../../experiments/configs/built_configs

  # update list of jobs for workers (Docker container that executes one algorithm)
  cfgsForWorkers="${cfgsForWorkers}${mobF}${algo}.ini\n"
done

echo -e "Jobs for workers:\n ${cfgsForWorkers}"
echo -e "${cfgsForWorkers}" > "../../../experiments/configs/built_configs/cfgs_for_workers"
