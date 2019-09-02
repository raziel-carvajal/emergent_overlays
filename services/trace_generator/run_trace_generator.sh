#!/bin/bash -
#===============================================================================
#
#          FILE: run_trace_generator.sh
#
#         USAGE: ./run_trace_generator.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 11/15/2018 15:17
#      REVISION:  ---
#===============================================================================
workdir=`pwd`
if [[ "${USE_PREVIOUS_TRACE}" != "yes" ]]; then
	cd src/scripts/topologies
	# delete outputs from previous executions
	rm -f *.pdf *.gif *.bm *.ned \
		network_metadata.json bipartite-scenario-1st-position source_nodes.xml
	echo "Creating a new mobility trace for:"
	case "${SCENARIO_ID}" in
		"with1Poi" )
			echo -e "\t scenario with one PoI"
			let walks=${SIMULATION_TIME}/4
		  ./get_one_poi_trace.py --cma-length ${COMM_AREA_LENGTH} \
			  --cma-width ${COMM_AREA_WIDTH} --nodes ${NODES}  \
			  --transmission-range ${NODES_TRANSMISSION_RANGE} --walks ${walks}
			;;
		"with2Poi" )
			echo -e "\t scenario with 2 PoI"
			# TODO
			;;
		"bipartite" )
			echo -e "\t bipartite scenario"
			./get-bipartite-trace.py --cma-length ${COMM_AREA_LENGTH} \
			  --cma-width ${COMM_AREA_WIDTH} --nodes ${NODES} \
				--trace-size ${SIMULATION_TIME} \
				--transmission-range ${NODES_TRANSMISSION_RANGE}
			;;
		* )
			echo -e "\t default scenario with one PoI"
			# TODO this is a deprecated method to create traces with one PoI and a
			# call to this scripts may require minor changes
			# ./make-topology.sh
			;;
	esac
	./create_omnet_cfg_files
else
	echo "Using previous trace..."
fi
cd ${workdir}/ini-f-d
INI_FILES_LIST="cfgs_for_workers" \
  INI_FILES_DIR="../experiments/configs/built_configs" \
  npm start
