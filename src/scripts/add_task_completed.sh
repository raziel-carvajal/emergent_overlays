#!/bin/bash - 
#===============================================================================
#
#          FILE: add_task_completed.sh
# 
#         USAGE: ./add_task_completed.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION: 
#       CREATED: 01/24/2018 11:21
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
lockFile="${1}/completed_tasks.lock"
destFile="${1}/completed_tasks_no"
if ( set -o noclobber ; echo "locked" > ${lockFile} ) 2> /dev/null ; then
	trap "{ rm -fr ${lockFile} ; exit 0 }" EXIT
  if [ -f ${destFile} ] ; then
	  let newNo=(`head -1 ${destFile}`)+1
		echo "${newNo}" >${dstFile}
  else
	  echo "1" >${dstFile}
  fi
	echo "Update of completed tasks: DONE"
else
  echo "Another worker is updating the no of completed tasks"
	exit 1
fi
