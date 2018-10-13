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
EMOV_LIB=../emergent_overlays/emergent_overlays

NED_PATH=${INET_PATH}/src:../emergent_overlays/src:../../experiments/networks

echo "Eperiment: ${CONF_NAME}"
echo "Execution with command: opp_run -u Cmdenv -n ${NED_PATH} -l ${INET_LIB} -l ${EMOV_LIB} -c ${CONF_NAME} -f ${CONF_FILE}"

NODES=`echo "$CONF_NAME" | awk -F "_" '{print $2 }'`
DENSITY=`echo "$CONF_NAME" | awk -F "_" '{print $4 }'`
PROTOCOL=`echo ${CONF_NAME} | awk -F "_" '{ print $12 }'`

opp_run -u Cmdenv -n ${NED_PATH} -l ${INET_LIB} -l ${EMOV_LIB} -c ${CONF_NAME} -f ${CONF_FILE}
[ ${?} -ne 0 ] && \
  echo "Error. Unsuccessful execution of experiment: ${CONF_NAME}" && exit 1
echo "Success, correct execution of ${CONF_NAME}"

simTime=`grep "sim-time-limit" ${CONF_FILE} | awk -F " = " '{print $2}' | grep -Eo '[0-9]{1,5}'`

broaInt=`grep "sendInterval" ${CONF_FILE} | awk -F "uniform" '{print $2}' | awk -F "(" '{print $2}' | awk -F ")" '{print $1}'`
broaT0=`echo ${broaInt} | awk -F "," '{print $1}' | awk -F "s" '{print $1}' | grep -Eo '[0-9]{0,5}.[0-9]{0,5}'`
broaT1=`echo ${broaInt} | awk -F ", " '{print $2}' | awk -F "s" '{print $1}' | grep -Eo '[0-9]{0,5}.[0-9]{0,5}'`

tx=`grep "maxCommunicationRange" ${CONF_FILE} | awk -F " = " '{print $2}' | grep -Eo '[0-9]{1,5}'`

# deltaApprox=`cat ${CONF_FILE} | grep "deltaApprox" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
# firstPosT=$(bc <<< "${wakeUpTime}+${deltaApprox}")
# count=`cat ${CONF_FILE} | grep repeat | awk -F "=" '{print $2}'`
# DENSE_ZONE_X=`cat ${CONF_FILE} | grep "centerDensAx" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
# DENSE_ZONE_Y=`cat ${CONF_FILE} | grep "centerDensAy" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
# DENSE_ZONE_WIDTH=`cat ${CONF_FILE} | grep "denseAreaWid" | head -1 | awk -F "=" '{print $2}' | grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
echo "Details of experiment [${CONF_NAME}]"
echo -e "\tSimulation time: ${simTime}"
echo -e "\tBroadcast message interval: ${broaInt}"
echo -e "\tNodes transmission range: ${tx}"
# echo -e "\tTime of first broadcast [${wakeUpTime}]"
# echo -e "\tBroadcast messages number [${broadcastMsgs}]"
# echo -e "\tFirst time when nodes print their position [${firstPosT}]"
# echo -e "\tDelta aproximation [${deltaApprox}]"
# echo -e "\tDense zone cetered at [${DENSE_ZONE_X}, ${DENSE_ZONE_Y}]"
# echo -e "\tDense zone width [${DENSE_ZONE_WIDTH}]"

Rscript get-broadcast-metrics.R \
  --simulation-time ${simTime} \
  --broadcast-interval-lim-inf ${broaT0} \
  --broadcast-interval-lim-sup ${broaT1} \
  --transmission-range ${tx} \
  --results-dir ../../results \
  ${CONF_NAME} ${CONF_FILE}

echo "Moving to debugging/logs/ every graph built in experiment ${CONF_NAME}"
rm -fr debugging/logs/${CONF_NAME}
mkdir -p debugging/logs/${CONF_NAME}
mv *.pdf debugging/logs/${CONF_NAME}
cp ${CONFIG_PATH}/${CONF_NAME}".ini" debugging/logs/${CONF_NAME}
tar czf debugging/logs/${CONF_NAME}.tgz debugging/logs/${CONF_NAME}
mv debugging/logs/${CONF_NAME}.tgz ../../results
echo -e "DONE - Moving logs to results folder\nEnd of ${0}"
