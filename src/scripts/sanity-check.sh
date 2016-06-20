#!/bin/bash

COMMANDS=( git make gcc g++ opp_run R )

for C in "${COMMANDS[@]}"; do
   printf "Checking if $C is installed: "
   type ${C} >/dev/null 2>&1 || { echo >&2 "I require ${C}, but it's not installed.  Aborting."; exit 1; }
   printf "Ok\n"
done
