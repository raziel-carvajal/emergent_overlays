#!/bin/bash -
#===============================================================================
#
#          FILE: wait_for_workers.sh
#
#         USAGE: ./wait_for_workers.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 01/24/2018 12:03
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

shareDir="../../experiments/configs/built_configs"
tasksNoF="${shareDir}/completed_tasks_no"
while :
do
  [ -f ${tasksNoF} ] && break
	echo "Any worker has finished yet, waiting"
	# workers have the highest completition time
	sleep 1
done
echo "at least one worker finised"
while :
do
  totalTasks=`ls -l ${shareDir}/*.ini | wc -l`
	complTasks=`head -1 ${tasksNoF}`
  [ "${totalTasks}" == "${complTasks}" ] && break
	echo "number of tasks is incomplete"
	sleep 1
done
echo "all workers have finished; time to plot all datasts..."
echo "END OF ${0}"
