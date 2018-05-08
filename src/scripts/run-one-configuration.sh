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
#OMNET="mpirun --np 1 --cpu-set 0,1,2 opp_run"
OMNET="opp_run"

# path to inet
INET_PATH=$2

# when this flags values 1 just collisions are computed
EXPE_FOR_COLLISIONS=$3

# path to inet library. Observe the string INET at the end
INET_LIBRARY_PATH=${INET_PATH}/out/gcc-debug/src/INET

# path to library with protocols
PROTOCOLS_LIBRARY=../../built/gcc-debug/protocols

# specify my ned path. set of path where I can find ned files
#LOCAL_NED_PATH=${INET_PATH}/examples:${INET_PATH}/src:../../experiments/networks:../protocols/:../base
LOCAL_NED_PATH=${INET_PATH}/src:../../experiments/networks:../protocols/:../base

echo "Executing : ${CONF_FILE}"
echo "Ned path: ${LOCAL_NED_PATH}"
echo "Inet Library: ${INET_LIBRARY_PATH}"
echo "Protocols: ${PROTOCOLS_LIBRARY}"
echo "Config File: ${CONF_FILE}"
echo "Executing command: ${OMNET} -u Cmdenv -n ${LOCAL_NED_PATH} -l ${INET_LIBRARY_PATH} -l ${PROTOCOLS_LIBRARY} -c ${CONF_NAME} -f ${CONF_FILE}"

NODES=`echo "$CONF_NAME" | awk -F "_" '{print $2 }'`
DENSITY=`echo "$CONF_NAME" | awk -F "_" '{print $4 }'`

#densityAsString=`grep "${DENSITY}" densities| head -1| awk '{print $2}'`
PROTOCOL=`echo ${CONF_NAME} | awk -F "_" '{ print $12 }'`
logFile="n_${NODES}_d_${DENSITY}_p_${PROTOCOL}"

# ${OMNET} -u Cmdenv -n ${LOCAL_NED_PATH} -l ${INET_LIBRARY_PATH} -l ${PROTOCOLS_LIBRARY} -c ${CONF_NAME} -f ${CONF_FILE} &>debugging/logs/${logFile}

${OMNET} -u Cmdenv -n ${LOCAL_NED_PATH} -l ${INET_LIBRARY_PATH} -l ${PROTOCOLS_LIBRARY} -c ${CONF_NAME} -f ${CONF_FILE}
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

# TODO: DO NOT FORGET TO WRITE EVERY VALUE AT THE INI FILE AS DOUBLE, EVEN IF IT IS INTEGER
# NOTE: when you grep in this way, be sure that the INI file contains float values for wakeUpTime AND deltaApprox
simulation_time=`cat ${CONF_FILE} | grep "sim-time-limit" | tail -n 1 | grep -Eo '[0-9]{1,5}'`
step=`cat ${CONF_FILE} |grep "intervalBroadcastTime" | head -1 | awk -F "=" '{print $2}'| grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
transmissionRange=`cat ${CONF_FILE} | grep "maxCommunicationRange" | tail -n 1 | grep -Eo '[0-9]{1,5}'`
wakeUpTime=`cat ${CONF_FILE} | grep "wakeUpTime" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
deltaApprox=`cat ${CONF_FILE} | grep "deltaApprox" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
firstPosT=$(bc <<< "${wakeUpTime}+${deltaApprox}")
broadcastMsgs=`cat ${CONF_FILE} | grep nr_broadcast_msg | head -1 | awk -F "=" '{print $2}'| grep -Eo '[0-9]{1,5}'`
count=`cat ${CONF_FILE} | grep repeat | awk -F "=" '{print $2}'`

DENSE_ZONE_X=`cat ${CONF_FILE} | grep "centerDensAx" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
DENSE_ZONE_Y=`cat ${CONF_FILE} | grep "centerDensAy" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
DENSE_ZONE_X_HALF_LEN=`cat ${CONF_FILE} | grep "denseAreaWid" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
DENSE_ZONE_Y_HALF_LEN=${DENSE_ZONE_X_HALF_LEN}

echo "Simulation time [${simulation_time}]"
echo "Frequency of broadcast messages: [${step}]"
echo "Transmission range [${transmissionRange}]"
echo "Time of first broadcast [${wakeUpTime}]"
echo "Broadcast messages number [${broadcastMsgs}]"
echo "First time when nodes print their position [${firstPosT}]"
echo "Delta aproximation [${deltaApprox}]"
echo "Dense zone cetered at [${DENSE_ZONE_X}, ${DENSE_ZONE_Y}]"
echo "Dense zone [width/2, height/2] [${DENSE_ZONE_X_HALF_LEN}, ${DENSE_ZONE_Y_HALF_LEN}]"

Rscript extract-charts.R --show-averages ${CONFIG_PATH}/results/${CONF_NAME}-0 ../../results/ \
  ${simulation_time} ${CONF_NAME} ${step} -b ${broadcastMsgs} \
  -t ${transmissionRange} -f_t ${firstPosT} -f_b ${wakeUpTime} \
  -d_x ${DENSE_ZONE_X} -d_y ${DENSE_ZONE_Y} -d_h_x ${DENSE_ZONE_X_HALF_LEN} \
  -d_h_y ${DENSE_ZONE_Y_HALF_LEN}

echo "Moving to debugging/logs/ every graph built in experiment ${CONF_NAME}"
rm -fr debugging/logs/${CONF_NAME}
mkdir -p debugging/logs/${CONF_NAME}
mv *.pdf debugging/logs/${CONF_NAME}
cp ${CONFIG_PATH}/${CONF_NAME}".ini" debugging/logs/${CONF_NAME}
echo "Compression of logs..."
tar czf debugging/logs/${CONF_NAME}.tgz debugging/logs/${CONF_NAME}
echo "DONE"
echo "Moving logs to results folder"
mv debugging/logs/${CONF_NAME}.tgz ../../results
echo "All PDF files were copied"
