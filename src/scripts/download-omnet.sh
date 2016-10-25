#!/bin/bash

install_omnet() {
  mkdir -p ../../tools
  cd ../../tools

  echo "caraajooooo"

  if [ ! -f omnetpp-4.6-src.tgz ]; then
    echo "Error: omnet++ is not detected. Download it following this link https://omnetpp.org/component/jdownloads/download/32-release-older-versions/2290-omnet-4-6-source-ide-tgz"
    exit 1
  else
    echo "la mierda 1"
    tar -zxf omnetpp-4.6-src.tgz
    echo "la mierda 2"
    cp configure omnetpp-4.6 2 > /dev/null
    tar -zxf inet-3.3.0-src.tgz
    mv inet omnetpp-4.6/samples > /dev/null
    cd omnetpp-4.6
    source ../../src/scripts/local-omnet-setenv.sh `pwd`
    ./configure NO_TCL=0 && make -j 4 && cd samples/inet && make makefiles && make -j 4
  fi
}

make_sure_that_omnet_is_installed() {
  # check if we have a path for omnet
  echo "caraajooooo 2222"
  if [ ! -f "omnet.config" ]; then
          echo "caraajooooo 11111"
          install_omnet
          local myresult=../../tools/omnetpp-4.6
  else
          local myresult=`cat omnet.config`
  fi
  echo "${myresult}"
}
