#!/bin/bash -
#===============================================================================
#
#          FILE: pull_task.sh
#
#         USAGE: ./pull_task.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 01/23/2018 16:25
#      REVISION:  ---
#===============================================================================

shareDir="../../experiments/configs/built_configs"
taskList="cfgs_for_workers"

while :
do
  curl trace_generator/alive
  [ ${?} == 0 ] && break
  echo "Wait until ini-f-d is ready..."
  sleep 1
done
echo "ini-f-d is UP !"

# chose one task
MY_TASK=`curl trace_generator/ini_file`
echo "Chosen task: ${MY_TASK}"
[ ${MY_TASK} == "" ] && echo "No more task. End of ${0}" && exit 0

# ./run-one-configuration.sh "../../experiments/configs/built_configs/${MY_TASK}" \
#   ../../tools/omnetpp-4.6/samples/inet 0
# [ ${?} != 0 ] && \
# 	echo -e "Error during execution of [${MY_TASK}]\nEND OF ${0}" && \
# 	exit 1
#
# # tell the plotter that this worker complete only ONE more task
# while :
# do
#   ./add_completed_task.sh ${shareDir} && break
# 	echo "waiting until completed_tasks.lock is released"
# 	sleep 1
# done
echo "END OF ${0}"
