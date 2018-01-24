#!/bin/bash -
#===============================================================================
#
#          FILE: add_completed_task.sh
#
#         USAGE: ./add_completed_task.sh
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
if ( set -o noclobber ; echo "locked" >> ${lockFile} ) 2> /dev/null ; then
	trap "{ rm -f ${lockFile} ; exit 0 ; }" EXIT
  if [ -f ${destFile} ] ; then
	  let newNo=(`head -1 ${destFile}`)+1
		echo "${newNo}" >${destFile}
  else
	  echo "1" >${destFile}
  fi
	echo "Update of completed tasks: DONE"
else
  echo "Another worker is updating the no of completed tasks"
	exit 1
fi
