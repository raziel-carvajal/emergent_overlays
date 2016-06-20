#!/bin/bash

if [ $# -lt 2 ]; then
   echo "Wrong number of parameters"
   echo "Usage: $0 ConfigurationFile ConfigurationName"
   exit 1
fi

# a file *.ini
CONF_FILE=$1

# one of the configurations in that file
CONF_NAME=$2 

# executable omnet
OMNET=opp_run

# path to inet library. Observe the string INET at the end
LIBRARY_PATH=../../out/gcc-debug/src/INET

# specify my ned path. set of path where I can find ned files
LOCAL_NEDPATH=../../examples:../../src:..

${OMNET} -u Cmdenv -r 0 -n ${LOCAL_NEDPATH} -l ${LIBRARY_PATH} -c ${CONF_NAME} -f ${CONF_FILE}
