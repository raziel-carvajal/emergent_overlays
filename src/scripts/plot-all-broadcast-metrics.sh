#!/bin/bash
# [BEGIN] Comment to perform unit test
while :
do
  continue=`curl trace_generator/all_tasks_done`
  echo "All task done? ${continue}"
  [ "${continue}" == "Y" ] && break
  echo "Wait for workers until they finish..."
  sleep 10
done
# [END] Comment to perform unit test

echo "Plotting all broadcast metrics"
Rscript plot-broadcast-metrics.R \
  --plot-sent-msgs \
  --plot-recv-msgs \
  ../../results/
mv Rplots.pdf ../../results
echo "End of ${0}"
