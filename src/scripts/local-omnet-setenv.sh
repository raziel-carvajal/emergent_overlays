#! /bin/sh

if [ $# -ne 1 ]; then
    echo "Wrong number of arguments"
    echo "Usage: $0 PathToOmnet"
    exit 1
fi

if [ ! -d $1 ]; then
    echo "Invalid argument"
    echo "$1 is not a valid directory"
    exit 2
fi

# the path to omnet
OMNET_PATH=$1

#case "$-" in
#*i*) ;;
#*)  echo "Error: not a login shell -- run this script as 'source setenv' or '. setenv'"
#    exit 1
#esac

if [ ! -f "${OMNET_PATH}/configure.user" -o ! -f "${OMNET_PATH}/include/omnetpp.h" ]; then
    echo "Error: ${OMNET_PATH} directory does not look like an OMNeT++ root directory"
    # no exit -- it would close the shell
else
    omnetpp_root=${OMNET_PATH}
    echo "Path to omnetpp: $omnetpp_root"
    export PATH=$omnetpp_root/bin:$PATH
    export LD_LIBRARY_PATH=$omnetpp_root/lib:$LD_LIBRARY_PATH
    export HOSTNAME
    export HOST
fi
