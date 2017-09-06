#!/bin/bash - 
#===============================================================================
#
#          FILE: create-asc-node-id.sh
# 
#         USAGE: ./create-asc-node-id.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 09/06/2017 16:38
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

getLine ()
{
	content=`head -${1} ${2} | tail -1`
	return 0
}	# ----------  end of function getLine  ----------


if [ ${#} -lt 1 ] ; then
	echo "USAGE: ${0} NED_FILE"
	exit 1
fi
if [ ! -f ${1} ] ; then
	echo "Topology file doesn't exist"
	exit 1
fi
firstTop=${1}
rm -fr tmp; grep -n hostR ${firstTop} >tmp
nodesNo=`cat tmp | wc -l`
if [ ${nodesNo} -gt 0 ] ; then
	rm -fr output; touch output
	#get header of initial NED file
	getLine 1 tmp
	lineNo=`echo ${content} | awk '{print $1}' | grep -Eo '[0-9]{1,5}'`
	let lineNo=lineNo-1
	head -${lineNo} ${firstTop} >>output
	#add nodes with their ID in ascendent way
	for (( i=1; i<=${nodesNo}; i+=1 )); do
		getLine ${i} tmp
		lineNo=`echo ${content} | awk '{print $1}' | grep -Eo '[0-9]{1,5}'`
		let nextLineNo=lineNo+1
		getLine ${nextLineNo} ${firstTop}
		strToAdd="hostR${i}: CenterHost { ${content} }"
		echo ${strToAdd} >>output
	done
	#add EOF
	echo "}" >>output
else
	echo -e "NED_FILE (${1}) doesn't look like a NED file.\nAborting..."
	exit 1
fi
echo "END of ${0}"
