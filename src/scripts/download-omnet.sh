#!/bin/bash

cd ../..

mkdir tools

cd tools

if [ ! -f omnetpp-4.6-src.tgz ]; then 

    wget -S -r -l 1 -U="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1"  https://omnetpp.org/component/jdownloads/download/32-release-older-versions/2290-omnet-4-6-source-ide-tgz -e robots=off


    p=`find . -name 2290-omnet-4-6-source-ide-tgz | grep send`

	echo "Found at $p"

    mv $p omnetpp-4.6-src.tgz
	
	rm -r omnetpp.org

	tar -zxvf omnetpp-4.6-src.tgz
fi

(
cd omnetpp-4.6
source ../../src/scripts/local-omnet-setenv.sh .
./configure
make -j 4
)
