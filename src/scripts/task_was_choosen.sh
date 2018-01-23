#!/bin/bash - 
#===============================================================================
#
#          FILE: task_was_choosen.sh
# 
#         USAGE: ./task_was_choosen.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION: 
#       CREATED: 01/23/2018 16:34
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

shareDir=${1}
lockFile="${shareDir}/choosing_task.lock"
tasks="${shareDir}/${2}"
if ( set -o noclobber ; touch ${lockFile} ) 2>/dev/null ; then
	echo "Lock taken!"
	trap "{ rm -f ${lockFile}; exit 0; }" EXIT
	MY_TASK=`head -1 ${tasks}`
	echo "${MY_TASK}" >my_task
  echo "Worker [${HOSTNAME}]: I've chosen task [${MY_TASK}]"
	let others=(`cat ${tasks} | wc -l`)-1
	todo=`tail -${others} ${tasks}`
	rm -f ${tasks}
	echo -e "${todo}" >${tasks}
	echo "Lock was released!"
else
  echo "Lock failed!"
	exit 1
fi
