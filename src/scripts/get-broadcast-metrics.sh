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
# [BEGIN] Comment to perform unit test
while :
do
  CONF_FILE=`curl trace_generator/dataset_to_plot`
  [ "${CONF_FILE}" != "" ] && break
  echo "No dataset to plot, wait and ask later..."
  sleep 5
done
# [END] Comment to perform unit test
# TODO uncomment to perform unit tests
# CONF_FILE=${1}
echo "Getting broadcast metrics from configuration: ${CONF_FILE}"
if [ ! -f "${CONF_FILE}" ]; then
 echo "Error: configuration file ${CONF_FILE} doesn't exist"
 exit 1
fi

filename=$(basename "${CONF_FILE}")
CONF_NAME=${filename%.*}

simTime=`grep "sim-time-limit" ${CONF_FILE} | awk -F " = " '{print $2}' | grep -Eo '[0-9]{1,5}'`

broaInt=`grep "broadcastInterval" ${CONF_FILE} | awk -F " = " '{print $2}' | awk -F "s" '{print $1}' | grep -Eo '[0-9]{0,5}.[0-9]{0,5}'`

tx=`grep "maxCommunicationRange" ${CONF_FILE} | awk -F " = " '{print $2}' | grep -Eo '[0-9]{1,5}'`

denseZoneCenterAtX=`grep "centerDensAx" ${CONF_FILE} | awk -F " = " '{print $2}' | grep -Eo '[0-9]{0,5}.[0-9]{0,5}'`
denseZoneCenterAtY=`grep "centerDensAy" ${CONF_FILE} | awk -F " = " '{print $2}' | grep -Eo '[0-9]{0,5}.[0-9]{0,5}'`

denseZoneWidth=`grep "denseAreaWid" ${CONF_FILE} | awk -F " = " '{print $2}' | grep -Eo '[0-9]{0,5}.[0-9]{0,5}'`
denseZoneLengt=`grep "denseAreaLen" ${CONF_FILE} | awk -F " = " '{print $2}' | grep -Eo '[0-9]{0,5}.[0-9]{0,5}'`

firstAtDenseZone=`grep "firstAtDense" ${CONF_FILE} | awk -F " = " '{print $2}' | grep -Eo '[0-9]{0,5}'`

mobilityModel=`grep "mobilityType" ${CONF_FILE}`
if [[ "${mobilityModel}" != "" ]]; then
	withMobility="--with-mobility"
else
	withMobility=""
fi

echo "Details of experiment [${CONF_NAME}]"
echo -e "\tSimulation time: ${simTime}"
echo -e "\tBroadcast message interval: ${broaInt}"
echo -e "\tNodes transmission range: ${tx}"
echo -e "\tCenter of dense zone: (${denseZoneCenterAtX}, ${denseZoneCenterAtY})"
echo -e "\tDimensions: ${denseZoneWidth} x ${denseZoneLengt}"
echo -e "\tExperiment with mobility: ${withMobility}"

Rscript get-broadcast-metrics.R \
  --simulation-time ${simTime} \
  --transmission-range ${tx} \
  --dense-zone-at-x ${denseZoneCenterAtX} \
  --dense-zone-at-y ${denseZoneCenterAtY} \
  --dense-zone-w ${denseZoneWidth} \
	--dense-zone-l ${denseZoneLengt} \
	--fist-at-dense ${firstAtDenseZone} \
  --results-dir ../../results \
	--with-metrics-over-time \
	${withMobility} ${CONF_NAME} ${CONF_FILE}
	# --with-energy-consumption \
	# --with-coverage \
	# --with-plotting \
	# --with-observables \
	# --with-sent-msgs \
	# --with-recv-msgs \

echo "Moving built graphs..."
# rm -fr ${CONF_NAME}
# mkdir ${CONF_NAME}
# mkdir ${CONF_NAME}/dataset
# mv *.pdf ${CONF_NAME}/
# cp ${CONF_FILE} ${CONF_NAME}/
# mv ../../experiments/configs/built_configs/results/${CONF_NAME}-*  ${CONF_NAME}/dataset
# tar czf ${CONF_NAME}.tgz ${CONF_NAME}/
# mv ${CONF_NAME}.tgz ../../results

echo "Announce that the datasets are ready for plotting..."
curl -X POST trace_generator/completed_task
[ ${?} != 0 ] && echo "/!\ End of task ${CONF_FILE} wasn't announced"

echo -e "Done - Find distributions of broadcast metrics at ../../results \nEnd of ${0}"
