#!/bin/bash

COMMANDS=( tar git make gcc g++ opp_run opp_makemake R Rscript python )

for C in "${COMMANDS[@]}"; do
   printf "Checking if $C is installed: "
   type ${C} >/dev/null 2>&1 || { echo >&2 "I require ${C}, but it's not installed.  Aborting."; exit 1; }
   printf "Ok\n"
done

#Checking Networkx: python lib for building topologies
echo "import networkx" | python
state=$?
if [ $state -ne 0 ]; then
    echo >&2 "Python.Networkx must be installed build network topologies. Aborting.";
    tar -xzvf ../../tools/networkx-1.11.tar.gz -C ../../tools
    exit 1
fi
print "Ok\n"

# installing omnetpp package for R if needed
Rscript checking-depencencies.R
