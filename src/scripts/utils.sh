#!/bin/bash

error_msg_exit() {
	echo "$1"
	exit 1
}


array_contains () {
    local seeking=$1; shift
    local in=1
    for element; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}


get_density_from_config_name() {
  echo "$1" | awk -F "_" '{print $4 }'
}


get_protocol_from_config_name() {
  echo "$1" | awk -F "_" '{print $12 }'
}


get_nrnodes_from_config_name() {
  echo "$1" | awk -F "_" '{print $2 }'
}
