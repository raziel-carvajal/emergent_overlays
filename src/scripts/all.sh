#!/bin/bash

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

CONFIG_PATH=../../experiments/configs

# configuring path to omnet++
source local-omnet-setenv.sh $OMNET_PATH

# checking that everything is ready to execute the experiments
./sanity-check.sh
r=$?
if [ $r -eq 0 ]; then
	echo "${OMNET_PATH}" >> omnet.config
fi

# load the right version of the code
echo "Checking out revision $SHA1"
#./load-proper-version.sh ${SHA1}


# compile applications' code
./compile_protocols.sh "../protocols" "${OMNET_PATH}/samples/inet/" "../../built"
error_code=$?
echo "error code ===>>>>>> ${error_code}"
if [ ${error_code} -ne 0 ]; then
   echo "Error: problem compiling. Aborting"
   exit 1
fi

if [ ! -d "../../results" ]; then
    mkdir ../../results
fi


for config in ${CONFIG_PATH}/*.ini ; do
    filename=$(basename "$config")
    config_name="${filename%.*}"
    echo "Executing : ${config}"
    ./run-one-configuration.sh "${config}" "${config_name}" "${OMNET_PATH}/samples/inet" "../../built/gcc-debug/protocols"
	r=$?
	if [ $r -ne 0 ]; then
		echo "Error: failure running simulation ${config_name}"
		exit 1
	fi
	Rscript extract-charts.R ${CONFIG_PATH}/results/${config_name}-0 ../../results/${config_name}
done
