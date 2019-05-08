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

if [ ${#} != 3 ] ; then
  echo -e "Usage: ${0} <remote_server> <remote_location> <local_destination>\nEND of ${0}"
	exit 1
fi
if [ ! -d ${3} ] ; then
  echo -e "Error: ${3} isn't a vaild directory.\nEND of ${0}"
	exit 1
fi
server=${1}
remoteDir=${2}
destDir=${3}
ssh ${server} "[ -d ${remoteDir}/src/emergent_overlays ]"
if [ ${?} != 0 ] ; then
  echo "Remote location (${remoteDir}) do not contain framework: emergent_overlays"
	echo -e "Any dataset will be fetched.\nEND of ${0}"
	exit 1
fi
ssh ${server} "tar czf ${remoteDir}/results.tgz ${remoteDir}/results/"
ssh ${server} "tar czf ${remoteDir}/experiments/networks/built_topologies.tgz \
	${remoteDir}/experiments/networks/built_topologies"
scp ${server}:${remoteDir}/results.tgz ${destDir}
scp ${server}:${remoteDir}/experiments/networks/built_topologies.tgz ${destDir}
echo -e "Find dataset in ${destDir}\nEND of ${0}"
