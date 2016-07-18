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

echo "" > ../../results/summary.csv

for c in ${path_to_configs}*.ini ; do
	filename=$(basename "$c")
	config_name="${filename%.*}"
	nodes=`echo "$config_name" | awk -F "_" '{print $2 }'`
	density=`echo "$config_name" | awk -F "_" '{print $4 }'`
	protocol=`echo "$config_name" | awk -F "_" '{print $12 }'`	
	if [ "$protocol" == "abba2" ] || [ "$protocol" == "dist2mean2" ] || [ "$protocol" == "ewma2" ] || [ "$protocol" == "mprt2" ] || [ "$protocol" == "cds"  ] ; then
		echo "This is one ${config_name}  ${nodes} ${density} ${protocol} "
		sem -j -1 --id "infocom2017" --no-notice ./run-one-configuration.sh ${c} ${OMNET_PATH}/samples/inet
		#exit 1
	fi
	
done


sem --wait --id "infocom2017" --no-notice


Rscript extract-aggregated-charts.R ../../results/summary.csv ../../results/summary.pdf
