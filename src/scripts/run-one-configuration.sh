#!/bin/bash

if [ $# -lt 3 ]; then
   echo "Wrong number of parameters"
   echo "Usage: $0 ConfigurationFile InetPath ExpeForCollisions"
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

# when this flags values 1 just collisions are computed
EXPE_FOR_COLLISIONS=$3

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

NODES=`echo "$CONF_NAME" | awk -F "_" '{print $2 }'`
DENSITY=`echo "$CONF_NAME" | awk -F "_" '{print $4 }'`
#densityAsString=`grep "${DENSITY}" densities| head -1| awk '{print $2}'`
PROTOCOL=`cat ${CONF_FILE} | grep udpApp | grep typename | awk -F "=" '{print $2}'`
algoN=`echo "$CONF_NAME" | awk -F "_" '{print $12 }'`
logFile="n_${NODES}_d_${DENSITY}_p_${algoN}"

${OMNET} -u Cmdenv -n ${LOCAL_NED_PATH} -l ${INET_LIBRARY_PATH} -l ${PROTOCOLS_LIBRARY} -c ${CONF_NAME} -f ${CONF_FILE} &>debugging/logs/${logFile}
r=$?

if [ $r -ne 0 ]; then
  echo -e "\nERROR: for more details check this file: debugging/logs/${logFile}"
	exit 1
fi


if [ ${EXPE_FOR_COLLISIONS} -eq "1" ]; then
  echo "COMPUTATION FOR COLLISIONS STARTS..."
  cd debugging
  ./draw_topology.sh logs/${logFile} ${PROTOCOL}
  cd ..
  echo -e "\tEND OF COMPUATION OF COLLISIONS"
  exit 1
fi

simulation_time=`cat ${CONF_FILE} | grep "sim-time-limit" | tail -n 1 | grep -Eo '[0-9]{1,5}'`
step=`cat ${CONF_FILE} |grep intervalBroadcastTime |awk -F "=" '{print $2}'|grep -Eo '[0-9]'`

count=`cat ${CONF_FILE} | grep repeat | awk -F "=" '{print $2}'`

echo "Checking ${count} repetitions"

END=$(($count))

for ((i=0;i<END;i++)); do
  withFa=""
  # if [ "${algoN}" == "fullyAdaptive" ]; then
  #   echo "Experiment with FullyAdaptive ${CONF_FILE} ${CONF_NAME}.mapping" >> log.txt
  #   ./MapNodeIdProtocolId.sh ${CONF_FILE} ${CONF_NAME}".mapping"
  #   #withFa="-mf ${CONF_NAME}.mapping"
  # fi

  # Rscript extract-charts.R --show-averages ${withFa} ${CONFIG_PATH}/results/${CONF_NAME}-$i ../../results/ ${simulation_time} ${CONF_NAME} 5
	#Rscript extract-charts.R --export-data-for-raziel ${CONFIG_PATH}/results/${CONF_NAME}-$i ../../results/ ${simulation_time} ${CONF_NAME} ${step} --algorithm ${PROTOCOL} --density-as-string ${densityAsString} --plot
  #      exit 1
	results=`Rscript extract-charts.R --show-averages ${withFa} ${CONFIG_PATH}/results/${CONF_NAME}-$i ../../results/ ${simulation_time} ${CONF_NAME} 5 | grep average_values`
	echo "Repetition $i"
	echo "$results"

	coverage=`echo ${results} | awk '{print $3}'`
	broadcast_time=`echo ${results} | awk '{print $4}'`
	power_consumption=`echo ${results} | awk '{print $5}'`
	duplicated_messages=`echo ${results} | awk '{print $6}'`
	retransmissions=`echo ${results} | awk '{print $7}'`

	echo "${CONF_NAME},${PROTOCOL},${NODES},${DENSITY},${coverage},${broadcast_time},${power_consumption},${duplicated_messages},${retransmissions}" >> ../../results/summary.csv
done
