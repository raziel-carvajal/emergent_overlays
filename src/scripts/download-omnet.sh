#!/bin/bash

OMNET_PATH=""

install_omnet() {
  mkdir -p ../../tools
  pushd ../../tools
  if [ ! -f omnetpp-4.6-src.tgz ]; then
    echo "Error: omnet++ is not detected. Download it following this link https://omnetpp.org/component/jdownloads/download/32-release-older-versions/2290-omnet-4-6-source-ide-tgz"
    exit 1
  else
    tar -zxf omnetpp-4.6-src.tgz
    cp configure omnetpp-4.6
    tar -zxf inet-3.3.0-src.tgz
    mv inet omnetpp-4.6/samples
    cd omnetpp-4.6
    source ../../src/scripts/local-omnet-setenv.sh `pwd`
    ./configure NO_TCL=0 && make -j 4 && cd samples/inet && make makefiles && make -j 4 && echo "happy"
  fi
  popd
}

make_sure_that_omnet_is_installed() {
  # check if we have a path for omnet
  if [ ! -f "omnet.config" ]; then
    install_omnet
  fi
  OMNET_PATH="../../tools/omnetpp-4.6"
}

make_sure_that_omnet_is_installed
