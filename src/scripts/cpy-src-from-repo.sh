#!/bin/bash - 
#===============================================================================
#
#          FILE: cpy-src-from-repo.sh
# 
#         USAGE: ./cpy-src-from-repo.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (RCG), raziel.carvajal@unine.ch
#  ORGANIZATION: 
#       CREATED: ---
#      REVISION: ---
#===============================================================================
set -o nounset                              # Treat unset variables as an error
copyFiles () {
  subDirList=${1}
  opt=${2}
  if [ "${opt}" == "BASE" ] ; then
    echo "Copying from BASE directory to IDE"
    src="${BASE_DIR}"
  else
    echo "Copying from ALGO directory to IDE"
    src="${ALGO_DIR}"
  fi
  for subDir in `echo -e ${subDirList}` ; do
    currentDir=${src}/${subDir}
    if [ -d ${currentDir} ]; then
      for f in `ls ${currentDir}` ; do
        echo "Dealing with file: ${f}"
        # Avoid copying auto-generated files from *_m.cc and *_m.h
        x=`echo ${f} | awk -F "_m" '{print $2}'`
        if [ "${x}" == "" ]; then
          if [ "`echo ${f} | awk -F "EnergyAwareIdealRadio" '{print $1}'`" == "" ]; then
            echo "Avoiding file ${f}"
          else
            echo "Copying file ${currentDir}/${f} to ${DST_DIR}/${subDir}"
            cp ${currentDir}/${f} ${DST_DIR}/${subDir}
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
  echo -e "USAGE: ${0} ROOT_DIR_FROM_IDE \nEND of ${0}"; exit 1
fi
if [ ! -d ${1} ]; then
  echo -e "ERROR: directory ${1} does not exist.\nEND of ${0}"; exit 1
fi
DST_DIR="`dirname ${1}`/`basename ${1}`"

baseC="broadcasting\nstoredmobility"
copyFiles ${baseC} "BASE"
algos="abba2\nadaptive-local\nadaptive-swsp\ncds3\nflooding\nfullyAdaptive\nmiddleAll"
algos="${algos}\nmiddleFix\nmiddleNone\nmiddleOpt\nmprt2\nprobflood"
copyFiles ${algos} "ALGO"

echo "END of ${0}"
