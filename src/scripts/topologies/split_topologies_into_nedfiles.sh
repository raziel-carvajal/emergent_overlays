#!/bin/bash -
#===============================================================================
#
#          FILE: split_topologies_into_nedfiles.sh
#
#         USAGE: ./split_topologies_into_nedfiles.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 01/28/2020 18:10
#      REVISION:  ---
#===============================================================================
COMM_AREA_LENGTH=50
COMM_AREA_WIDTH=50
NODES=80
NODES_TRANSMISSION_RANGE=10
TOPOLOGIES_NO=10

./get_random_waypoint_trace.py --cma-length ${COMM_AREA_LENGTH} --cma-width \
	${COMM_AREA_WIDTH} --transmission-range ${NODES_TRANSMISSION_RANGE} --nodes \
	${NODES} --walks ${TOPOLOGIES_NO}

mv trace.bm trace.bm.bkup
nedFile="n_${NODES}_d_0_tr_${NODES_TRANSMISSION_RANGE}_a_${COMM_AREA_LENGTH}x${COMM_AREA_WIDTH}_idx_0_p_"

for (( i = 1; i <= ${TOPOLOGIES_NO}; i++ )); do
	awk -v i=$((${i}*3)) '{print $(i-2), $(i-1), $i}' trace.bm.bkup > trace.bm
	./make_ned_file.py --cma-len ${COMM_AREA_LENGTH} --cma-width ${COMM_AREA_WIDTH} \
	--transmission-range ${NODES_TRANSMISSION_RANGE} --nodes ${NODES}

	sed -ie "s/emergent_overlays.tunned_modules.Cellphone/inet.node.aodv.AODVRouter/" \
		"${nedFile}.ned"
	sed -ie "s/Cellphone/AODVRouter/" "${nedFile}.ned"
	newNedF="${nedFile}routing_top_${i}"
	sed -ie "s/${nedFile}/${newNedF}/" "${nedFile}.ned"

	mv "${nedFile}.ned" "${newNedF}.ned"
done

mv trace.bm.bkup trace.bm
