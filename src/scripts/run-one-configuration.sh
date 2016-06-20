#!/bin/bash

if [ $# -lt 4 ]; then
   echo "Wrong number of parameters"
   echo "Usage: $0 ConfigurationFile ConfigurationName InetPath ProtocolsLibraryPath"
   exit 1
fi

# a file *.ini
CONF_FILE=$1

if [ ! -f "${CONF_FILE}" ]; then
   echo "Error: configuration file ${CONF_FILE} doesn't exists"
   exit 1
fi

# one of the configurations in that file
CONF_NAME=$2 

# executable omnet
OMNET=opp_run

# path to inet
INET_PATH=$3

# path to inet library. Observe the string INET at the end
INET_LIBRARY_PATH=${INET_PATH}/out/gcc-debug/src/INET

# path to library with protocols
PROTOCOLS_LIBRARY=$4

# specify my ned path. set of path where I can find ned files
LOCAL_NEDPATH=${INET_PATH}/examples:${INET_PATH}/src:../../experiments/networks:../protocols/


${OMNET} -u Cmdenv -r 0 -n ${LOCAL_NEDPATH} -l ${INET_LIBRARY_PATH} -l ${PROTOCOLS_LIBRARY} -c ${CONF_NAME} -f ${CONF_FILE}
