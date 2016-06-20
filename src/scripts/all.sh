#!/bin/bash

OMNET_PATH=~/work/apps/omnetpp-4.6

SHA1=`cat ../../revision.txt`

CONFIG_PATH=../../experiments/configs

# configuring path to omnet++
source local-setenv-omnet.sh $OMNET_PATH

# checking that everything is ready to execute the experiments
./sanity-checks.sh

# load the right version of the code 
./load-proper-version.sh ${SHA1}


# function to extract the configuration name from a given configuration file
get_config_name() {
   $1
}

for config in "${CONFIG_PATH}/*.ini"; do
    CONFIG_FILE=${config}
    CONFIG_NAME=get_config_name(${config})
    echo ${CONFIG_NAME}
    #./run-one-configuration.sh ${CONFIG_FILE} ${CONFIG_NAME}
done


