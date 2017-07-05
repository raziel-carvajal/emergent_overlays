#!/bin/bash - 
#===============================================================================
#
#          FILE: cpy-src-from-ide.sh
# 
#         USAGE: ./cpy-src-from-ide.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: 04/25/2017 11:52
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
copyFiles () {
  subDirList=${1}
  dst=${2}
  for subDir in `echo -e ${subDirList}` ; do
    currentDir=${SRC_DIR}/${subDir}
    if [ -d ${currentDir} ]; then
      for f in `ls ${currentDir}` ; do
        echo "dealing with file: ${f}"
        # Avoid copying auto-generated files from *.msg and *.ned 
        x=`echo ${f} | awk -F "_m" '{print $2}'`
        if [ "${x}" == "" ]; then
          if [ "`echo ${f} | awk -F "EnergyAwareIdealRadio" '{print $1}'`" == "" ]; then
            echo "Avoiding EnergyAwareIdealRadio.cc"
          else
            if [ "${dst}" == "BASE" ] ; then
              echo "DOING: cp ${currentDir}/${f} ${BASE_DIR}/${subDir}"
              cp ${currentDir}/${f} ${BASE_DIR}/${subDir}
            else
              echo "DOING: cp ${currentDir}/${f} ${ALGO_DIR}/${subDir}"
              cp ${currentDir}/${f} ${ALGO_DIR}/${subDir}
            fi
          fi
        fi
      done
    else
      echo "Ignoring files on ${subDir} because the directory does not exist in ${SRC_DIR}"
    fi
  done
}

BASE_DIR="../base"
ALGO_DIR="../protocols"

if [ $# -lt 1 ]; then
  echo -e "USAGE: ${0} DIR_OF_SOURCES \nEND of ${0}"
  exit 1
fi
if [ ! -d ${1} ]; then
  echo -e "ERROR: directory ${1} does not exist.\nEND of ${0}"
  exit 1
fi
SRC_DIR="`dirname ${1}`/`basename ${1}`"

# source files from the every directory in ${baseC} & ${algos}
baseC="broadcasting\nstoredmobility"
copyFiles ${baseC} "BASE"
algos="abba2\nadaptive-local\nadaptive-swsp\ncds3\nflooding\nfullyAdaptive\nmiddleAll"
algos="${algos}\nmiddleFix\nmiddleNone\nmiddleOpt\nmprt2\nprobflood"
copyFiles ${algos} "ALGO"

echo "END of ${0}"
