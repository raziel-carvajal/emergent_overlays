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
echo -e "Correct execution of ${CONF_NAME}\nEnd of ${0}"
