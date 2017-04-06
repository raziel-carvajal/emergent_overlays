#!/bin/bash - 
#===============================================================================
#
#          FILE: MapNodeIdProtocolId.sh
# 
#         USAGE: ./MapNodeIdProtocolId.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 04/05/17 14:47
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

fileName=$1
outFile=$2
grep typename -F "${fileName}" | grep -E "hostR[0-9]+" | awk -F '.' '{print $2, $4}' | awk -F ' ' '{print $1, $4}' >${outFile}
