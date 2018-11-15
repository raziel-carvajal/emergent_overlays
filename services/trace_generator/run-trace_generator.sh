#!/bin/bash -
#===============================================================================
#
#          FILE: run-trace_generator.sh
#
#         USAGE: ./run-trace_generator.sh
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

set -o nounset                              # Treat unset variables as an error
workdir=`pwd`
if [[ "${USE_PREVIOUS_TRACE}" != "yes" ]]; then
	echo "Creating a mobility trace..."
	cd src/scripts/topologies
	./make-topology.sh
else
	echo "Using previous trace..."
fi
cd ${workdir}/ini-f-d
INI_FILES_LIST="cfgs_for_workers" \
  INI_FILES_DIR="../experiments/configs/built_configs" \
  npm start
