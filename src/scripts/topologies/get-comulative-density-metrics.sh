#!/bin/bash -
#===============================================================================
#
#          FILE: get-comulative-density-metrics.sh.sh
#
#         USAGE: ./get-comulative-density-metrics.sh.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 02/28/2019 13:48
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
areaLen=10
rm -f *.dataset
for (( i = ${1}; i <= ${2}; i++ )); do
	let n=${i}*${3}
	echo "Getting distributions from overlay of [${n}] nodes..."
	./generate_levy-walk_trace.py --nodes-no ${n} --area-len ${areaLen}
	Rscript get-density-metrics.R "levy-walk_${n}_${areaLen}-X-${areaLen}.dataset"
	echo -e "\tDONE"
done
comDs='comulative_ds.txt'; rm -f ${comDs}
for dataset in `ls -t *.dataset | grep cluCoef`
do
	cat ${dataset} >> ${comDs}
done
echo "Plotting cumulative distributions of clustering coeficient and density..."
Rscript plot-density-metrics.R ${comDs} --with-clustering-coef
Rscript plot-density-metrics.R ${comDs} --with-closure-coef
Rscript plot-density-metrics.R ${comDs} --with-density
echo -e "\tDONE"
echo "END of ${0}"
