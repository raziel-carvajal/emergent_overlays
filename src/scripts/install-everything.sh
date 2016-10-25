#!/bin/bash

# sort of include files
. utils.sh

# checking that everything is ready to execute the experiments
./sanity-check.sh || error_msg_exit "Stopping the execution because a required application is not installed"

# compile applications' code
./compile_protocols.sh "../protocols" "../../built" || error_msg_exit "Error: problem compiling. Aborting"
