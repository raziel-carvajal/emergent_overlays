#!/bin/bash -
set -o nounset                              # Treat unset variables as an error

if [[ ${#} -lt 3 ]]; then
  echo "Usage: ${0} [src_dir] [plot_order_file] [metrics_file]"; exit 1
fi

# TODO
# 1.- check that arguments are existing files
# 2.- list in [plot_order_file] must be a subset of directories within [src_dir]
# 3.- remove output files

# NOTE example of how to run
# /merge_results.sh /home/raziel/Tmp/preliminary_results_emergent_ovrls/dynamic_scenario ~/Tmp/preliminary_results_emergent_ovrls/dynamic_scenario/order ~/Tmp/preliminary_results_emergent_ovr
# ls/dynamic_scenario/metrics

subDirs=`cat ${2} | awk '{print $1}'`
metrics=`cat ${3} | awk '{print $1}'`
metricIndx=1
for m in ${metrics}; do
  titleIndx=1
  dstF=${1}/${m}; rm -f ${dstF} && touch ${dstF}
  minLim=`head -${metricIndx} ${3} | tail -1 | awk '{print $2}'`
  maxLim=`head -${metricIndx} ${3} | tail -1 | awk '{print $3}'`
  for d in ${subDirs}; do
    fj="${1}/${d}/${m}"
    title=`head -${titleIndx} ${2} | tail -1 | awk '{print $2}'`
    echo "${fj} ${title} ${minLim} ${maxLim}" >>${dstF}
    let titleIndx=titleIndx+1
  done
  let metricIndx=metricIndx+1
  Rscript merge_dist_per_metric.R -d ${dstF} -n ${m}
done
