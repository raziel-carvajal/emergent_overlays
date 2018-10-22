#!/bin/bash

# sort of include files
. utils.sh

CONFIG_PATH=../../experiments/configs/

usage() {
  echo "Usage $0: [-p PATH] CONFIGURATION_FILENAME"
  echo ""
  echo -e "\tPATH: used to locate the configurations (../../experiments/configs/ by default)\n"
}

# parsing parameters
while getopts "p:h" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    p)
      CONFIG_PATH=$OPTARG
      ;;
    \?)
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))
config_name="$1"

# install all dependencies
. install-everything.sh || error_msg_exit "Error configuring the framework"

# executes the simulation
density=$(get_density_from_config_name $config_name)
protocol=$(get_protocol_from_config_name $config_name)
./run-selected-protocols-all-configs.sh -d $density -D $density -p ${CONFIG_PATH} -a $protocol
