#!/bin/bash
while :
do
  continue=`curl trace_generator/all_task_done`
  [ "${continue}" == "Y" ] && break
  echo "Wait for workers until they finish..."
  sleep 10
done
echo "All workes have finished"
cat ../../results/batteryConsumptionDistribution-* \
  > ../../results/batteryConsumptionDistribution
#
cat ../../results/coverage-* > ../../results/coverage
#
cat ../../results/packetErrorRate-* > ../../results/packetErrorRate
#
cat ../../results/recvBroadcastMsgsDistribution-* \
  > ../../results/recvBroadcastMsgsDistribution
cat ../../results/sentBroadcastMsgsDistribution-* \
  > ../../results/sentBroadcastMsgsDistribution

# cat ../../results/broadcastSession-n_* > ../../results/broadcastSession
# cat ../../results/sentCtrlMsgsDistribution-n_* > ../../results/sentCtrlMsgsDistribution
# cat ../../results/recvCtrlMsgsDistribution-n_* > ../../results/recvCtrlMsgsDistribution
# cat ../../results/collisionsRelativeError-n_* > ../../results/collisionsRelativeError
# cat ../../results/densityRelativeError-n_* > ../../results/densityRelativeError
# cat ../../results/noderoles-n_* > ../../results/noderoles

echo "Plotting all broadcast metrics"
Rscript plot-broadcast-metrics.R \
  --plot-energy-consumption \
  --plot-coverage \
  --plot-packet-err \
  --plot-sent-msgs \
  --plot-recv-msgs \
  ../../results/
mv Rplots.pdf ../../results
echo "End of ${0}"
