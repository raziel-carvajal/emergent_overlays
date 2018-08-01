#!/bin/bash

echo "Creating aggregated results"
cat ../../results/broadcastSession-n_* > ../../results/broadcastSession
cat ../../results/batteryConsumptionDistribution-n_* > ../../results/batteryConsumptionDistribution
cat ../../results/coverage-n_* > ../../results/coverage
cat ../../results/sentBroadcastMsgsDistribution-n_* > ../../results/sentBroadcastMsgsDistribution
cat ../../results/recvBroadcastMsgsDistribution-n_* > ../../results/recvBroadcastMsgsDistribution
cat ../../results/sentCtrlMsgsDistribution-n_* > ../../results/sentCtrlMsgsDistribution
cat ../../results/recvCtrlMsgsDistribution-n_* > ../../results/recvCtrlMsgsDistribution
cat ../../results/collisionsRelativeError-n_* > ../../results/collisionsRelativeError
cat ../../results/densityRelativeError-n_* > ../../results/densityRelativeError
cat ../../results/noderoles-n_* > ../../results/noderoles

# -dre densityRelativeError \
echo "Plotting aggregated results"
Rscript pretty-plotting.R \
  -ds groundTruthDensityDist- \
	-bs broadcastSession \
	-cv coverage \
	-cre collisionsRelativeError \
	-sent_bro sentBroadcastMsgsDistribution \
	-recv_bro recvBroadcastMsgsDistribution \
	-sent_ctrl sentCtrlMsgsDistribution \
	-recv_ctrl recvCtrlMsgsDistribution \
  -nodes_roles noderoles \
  -pc batteryConsumptionDistribution ../../results/
mv Rplots.pdf ../../results
