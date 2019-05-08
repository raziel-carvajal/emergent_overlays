#!/bin/bash - 
#===============================================================================
#
#          FILE: get-mobility-dataset.sh
# 
#         USAGE: ./get-mobility-dataset.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION: 
#       CREATED: 10/17/2017 18:01
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

f=${1}
outF="mobility-dataset"
rm -fr ${outF}
nodes=`head -1 ${f}`
step=`head -2 ${f} | tail -1`
t=${step}
lineC=3
linesInF=`cat ${f} | wc -l`
let linesInF=linesInF-2
movs=$(bc <<< "${linesInF}/${nodes}")
echo "nodes[${nodes}] step[${step}] movs[${movs}]"
touch ${outF}
for (( i=0; i<${movs}; i+=1 )); do
  for (( j=1; j<=${nodes}; j+=1 )); do
		coord=`cat ${f} | head -${lineC} | tail -1`
		echo "${j} ${t} ${coord}" >> ${outF}
		let lineC=lineC+1
  done
	echo "cycle[${i}] step[${t}]"
	t=$(bc <<< "${t} + ${step}")
done
echo "END of ${0}"
