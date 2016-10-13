#!/bin/bash

path_to_configs=../../experiments/configs/builtConfigs/

# check if we have a path for omnet
if [ ! -f "omnet.config" ]; then
        while true; do
                read -p "Do you want to download omnet++ 4.6 (y/n) " yn
                case $yn in
                                [Yy]* ) ./download-omnet.sh; OMNET_PATH=../../tools/omnetpp-4.6 ; break;;
                                [Nn]* ) read -p "Please enter path to omnet++ 4.6 : " OMNET_PATH; break;;
                                * ) echo "Please enter y or n.";;
                esac
        done
else
        OMNET_PATH=`cat omnet.config`
fi

## OMNET_PATH=/home/inti/work/apps/omnetpp-4.6

SHA1=`cat ../../revision.txt`

CONFIG_PATH=${path_to_configs}

# configuring path to omnet++
source local-omnet-setenv.sh $OMNET_PATH

if [ ! -d "../../results" ]; then
    mkdir ../../results
fi

rm -f ../../results/broadcastSession*
rm -f ../../results/duplicatedMsgs*
rm -f ../../results/batteryConsumption*
rm -f ../../results/networkCoverage*
rm -f ../../results/*.pdf
rm -f ../../results/summary.csv

echo "" > ../../results/summary.csv

echo "Simulating"

for c in ${path_to_configs}*.ini ; do
	filename=$(basename "$c")
	config_name="${filename%.*}"
	nodes=`echo "$config_name" | awk -F "_" '{print $2 }'`
	density=`echo "$config_name" | awk -F "_" '{print $4 }'`
	protocol=`echo "$config_name" | awk -F "_" '{print $12 }'`
	if [ "$protocol" == "abba2" ] || [ "$protocol" == "mprt2" ] || [ "$protocol" == "cds3" ] || [ "$protocol" == "flooding"  ] ; then
    		if [ "${density}" -lt "18" ]; then
    			echo "This is one ${config_name}  ${nodes} ${density} ${protocol} "
			    sem -j+0 --no-notice ./run-one-configuration.sh ${c} ${OMNET_PATH}/samples/inet
    		fi
    #exit 1
	fi

done


sem --wait --no-notice


# Rscript extract-aggregated-charts.R ../../results/summary.csv ../../results/summary.pdf

echo "Creating aggregated results"

cat ../../results/broadcastSession-n_* >> ../../results/broadcastSession
cat ../../results/duplicatedMsgsDistribution-n_* >> ../../results/duplicatedMsgsDistribution
cat ../../results/batteryConsumptionDistribution-n_* >> ../../results/batteryConsumptionDistribution
cat ../../results/batteryConsumptionDistributionTime-n_* >> ../../results/batteryConsumptionDistributionTime

# Rscript import-data.R ../../results/ batteryConsumptionDistribution duplicatedMsgsDistribution broadcastSession

echo "Plotting aggregated results"

Rscript pretty-plotting.R -p ../../results/ -pc batteryConsumptionDistribution -dm duplicatedMsgsDistribution -bs broadcastSession
