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
	protocol=`echo "$config_name" | awk -F "_" '{print $10 }'`
	if [ "$protocol" == "abba2" ]; then
		echo "This is one ${config_name}  ${nodes} ${density} ${protocol} "
		echo "Executing : ${c}"
		
		./run-one-configuration.sh "${c}" "${config_name}" "${OMNET_PATH}/samples/inet" "../../built/gcc-debug/protocols"
		r=$?
		if [ $r -ne 0 ]; then
  			echo "Error: failure running simulation ${config_name}"
  			exit 1
		fi
		simulation_time=`cat "${c}" | grep "sim-time-limit" | tail -n 1 | grep -Eo '[0-9]{1,5}'`
		results=`Rscript extract-charts.R ${CONFIG_PATH}/results/${config_name}-0 ../../results/${config_name} ${simulation_time} | grep average_values`
		coverage=`echo ${results} | awk '{print $2}'`	
		broadcast_time=`echo ${results} | awk '{print $3}'`
		power_consumption=`echo ${results} | awk '{print $4}'`
		duplicated_messages=`echo ${results} | awk '{print $5}'`
		echo "${config_name},${protocol},${nodes},${density},${coverage},${broadcast_time},${power_consumption},${duplicated_messages}" >> ../../results/summary.csv
		exit 0
	elif [ "$protocol" == "dist2mean2" ]; then	
		echo "This is one ${config_name}  ${nodes} ${density} ${protocol} "
	fi
	
done
