#!/bin/bash

# sort of include files
. utils.sh

echo "puta 1"

# checking that everything is ready to execute the experiments
./sanity-check.sh # || error_msg_exit "Stopping the execution because a required application is not installed"

echo "puta 2"

# compile applications' code
#./compile_protocols.sh "../protocols" "../../built" # || error_msg_exit "Error: problem compiling. Aborting"
