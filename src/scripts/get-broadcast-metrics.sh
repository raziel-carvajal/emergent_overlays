#!/bin/bash -
#===============================================================================
#
#          FILE: get-broadcast-metrics.sh
#
#         USAGE: ./get-broadcast-metrics.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 10/22/2018 14:58
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
while :
do
  CONF_FILE=`curl trace_generator/dataset_to_plot`
  [ "${CONF_FILE}" != "" ] && break
  echo "No dataset to plot, wait and ask later..."
  sleep 5
done
echo "Getting broadcast metrics from configuration: ${CONF_FILE}"
if [ ! -f "${CONF_FILE}" ]; then
 echo "Error: configuration file ${CONF_FILE} doesn't exist"
 exit 1
fi

filename=$(basename "${CONF_FILE}")
CONF_NAME=${filename%.*}

simTime=`grep "sim-time-limit" ${CONF_FILE} | awk -F " = " '{print $2}' | grep -Eo '[0-9]{1,5}'`

broaInt=`grep "sendInterval" ${CONF_FILE} | awk -F "uniform" '{print $2}' | awk -F "(" '{print $2}' | awk -F ")" '{print $1}'`
broaT0=`echo ${broaInt} | awk -F "," '{print $1}' | awk -F "s" '{print $1}' | grep -Eo '[0-9]{0,5}.[0-9]{0,5}'`
broaT1=`echo ${broaInt} | awk -F ", " '{print $2}' | awk -F "s" '{print $1}' | grep -Eo '[0-9]{0,5}.[0-9]{0,5}'`

tx=`grep "maxCommunicationRange" ${CONF_FILE} | awk -F " = " '{print $2}' | grep -Eo '[0-9]{1,5}'`

echo "Details of experiment [${CONF_NAME}]"
echo -e "\tSimulation time: ${simTime}"
echo -e "\tBroadcast message interval: ${broaInt}"
echo -e "\tNodes transmission range: ${tx}"

Rscript get-broadcast-metrics.R \
  --simulation-time ${simTime} \
  --broadcast-interval-lim-inf ${broaT0} \
  --broadcast-interval-lim-sup ${broaT1} \
  --transmission-range ${tx} \
  --results-dir ../../results \
  ${CONF_NAME} ${CONF_FILE}

echo "Moving built graphs..."
rm -fr ${CONF_NAME}
mkdir -p ${CONF_NAME}
mv *.pdf ${CONF_NAME}/
cp ${CONF_FILE} ${CONF_NAME}/
tar czf ${CONF_NAME}.tgz ${CONF_NAME}/
mv ${CONF_NAME}.tgz ../../results
echo -e "Done - Find distributions of broadcast metrics at ../../results\nEnd of ${0}"
