#!/bin/bash -
#===============================================================================
#
#          FILE: get-bipartite-scenario.sh
#
#         USAGE: ./get-bipartite-scenario.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 08/13/2019 14:08
#      REVISION:  ---
#===============================================================================
# first, create experimental scenario (network topology and mobility trace)
rm -f *.pdf *.gif *.bm bipartite-scenario-1st-position *.ned
### nodes perform one step every second
overlays=${SIMULATION_TIME}
### create mobility trace
./get-bipartite-trace.py --cma-length ${COMM_AREA_LENGTH} \
  --cma-width ${COMM_AREA_WIDTH} --nodes ${NODES} --trace-size ${overlays} \
  --transmission-range ${NODES_TRANSMISSION_RANGE}
### create topology for Omnet++
./make-ned-file.py --cma-len ${COMM_AREA_LENGTH} --cma-width ${COMM_AREA_WIDTH} \
	--transmission-range ${NODES_TRANSMISSION_RANGE} --nodes ${NODES} --scenario-id 2
### rename files for this scenario and change containing directory
temp='' ; for l in `ls -t *.pdf` ; do temp="${l} ${temp}" ; done
pdfunite ${temp} all.pdf ; rm 'snapshot'*
expeId=`ls *.ned | awk -F ".ned" '{print $1}'`
mv all.pdf "${expeId}.pdf"
temp=`ls *.bm` ; mv ${temp} "${expeId}.bm"
mv ${expeId}.* ../../../experiments/networks/built_topologies

# now, create configuration file (INI) for experiment
cat '../../../experiments/configs/in_common/common.ini' > iniFile
###
sed -i -e "s/SIMULATION_TIME/${SIMULATION_TIME}s/" iniFile
sed -i -e "s/CONFIGURATION_NAME/${expeId}bipartite/" iniFile
sed -i -e "s/TOPOLOGY_NAME/${expeId}/" iniFile
sed -i -e "s/NODES_TRANSMISSION_RANGE/${NODES_TRANSMISSION_RANGE}m/" iniFile
sed -i -e "s/BROADCAST_MSG_INTERVAL/${BROADCAST_MSGS_INTERVAL}s/" iniFile
### any node in the network may be a source node because every wireless topology
### remains connected (due to construction of mobility trace)
sed -i -e "s/SOURCE_NODE_ID/host1/" iniFile
### ignored parameter (it's set to have a valid INI file)
sed -i -e "s/ADAPTATION_POLICY/0/" iniFile
### number of nodes in the network
echo "**.udpApp[0].nodesNo = ${NODES}" >> iniFile
### assign the broadcast protocol running on each node
algorithms="../../../experiments/configs/in_common/algo_class_mapping"
algoId=`grep ${ALGO_AT_1ST_REGION} ${algorithms} | awk -F "=" '{print $2}'`
let N=NODES/2
echo "*.host{1..${N}}.udpApp[0].runningProtocolId = ${algoId}" >> iniFile
algoId=`grep ${ALGO_AT_2ND_REGION} ${algorithms} | awk -F "=" '{print $2}'`
let N=N+1
echo "*.host{${N}..${NODES}}.udpApp[0].runningProtocolId = ${algoId}" >> iniFile
### assign one mobility trace per node
mobModel="# tunning mobility model\n*.host*.mobilityType = \"BonnMotionMobility\"\n"
traceFilePath="../../experiments/networks/built_topologies/"
mobModel=${mobModel}"*.host*.mobility.traceFile = \"${traceFilePath}${expeId}.bm\"\n"
for (( i = 1; i <= ${NODES}; i++ )); do
	mobModel=${mobModel}"*.host${i}.mobility.nodeId = ${i}\n"
done
mobModel=${mobModel}"**.udpApp[0].motionInterval=1s\n"
echo -e ${mobModel} >> iniFile
### change containing directory of INI file
mv iniFile "${expeId}bipartite.ini"
mv "${expeId}bipartite.ini" ../../../experiments/configs/built_configs
### job for worker
echo "${expeId}bipartite.ini" > "../../../experiments/configs/built_configs/cfgs_for_workers"
