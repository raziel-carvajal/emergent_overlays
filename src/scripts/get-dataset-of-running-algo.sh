#!/bin/bash - 
#===============================================================================
#
#          FILE: get-dataset-of-running-algo.sh
# 
#         USAGE: ./get-dataset-of-running-algo.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@gmail.com
#  ORGANIZATION: 
#       CREATED: 09/11/2017 10:15
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
EOS="END OF ${0}"
if [ ${#} -lt 2 ] ; then
	echo -e "USAGE: ${0} DIR_OF_INI_FILES FILE_NAMES\n${EOS}"; exit 0
fi
dire=${1}
cfgF=${2}
if [ ! -d ${dire} ] ; then
	echo -e "Directory of INI files doesn't exist\n${EOS}"; exit 0
fi
tmp=`dirname ${dire}`"/"`basename ${dire}`; dire=${tmp}
if [ ! -f ${cfgF} ] ; then
	echo -e "Descriptor with list of INI files doesn't exist\n${EOS}"; exit 0
fi
outF="algorithmTypeDistribution"; rm -fr ${outF}; touch ${outF}
for iniFile in `cat ${cfgF}` ; do
	if [ ! -f "${dire}/${iniFile}.ini" ]; then
		echo -e "File ${dire}/${iniFile}.ini doesn't exist, no way to get its content"
	else
    nodesNo=`echo ${iniFile} | awk -F "_" '{print $2}'`
    algo=`echo ${iniFile} | awk -F "_" '{print $12}'`
	  echo "\"${iniFile}\"" >>${outF}
	  if [ "${algo}" == "hybrid" ] ; then
	  	grep "initialProtocol" "${dire}/${iniFile}.ini" >tmp
	  	for l in `cat tmp`; do
	  		algoInN=`echo ${l} | awk -F '"' '{print $2}' | awk -F "[0-9]" '{print $1}' \
					| awk -F "_" '{print $1}' | awk '{print toupper($0)}'`
	  		echo "\"${algoInN}\"" >>${outF}
	  	done
	  else
			algo=`echo ${algo} | awk '{print toupper($0)}'`
	  	for (( i=0; i<${nodesNo}; i+=1 )); do
	  		echo "\"${algo}\"" >>${outF}
	  	done
	  fi
	fi
done
mv ${outF} ../../results; rm -fr tmp; echo ${EOS}
