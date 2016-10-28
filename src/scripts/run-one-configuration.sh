#!/bin/bash

if [ $# -lt 2 ]; then
   echo "Wrong number of parameters"
   echo "Usage: $0 ConfigurationFile InetPath"
   exit 1
fi

# a file *.ini
CONF_FILE=$1

if [ ! -f "${CONF_FILE}" ]; then
   echo "Error: configuration file ${CONF_FILE} doesn't exist"
   exit 1
fi

# one of the configurations in that file

filename=$(basename "$1")
CONF_NAME=${filename%.*}
CONFIG_PATH=$(dirname "$1")

# executable omnet
OMNET=opp_run

# path to inet
INET_PATH=$2

# path to inet library. Observe the string INET at the end
INET_LIBRARY_PATH=${INET_PATH}/out/gcc-debug/src/INET

# path to library with protocols
PROTOCOLS_LIBRARY=../../built/gcc-debug/protocols

# specify my ned path. set of path where I can find ned files
LOCAL_NED_PATH=${INET_PATH}/examples:${INET_PATH}/src:../../experiments/networks:../protocols/:../base


echo "Executing : ${CONF_FILE}"
echo "Ned path: ${LOCAL_NED_PATH}"
echo "Inet Library: ${INET_LIBRARY_PATH}"
echo "Protocols: ${PROTOCOLS_LIBRARY}"
echo "Config File: ${CONF_FILE}"
echo "Executing command: ${OMNET} -u Cmdenv -n ${LOCAL_NED_PATH} -l ${INET_LIBRARY_PATH} -l ${PROTOCOLS_LIBRARY} -c ${CONF_NAME} -f ${CONF_FILE}"

${OMNET} -u Cmdenv -n ${LOCAL_NED_PATH} -l ${INET_LIBRARY_PATH} -l ${PROTOCOLS_LIBRARY} -c ${CONF_NAME} -f ${CONF_FILE}
r=$?
if [ $r -ne 0 ]; then
	exit 1
fi

NODES=`echo "$CONF_NAME" | awk -F "_" '{print $2 }'`
DENSITY=`echo "$CONF_NAME" | awk -F "_" '{print $4 }'`
PROTOCOL=`cat ${CONF_FILE} | grep udpApp | grep typename | awk -F "=" '{print $2}'`

simulation_time=`cat ${CONF_FILE} | grep "sim-time-limit" | tail -n 1 | grep -Eo '[0-9]{1,5}'`

count=`cat ${CONF_FILE} | grep repeat | awk -F "=" '{print $2}'`

echo "Checking ${count} repetitions"

END=$(($count))

for ((i=0;i<END;i++)); do
	#Rscript extract-charts.R --export-data-for-raziel ${CONFIG_PATH}/results/${CONF_NAME}-$i ../../results/ ${simulation_time} ${CONF_NAME} --algorithm ${PROTOCOL} --density 0
        #exit 1
	results=`Rscript extract-charts.R --show-averages ${CONFIG_PATH}/results/${CONF_NAME}-$i ../../results/ ${simulation_time} ${CONF_NAME} | grep average_values`
	echo "Repetition $i"
	echo "$results"

	coverage=`echo ${results} | awk '{print $3}'`
	broadcast_time=`echo ${results} | awk '{print $4}'`
	power_consumption=`echo ${results} | awk '{print $5}'`
	duplicated_messages=`echo ${results} | awk '{print $6}'`
	retransmissions=`echo ${results} | awk '{print $7}'`

	echo "${CONF_NAME},${PROTOCOL},${NODES},${DENSITY},${coverage},${broadcast_time},${power_consumption},${duplicated_messages},${retransmissions}" >> ../../results/summary.csv
done
