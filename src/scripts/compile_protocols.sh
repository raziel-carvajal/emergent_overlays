#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Error: wrong number of parameters"
    echo "Usage: $0 PATH_TO_PROTOCOLS PATH_TO_INET OUT_PATH"
    exit 1
fi

if [ ! -d $2 ]; then
    echo "Error: $2 is not a valid directory nor a link. It must be the path to omnet++/inet"
    exit 1
fi

if [ ! -d $1 ]; then
    echo "Error: $1 is not a valid directory nor a link. It must be the path to the directory that contains the protocols"
    exit 1
fi

OUT_PATH=$3

if [ ! -d ${OUT_PATH} ]; then
    mkdir ${OUT_PATH}
fi

# tool to creata makefiles
OMNET_MAKEMAKE=opp_makemake
# make application
MAKE=make

# variables
INCLUDE=$2/src
PROTOCOLS=$1

# create base library that only includes project broadcasting
cd "../base" && ${OMNET_MAKEMAKE} -f --deep -a -I${INCLUDE} -O ${OUT_PATH} -o protocol_base

cd "../base" && make 

# a single makefile with all the protocols. it overwrite the previous makefile. Build a shared library. Include path has a reference to omnet
cd "${PROTOCOLS}" && ${OMNET_MAKEMAKE} -f --deep -s -I${INCLUDE} -I../base -L../base -lprotocol_base -O ${OUT_PATH}

# build library with all protocols
cd "${PROTOCOLS}" && make
