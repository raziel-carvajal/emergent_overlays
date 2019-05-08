#!/bin/bash - 
#===============================================================================
#
#          FILE: tag-images.sh
# 
#         USAGE: ./tag-images.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION: 
#       CREATED: 03/29/2019 15:01
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
for i in `sudo docker images | grep "emergent_overlays_[a-z]" | awk '{print $1}'` ; do sudo docker tag ${i} emergent_overlays_1_$(echo ${i} | awk -F "emergent_overlays_" '{print $2}'); done

