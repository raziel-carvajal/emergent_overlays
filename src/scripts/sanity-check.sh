#!/bin/bash

COMMANDS=( tar git make gcc g++ opp_run opp_makemake R python )

for C in "${COMMANDS[@]}"; do
   printf "Checking if $C is installed: "
   type ${C} >/dev/null 2>&1 || { echo >&2 "I require ${C}, but it's not installed.  Aborting."; exit 1; }
   printf "Ok\n"
done

#Checking Networkx: python lib for building topologies
echo "import networkx" | python
state=$?
if [ $state -ne 0 ]; then
    echo >&2 "Python.Networkx must be installed build network topologies. Aborting."; exit 1;
fi
print "Ok\n"
