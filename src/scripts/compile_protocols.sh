#!/bin/bash

if [ ${#} -ne 2 ]; then
  echo "Error: Wrong number of arguments"
  echo "Usage: ${0} <omnet-path> <omnet-project-root-dir>"
  exit 1
fi

if [ ! -d ${1} ]; then
  echo "Invalid argument"
  echo "${1} isn't a directory"
  exit 1
fi

if [ ! -d ${2} ]; then
  echo "Invalid argument"
  echo "${2} isnt a directory"
  exit 1
fi

OMNET_PATH=${1}
PROJECT=${2}
INET="${OMNET_PATH}/samples/inet/src"
if [ ! -f "${OMNET_PATH}/configure.user" -o ! -f "${OMNET_PATH}/include/omnetpp.h" ]; then
  echo "Error: ${OMNET_PATH} directory does not look like an OMNeT++ root directory"
  exit 1
fi

cd ${PROJECT_SRC}
opp_makemake -I${INET} -I${PROJECT_SRC}/src -P ${PROJECT_SRC} --no-deep-includes -f --deep -s -o emergent_overlays
make -j 4

if [[ ${?} != 0 ]]; then
  echo "Error: during the compilation of emergent_overlays project"
  exit 1
fi
cd ${here}
