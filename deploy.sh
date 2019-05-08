#!/bin/bash -
#===============================================================================
#
#          FILE: deploy.sh
#
#         USAGE: ./deploy.sh <docker-compose-version> <workers-number>
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Raziel Carvajal-Gomez (), raziel.carvajal@uclouvain.be
#  ORGANIZATION:
#       CREATED: 07/24/2018 16:30
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
[[ ${#} != 2 ]] && \
	echo -e "USAGE: ${0} <docker-compose-version> <workers-number>\nEnd of ${0}" && \
	exit 1

version=`echo ${1} | grep -Eo '[0-9]{1,5}'`
[[ ${?} != 0 ]] && \
	echo -e "ERROR: docker-compose version must be an integer.\nEnd of ${0}" && \
	exit 1
[[ ${version} -lt 9 ]] && \
	echo -e "ERROR: docker-compose version must be at least 9.\nEnd of ${0}" && \
	exit 1

workers=`echo ${2} | grep -Eo '[0-9]{1,5}'`
[[ ${?} != 0 ]] && \
	echo -e "ERROR: number of workers must be an integer.\nEnd of ${0}" && \
	exit 1

if [[ ${version} -gt 20 ]]; then
	docker-compose down && \
		docker-compose build && \
		docker-compose up -d --scale worker=${workers} --scale dist_generator=${workers}
	result=${?}
else
	sudo docker-compose down && sudo docker-compose build && \
		sudo docker network create emergentoverlays_default && \
		sudo docker-compose scale worker=${workers} dist_generator=${workers} \
			trace_generator=1 plotter=1
	result=${?}
fi
[[ ${result} != 0 ]] && \
	echo -e "ERROR: during the deployment with docker-compose.\n End of ${0}" && \
	exit 1
echo "DONE. Successful execution of ${0}."
