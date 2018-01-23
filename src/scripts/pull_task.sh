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
	[ -f "${shareDir}/${taskList}" ] && break
	echo "Waiting until the list of task is ready!"
  sleep 1
done
echo "list of tasks for workers is ready"
while :
do
  ./task_was_choosen.sh ${shareDir} ${taskList} && break
	echo "waiting until lock is released"
	sleep 1
done
MY_TASK=`head -1 my_task`
./run-one-configuration.sh "../../experiments/configs/built_configs/${MY_TASK}" \
  ../../tools/omnetpp-4.6/samples/inet 0
echo "END OF ${0}"
