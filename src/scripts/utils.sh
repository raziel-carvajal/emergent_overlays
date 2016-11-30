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

chooseRightCnf() {
  file=$1
  dens=$2
  algo=$3
  newName=""
  for (( CNTR=1; CNTR<13; CNTR+=1 )); do
    if [ ${CNTR} -eq 4 ] ; then
      newName="${newName}${dens}_"
    fi
    if [ ${CNTR} -eq 12 ] ; then
      newName="${newName}${algo}.ini"
    else
      str=`echo ${file} |awk -F "_" -v I=${CNTR} '{print $I}'`
      newName="${newName}${str}_"
    fi
  done
  echo ${newName}
}
