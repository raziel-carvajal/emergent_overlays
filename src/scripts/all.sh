#!/bin/bash

OMNET_PATH=/home/inti/work/apps/omnetpp-4.6

SHA1=`cat ../../revision.txt`

CONFIG_PATH=../../experiments/configs

# configuring path to omnet++
source local-omnet-setenv.sh $OMNET_PATH

# checking that everything is ready to execute the experiments
./sanity-check.sh

# load the right version of the code 
echo "Checking out revision $SHA1"
#./load-proper-version.sh ${SHA1}


# compile applications' code
./compile_protocols.sh "../protocols" "${OMNET_PATH}/samples/inet/" "../../built"
error_code=$?
echo "error code ===>>>>>> ${error_code}"
if [ "${error_code}" -gt "0" ]; then
   echo "Error: problem compiling. Aborting"
   exit 1
fi

# function to extract the configuration name from a given configuration file
get_config_name() {
   echo "main_config"
}

if [ ! -d "../../results" ]; then
    mkdir ../../results
fi 

for config in ${CONFIG_PATH}/*.ini ; do
    #CONFIG_FILE=${config}
    #CONFIG_NAME=$(get_config_name "${config}")
    #printf "%s\n" ${CONFIG_NAME}
    filename=$(basename "$config")
    config_name="${filename%.*}"
    echo "Executing : ${config}"
    ./run-one-configuration.sh "${config}" "${config_name}" "${OMNET_PATH}/samples/inet" "../../built/gcc-debug/protocols"
    #tar -zcvf "${CONFIG_PATH}/results/${config_name}" ${CONFIG_PATH}/results/${config_name}-0.sca ${CONFIG_PATH}/results/${config_name}-0.vec ${CONFIG_PATH}/results/${config_name}-0.vci
    ./extract-data.sh ${CONFIG_PATH}/results/${config_name}-0.vec msg_sent ../../results
    ./extract-data.sh ${CONFIG_PATH}/results/${config_name}-0.vec broadcast_msg_received ../../results
    ./extract-data.sh ${CONFIG_PATH}/results/${config_name}-0.vec power_level ../../results
    nr_nodes=`echo ${config_name} | awk -F "-" '{print $2}'`
    python processing-data.py "../../results/" "${config_name}" hostR0 ${nr_nodes}
done


