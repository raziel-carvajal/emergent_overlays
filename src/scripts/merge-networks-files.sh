#!/bin/bash - 
#===============================================================================
#
#          FILE: merge-networks-files.sh
# 
#         USAGE: ./merge-networks-files.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 09/07/2017 23:14
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
EOS=`echo "END of ${0}"`
getLine ()
{
	content=`head -${1} ${2} | tail -1`
	return 0
}	# ----------  end of function getLine  ----------

if [ ${#} -lt 3 ] ; then
	echo -e "USAGE: ${0} SPARSE_NET DENSE_NET INC_X.\n${EOS}"; exit 1
fi
if [ ! -f ${1} ] ; then
	echo -e "File with sparse network doesn't exist.\n${EOS}"; exit 1
fi
if [ ! -f ${2} ] ; then
	echo -e "File with dense network doesn't exist.\n${EOS}"; exit 1
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
	seconTop=${2}
	incInX=${3}
	grep hostR ${seconTop} >tmp
	nodesf2=`cat tmp | wc -l`
	if [ ${nodesf2} -gt 0 ] ; then
		for (( j=0; j<${nodesf2}; j+=1 )); do
			getLine $((${j} + 1)) tmp
			headL=`echo ${content} | awk -F "p=" '{print $1}'`
			restL=`echo ${content} | awk -F "p=" '{print $2}'`
			poInX=`echo ${restL} | awk -F "," '{print $1}' \
							| grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
			poInY=`echo ${restL} | awk -F "," '{print $2}' \
							| grep -Eo '[0-9]{1,5}.[0-9]{1,5}'`
			poInX=$(bc <<< "${poInX}+${incInX}")
			poInY=$(bc <<< "${poInY}+${incInX}")
			let nextId=i+j
			strToAdd="hostR${nextId}:`echo ${headL} | awk -F ":" '{print $2}'`"
			strToAdd="${strToAdd}p=${poInX},${poInY}"'"'"); }"
			echo ${strToAdd} >>output
		done
	else
		echo "Second NET file (${2}) doesn't contain any host."
		echo -e "Just sparse area will be present in final NED file."
	fi
	#add EOF
	echo "}" >>output
else
	echo -e "NED_FILE (${1}) doesn't look like a NED file.\nAborting..."
	exit 1
fi
echo "${EOS}"
