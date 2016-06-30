#!/bin/bash

cd ../..

mkdir tools

cd tools

if [ ! -f omnetpp-4.6-src.tgz ]; then 
  echo "Error: omnet++ is not detected. Download it following this link https://omnetpp.org/component/jdownloads/download/32-release-older-versions/2290-omnet-4-6-source-ide-tgz"
  exit 1
else
  tar -zxvf omnetpp-4.6-src.tgz
  cp configure omnetpp-4.6
  tar -zxvf inet-3.3.0-src.tgz
  mv inet omnetpp-4.6/samples
  cd omnetpp-4.6
  source ../../src/scripts/local-omnet-setenv.sh `pwd`
  ./configure
  make -j 4
  cd samples/inet
  make makefiles
  make -j 4
fi
