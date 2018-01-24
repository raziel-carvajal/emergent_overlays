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

# wait until trace_generator create configuration files
while :
do
	[ -f "${shareDir}/${taskList}" ] && break
	echo "Waiting until the list of task is ready!"
  sleep 1
done
echo "list of tasks for workers is ready"

# chose ONE task for the current worker
while :
do
  ./was_task_choosen.sh ${shareDir} ${taskList} && break
	echo "waiting until lock is released"
	sleep 1
done

[ ! -f "my_task" ] && echo "END OF ${0}" && exit 1

MY_TASK=`head -1 my_task`
./run-one-configuration.sh "../../experiments/configs/built_configs/${MY_TASK}" \
  ../../tools/omnetpp-4.6/samples/inet 0
[ ${?} != 0 ] && \
	echo -e "Error during execution of [${MY_TASK}]\nEND OF ${0}" && \
	exit 1

# tell the plotter that this worker complete only ONE more task
while :
do
  ./add_completed_task.sh ${shareDir} && break
	echo "waiting until completed_tasks.lock is released"
	sleep 1
done
echo "END OF ${0}"
