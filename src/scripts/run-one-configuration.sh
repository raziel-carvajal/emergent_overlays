#!/bin/bash
if [ ${#} -lt 2 ]; then
   echo "Wrong number of parameters"
   echo "Usage: $0 <ini-file> <inet-path>"
   exit 1
fi
if [ ! -f "${1}" ]; then
 echo "Error: configuration file ${1} doesn't exist"
 exit 1
fi
CONF_FILE=${1}
if [ ! -f ${2}/src/libINET.so ]; then
  echo "Error: ${1} doesn't look like an INET directory"
  exit 1
fi
INET_PATH=${2}

filename=$(basename "${CONF_FILE}")
CONF_NAME=${filename%.*}
CONFIG_PATH=$(dirname "${CONF_FILE}")

INET_LIB=${INET_PATH}/src/INET
EMOV_LIB=../emergent_overlays/out/gcc-debug/emergent_overlays
NED_PATH=${INET_PATH}/src:../emergent_overlays:../../experiments/networks

echo "Eperiment: ${CONF_NAME}"
echo "Execution with command: opp_run -u Cmdenv -n ${NED_PATH} -l ${INET_LIB} -l ${EMOV_LIB} -c ${CONF_NAME} -f ${CONF_FILE}"

NODES=`echo "$CONF_NAME" | awk -F "_" '{print $2 }'`
DENSITY=`echo "$CONF_NAME" | awk -F "_" '{print $4 }'`
PROTOCOL=`echo ${CONF_NAME} | awk -F "_" '{ print $12 }'`
logFile="n_${NODES}_d_${DENSITY}_p_${PROTOCOL}"

# ${OMNET} -u Cmdenv -n ${LOCAL_NED_PATH} -l ${INET_LIBRARY_PATH} -l ${PROTOCOLS_LIBRARY} -c ${CONF_NAME} -f ${CONF_FILE} &>debugging/logs/${logFile}

opp_run -u Cmdenv -n ${NED_PATH} -l ${INET_LIB} -l ${EMOV_LIB} -c ${CONF_NAME} -f ${CONF_FILE}
if [ ${?} -ne 0 ]; then
  echo -e "\nERROR: for more details check this file: debugging/logs/${logFile}"
	exit 1
fi

# # TODO: DO NOT FORGET TO WRITE EVERY VALUE AT THE INI FILE AS DOUBLE, EVEN IF IT IS INTEGER
# # NOTE: when you grep in this way, be sure that the INI file contains float values for wakeUpTime AND deltaApprox
# simulation_time=`cat ${CONF_FILE} | grep "sim-time-limit" | tail -n 1 | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
# step=`cat ${CONF_FILE} |grep "intervalBroadcastTime" | head -1 | awk -F "=" '{print $2}'| grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
# transmissionRange=`cat ${CONF_FILE} | grep "maxCommunicationRange" | tail -n 1 | grep -Eo '[0-9]{1,5}'`
# wakeUpTime=`cat ${CONF_FILE} | grep "wakeUpTime" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
# deltaApprox=`cat ${CONF_FILE} | grep "deltaApprox" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
# firstPosT=$(bc <<< "${wakeUpTime}+${deltaApprox}")
# broadcastMsgs=`cat ${CONF_FILE} | grep nr_broadcast_msg | head -1 | awk -F "=" '{print $2}'| grep -Eo '[0-9]{1,5}'`
# count=`cat ${CONF_FILE} | grep repeat | awk -F "=" '{print $2}'`
#
# DENSE_ZONE_X=`cat ${CONF_FILE} | grep "centerDensAx" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
# DENSE_ZONE_Y=`cat ${CONF_FILE} | grep "centerDensAy" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
# DENSE_ZONE_WIDTH=`cat ${CONF_FILE} | grep "denseAreaWid" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
#
# echo "Simulation time [${simulation_time}]"
# echo "Frequency of broadcast messages: [${step}]"
# echo "Transmission range [${transmissionRange}]"
# echo "Time of first broadcast [${wakeUpTime}]"
# echo "Broadcast messages number [${broadcastMsgs}]"
# echo "First time when nodes print their position [${firstPosT}]"
# echo "Delta aproximation [${deltaApprox}]"
# echo "Dense zone cetered at [${DENSE_ZONE_X}, ${DENSE_ZONE_Y}]"
# echo "Dense zone width [${DENSE_ZONE_WIDTH}]"
#
# Rscript extract-charts.R --show-averages ${CONFIG_PATH}/results/${CONF_NAME}-0 ../../results/ \
#   ${simulation_time} ${CONF_NAME} ${step} -b ${broadcastMsgs} \
#   -t ${transmissionRange} -f_t ${firstPosT} -f_b ${wakeUpTime} \
#   -d_x ${DENSE_ZONE_X} -d_y ${DENSE_ZONE_Y} -d_z_w ${DENSE_ZONE_WIDTH}
#
# echo "Moving to debugging/logs/ every graph built in experiment ${CONF_NAME}"
# rm -fr debugging/logs/${CONF_NAME}
# mkdir -p debugging/logs/${CONF_NAME}
# mv *.pdf debugging/logs/${CONF_NAME}
# cp ${CONFIG_PATH}/${CONF_NAME}".ini" debugging/logs/${CONF_NAME}
# echo "Compression of logs..."
# tar czf debugging/logs/${CONF_NAME}.tgz debugging/logs/${CONF_NAME}
# echo "DONE"
# echo "Moving logs to results folder"
# mv debugging/logs/${CONF_NAME}.tgz ../../results
# echo "All PDF files were copied"
