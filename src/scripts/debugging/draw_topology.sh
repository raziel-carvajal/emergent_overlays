#!/bin/bash - 
#===============================================================================
#
#          FILE: draw_topology.sh
# 
#         USAGE: ./draw_topology.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 11/07/2016 17:35
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

if [ $# -lt 2 ]; then
  echo "Error: Worng number of parameters, type the log file (with full path) of your Omnet experiment"
  echo "Usage: $0 LogFileOfExperimentExecution Algorithm"
  exit 1
fi
logFile=$1
algo=$2
if [ ! -f "${logFile}" ]; then
  echo "Error: The log file ${logFile} doesn't exists"
  exit 1
fi
dst="topology_"$(basename "${logFile}")
rm -fr ${dst} 
mkdir ${dst}
dst="./${dst}/"
loops=`grep ":: POSITION" ${logFile} |awk -F " " '{print $8}'| sort -u| wc -l`
echo "Creating input files..."
for (( CNTR=1; CNTR<=${loops}; CNTR+=1 )); do
  key=`grep ":: POSITION" ${logFile} |awk -F " " '{print $8}'| sort -u| head -${CNTR}| tail -1`
  echo "DOING FOR KEY: ${key}"
  grep "BROADCASTING ${key} TO_NEIGHBORS" ${logFile} >${dst}graph_${CNTR}
  grep "KEY_RECEPTION ${key} FROM_PEER" ${logFile} >${dst}rcvMsgs_${CNTR}
done
echo -e "\tDONE\nDrawing topology per loop..."
python draw_overlay.py ${loops} ${dst} ${algo}
echo -e "\tDONE"
#rm ${dst}graph_*
#rm ${dst}nodes_*
#rm ${dst}relays_*
