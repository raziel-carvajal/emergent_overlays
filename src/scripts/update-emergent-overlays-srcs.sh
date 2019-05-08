#!/bin/bash -
#===============================================================================
#
#          FILE: update-emergent-overlays-srcs.sh
#
#         USAGE: ./update-emergent-overlays-srcs.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 10/12/2018 11:15
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[ ${#} != 1 ] && \
  echo -e "Usage: ${0} <emergent_overlays-project-path>\nEnd of ${0}" && exit 1

[ ! -d ${1} ] && echo -e "Error. Dir ${1} do not exist.\nEnd of ${0}" && exit 1

if [ -f ${1}/src/package.ned ]; then
  grep "package emergent_overlays" ${1}/src/package.ned
  [ ${?} != 0 ] && \
    echo "Error. ${1} isn't a directory of emergent_overlays project." && \
    echo "End of ${0}" && exit 1
else
  echo "Error. ${1} isn't a directory of emergent_overlays project."
  echo "End of ${0}" && exit 1
fi
echo "Copying source files from directory ${1}"
cp -fr ${1}/src ../emergent_overlays/
echo -e "Done\nSuccessful execution of ${0}"
