#!/bin/bash
tx=$1
loB=$2
upB=$3
for (( CNTR=$loB; CNTR<=$upB; CNTR+=1 )); do
  let layoutLen=tx*CNTR
  echo $layoutLen
  python buildTopology.py $tx $layoutLen
done
mv *.ned topologies
