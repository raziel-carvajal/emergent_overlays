#!/bin/bash -
#===============================================================================
#
#          FILE: create_omnet_cfg_files.sh
#
#         USAGE: ./create_omnet_cfg_files.sh
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
[ ${#} != 1 ] && echo -e "Usage: ${0} [Scenario_ID] \nEnd of ${0}." && exit 1

# # [BEING] NOTE Local test with one mobile PoI
# rm -f *.pdf *.gif *.bm *.ned *.json *.xml bipartite-scenario-1st-position
# echo -e "\t scenario with one PoI"
# let walks=${SIMULATION_TIME}/4
# ./get_one_poi_trace.py --cma-length ${COMM_AREA_LENGTH} \
# 	--cma-width ${COMM_AREA_WIDTH} --nodes ${NODES}  \
# 	--transmission-range ${NODES_TRANSMISSION_RANGE} --walks ${walks}
# # [END]

# # [BEING] NOTE Local test with one fixed mobile PoI
# rm -f *.pdf *.gif *.bm *.ned *.json *.xml bipartite-scenario-1st-position
# echo -e "\t scenario with one PoI"
# let nodesNoAtD=${NODES}/2
# let nodesNoAtS=${NODES}/2
# echo -e "\t scenario with one fixed PoI"
# ./gen_mobility_trace.py --nodes-at-dense ${nodesNoAtD} \
#   --cma-length ${COMM_AREA_LENGTH} --cma-width ${COMM_AREA_WIDTH}   \
#   --dense-area-length ${POI_AREA_LENGTH} --dense-area-width ${POI_AREA_WIDTH} \
#   --nodes-at-sparse ${nodesNoAtS} \
# 	--transmission-range ${NODES_TRANSMISSION_RANGE} \
# 	--trace-size ${SIMULATION_TIME}
# let NODES=NODES+1
# # [END]

./make_ned_file.py --cma-len ${COMM_AREA_LENGTH} --cma-width ${COMM_AREA_WIDTH} \
	--transmission-range ${NODES_TRANSMISSION_RANGE} --nodes ${NODES}
# rename files for this scenario and change containing directory
temp='' ; for l in `ls -t *.pdf` ; do temp="${l} ${temp}" ; done
pdfunite ${temp} all.pdf ; rm 'snapshot'*
expeId=`ls *.ned | awk -F ".ned" '{print $1}'`
mv all.pdf "${expeId}.pdf"
# these 3 files are outputs of the script that creates the mobility trace
mv "trace.bm" "${expeId}.bm" ; mv "network_metadata.json" "${expeId}.json"
mv "source_nodes.xml" "${expeId}.xml"
mv ${expeId}.* "../../../experiments/networks/built_topologies"

# now, create configuration file (INI) for experiment
cat '../../../experiments/configs/in_common/common.ini' > iniFile
###
sed -i -e "s/SIMULATION_TIME/${SIMULATION_TIME}s/" iniFile
sed -i -e "s/CONFIGURATION_NAME/${expeId}${1}/" iniFile
sed -i -e "s/TOPOLOGY_NAME/${expeId}/" iniFile
sed -i -e "s/NODES_TRANSMISSION_RANGE/${NODES_TRANSMISSION_RANGE}m/" iniFile
sed -i -e "s/BROADCAST_MSG_INTERVAL/${BROADCAST_MSGS_INTERVAL}s/" iniFile

### ignored parameter (it's set to have a valid INI file)
sed -i -e "s/ADAPTATION_POLICY/0/" iniFile
### number of nodes in the network
echo "**.udpApp[0].nodesNo = ${NODES}" >> iniFile
### set file with list of source nodes
temp="**.udpApp[0].sourceNodes = xmldoc"
temp="${temp}(\"../../experiments/networks/built_topologies/${expeId}.xml\")"
echo ${temp} >> iniFile
# assign the broadcast protocol running on each node
case "${1}" in
	"with1Poi" )
		echo "Nodes use pure-flooding as protocol to bootstrap"
		;;
	"with2Poi" )
    # TODO
		;;
	"bipartite" )
		algorithms="../../../experiments/configs/in_common/algo_class_mapping"
		algoId=`grep ${ALGO_AT_1ST_REGION} ${algorithms} | awk -F "=" '{print $2}'`
		let N=NODES/2
		echo "*.host{1..${N}}.udpApp[0].runningProtocolId = ${algoId}" >> iniFile
		algoId=`grep ${ALGO_AT_2ND_REGION} ${algorithms} | awk -F "=" '{print $2}'`
		let N=N+1
		echo "*.host{${N}..${NODES}}.udpApp[0].runningProtocolId = ${algoId}" >> iniFile
		;;
	* )
		echo "Nodes use pure-flooding as protocol to bootstrap"
		;;
esac
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
mv iniFile "${expeId}${1}.ini"
mv "${expeId}${1}.ini" ../../../experiments/configs/built_configs
### job for worker
echo "${expeId}${1}.ini" > "../../../experiments/configs/built_configs/cfgs_for_workers"
