#!/bin/bash

# sort of include files
. utils.sh

# the configuration to use
CONFIG_PATH=../../experiments/configs/builtConfigs/
MINIMUM_DENSITY=5
MAXIMUM_DENSITY=15
ALGORITHMS=()

usage() {
  echo "Usage $0: [-d DENSITY1] [-D DENSITY2] [-p PATH] [-a ALGORITHM]*"
  echo ""
  echo -e "\tDENSITY1: minimum density to consider (5 by default)\n"
  echo -e "\tDENSITY2: maximum density to consider (15 by default)\n"
  echo -e "\tPATH: used to located the configurations (../../experiments/configs/builtConfigs/ by default)\n"
  echo -e "\tALGORITHM: an algorithm to consider\n"
}


# parsing parameters
while getopts "d:D:p:a:h" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    d)
      MINIMUM_DENSITY=$OPTARG
      ;;
    D)
      MAXIMUM_DENSITY=$OPTARG
      ;;
    p)
      CONFIG_PATH=$OPTARG
      ;;
    a)
      ALGORITHMS+=($OPTARG)
      ;;
    \?)
      exit 1
      ;;
  esac
done

[ "${#ALGORITHMS[@]}" -eq "0" ] && echo "Ok, since there is no algorithm selected, we are done, bye!!!" && exit 0

# configuring path to omnet++
. download-omnet.sh
. local-omnet-setenv.sh ${OMNET_PATH}

# prepare result directory
if [ ! -d "../../results" ]; then
    mkdir ../../results
fi
rm -f ../../results/broadcastSession* \
      ../../results/duplicatedMsgs* \
      ../../results/batteryConsumption* \
      ../../results/networkCoverage* \
      ../../results/relays* \
      ../../results/coverage* \
      ../../results/*.pdf \
      ../../results/summary.csv

echo "Simulating"

for c in ${CONFIG_PATH}*.ini ; do
	filename=$(basename "$c")
  my_substring="_forCol"
  if [[ ! "$filename" =~ "$my_substring" ]]; then
  	config_name="${filename%.*}"
    nodes=$(get_nrnodes_from_config_name $config_name)
    density=$(get_density_from_config_name $config_name)
    protocol=$(get_protocol_from_config_name $config_name)
    if [ "${density}" -ge "${MINIMUM_DENSITY}" ] && [ "${density}" -le "${MAXIMUM_DENSITY}" ]; then
      array_contains "$protocol" "${ALGORITHMS[@]}"
      if [ $? -eq 0 ]; then
        echo "This is one ${config_name}  ${nodes} ${density} ${protocol}"
        sem -j-1 --no-notice ./run-one-configuration.sh ${c} ${OMNET_PATH}/samples/inet 0
      fi
    fi
  fi

done

sem --wait --no-notice

echo "Creating aggregated results"

cat ../../results/broadcastSession-n_* >> ../../results/broadcastSession
cat ../../results/duplicatedMsgsDistribution-n_* >> ../../results/duplicatedMsgsDistribution
cat ../../results/batteryConsumptionDistribution-n_* >> ../../results/batteryConsumptionDistribution
cat ../../results/batteryConsumptionDistributionTime-n_* >> ../../results/batteryConsumptionDistributionTime
cat ../../results/relays-n_* >> ../../results/relays
cat ../../results/coverage-n_* >> ../../results/coverage

rm -f ../../results/broadcastSession-n_* \
      ../../results/duplicatedMsgsDistribution-n_* \
      ../../results/batteryConsumptionDistribution-n_* \
      ../../results/batteryConsumptionDistributionTime-n_* \
      ../../results/relays-n_* \
      ../../results/coverage-n_*

# Rscript import-data.R ../../results/ batteryConsumptionDistribution duplicatedMsgsDistribution broadcastSession

echo "Plotting aggregated results"

Rscript pretty-plotting.R \
      -pc batteryConsumptionDistribution \
      -dm duplicatedMsgsDistribution \
      -bs broadcastSession \
      -rf relays \
      -cv coverage \
      -sf summary.csv \
      ../../results/
