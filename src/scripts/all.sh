#!/bin/bash

# sort of include files
. utils.sh

# install all dependencies
. install-everything.sh || error_msg_exit "Error configuring the framework"

CONFIG_PATH=../../experiments/configs/builtConfigs

minimum_density=100000
maximum_density=0
algorithms=()

for config in ${CONFIG_PATH}/*.ini ; do
    filename=$(basename "$config")
		config_name="${filename%.*}"
		density=$(get_density_from_config_name $config_name)
		protocol=$(get_protocol_from_config_name $config_name)

		if [ "$density" -lt "$minimum_density" ]; then
			minimum_density=$density
		fi
		if [ "$density" -gt "$maximum_density" ]; then
			maximum_density=$density
		fi

		algorithms+=("-a" $protocol)
done

./run-selected-protocols-all-configs.sh -d $minimum_density -D $maximum_density -p ${CONFIG_PATH} ${algorithms[@]}
