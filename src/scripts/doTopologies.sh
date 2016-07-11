#!/bin/bash

tx=$1
loB=$2
upB=$3
dst=$4

if [ $# -lt 4 ]; then
   echo "Wrong number of parameters"
   echo "Usage: $0 TransmissionRange MinAreaLength MaxAreaLength DirectoryToStoreTopologies"
   exit 1
fi

if [ ! -d $dst ]; then
    echo "Error: $dst is not a valid directory nor a link. It must be the path to the directory where topologies will be kept"
    exit 1
fi


for (( CNTR=$loB; CNTR<=$upB; CNTR+=1 )); do
  let layoutLen=tx*CNTR
  python buildTopology.py $tx $layoutLen
done
mv *.ned $dst
