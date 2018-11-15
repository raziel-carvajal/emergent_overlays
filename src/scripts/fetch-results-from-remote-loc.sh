#!/bin/bash -
#===============================================================================
#
#          FILE: fetch-results-from-remote-loc.sh
#
#         USAGE: ./fetch-results-from-remote-loc.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 11/15/2018 13:01
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ ${#} != 2 ] ; then
  echo -e "Usage: ${0} <remote_server> <destination>\nEND of ${0}"
	exit 1
fi
if [ ! -d ${2} ] ; then
  echo -e "Error: ${2} isn't a vaild directory.\nEND of ${0}"
	exit 1
fi
remoteLoc=${1}
destDir=${2}
ssh ${remoteLoc} "[ -d emergent_overlays ]"
if [ ${?} != 0 ] ; then
  echo "Remote location (${remoteLoc}) do not contain framework: emergent_overlays"
	echo -e "Any dataset will be fetch.\nEND of ${0}"
	exit 1
fi
ssh ${remoteLoc} "tar czf emergent_overlays/results.tgz emergent_overlays/results/"
ssh ${remoteLoc} "tar czf emergent_overlays/experiments/networks/built_topologies.tgz \
	emergent_overlays/experiments/networks/built_topologies"
scp ${remoteLoc}:~/emergent_overlays/results.tgz ${destDir}
scp ${remoteLoc}:~/emergent_overlays/experiments/networks/built_topologies.tgz ${destDir}
echo -e "Find dataset in ${destDir}\nEND of ${0}"
