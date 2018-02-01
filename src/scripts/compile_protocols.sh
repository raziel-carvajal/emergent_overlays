#!/bin/bash

# configuring path to omnet++
#. download-omnet.sh
. local-omnet-setenv.sh ${OMNET_PATH}

if [ $# -lt 2 ]; then
    echo "Error: wrong number of parameters"
    echo "Usage: $0 PATH_TO_PROTOCOLS OUT_PATH"
    exit 1
fi

if [ ! -d $1 ]; then
    echo "Error: $1 is not a valid directory nor a link. It must be the path to the directory that contains the protocols"
    exit 1
fi

# load the right version of the code
SHA1=`cat ../../revision.txt`
echo "Checking out revision $SHA1"
#./load-proper-version.sh ${SHA1}

OUT_PATH=$2
if [ ! -d ${OUT_PATH} ]; then
    mkdir ${OUT_PATH}
fi

# tool to create makefiles
OMNET_MAKEMAKE=opp_makemake
# make application
MAKE=make

# variables
INCLUDE="${OMNET_PATH}/samples/inet/src"
PROTOCOLS=$1
CORES=3

# create base library that only includes project broadcasting
cd "../base" && ${OMNET_MAKEMAKE} -f --deep -a -I${INCLUDE} -O ${OUT_PATH} -o protocol_base && make MODE=release -j ${CORES}
if [ $? -ne "0" ]; then
  exit 1
fi

# a single makefile with all the protocols. it overwrites the previous makefile. Build a shared library. Include path has a reference to omnet
cd "${PROTOCOLS}" && ${OMNET_MAKEMAKE} -f --deep -s -I${INCLUDE} -I../base -L../base -lprotocol_base -O ${OUT_PATH}
if [ $? -ne "0" ]; then
  exit 1
fi

# build library with all protocols
cd "${PROTOCOLS}" && make MODE=release -j ${CORES}
if [ $? -ne "0" ]; then
  exit 1
fi
