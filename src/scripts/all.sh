#!/bin/bash

# sort of include files
. utils.sh

# install all dependencies
. install-everything.sh || error_msg_exit "Error configuring the framework"

CONFIG_PATH=../../experiments/configs/builtConfigs
#INFO: alternative way to lunch experiments
expeCnf="../../experiments/configs/experimet.cnf"
if [ ! -f ${expeCnf} ] ;then
  echo -e "The configuration of the experiment is not defined\n"
  exit 1
fi

echo "Launching experiment with this configuration:"
cat ${expeCnf}

expeN=`cat ${expeCnf} |head -3 |tail -1| awk -F ":" '{print $2}'`
resuD="../../results/${expeN}"
if [ -d ${resuD} ] ; then
  echo -e "There are already results for experiment ${expeN} at ${resuD}\n"
  exit 1
fi

mkdir ${resuD}
mkdir "${resuD}/tmp"
echo "CLEANING OLD RESULTS..."

rm -fr ../../results/batteryConsumptionDistribution-*
rm -fr ../../results/broadcastSession-*
rm -fr ../../results/duplicatedMsgsDistribution-*

rm -fr ../../results/sentMsgs_*
rm -fr ../../results/rcvdMsgs_*
rm -fr ../../results/networkCoverage_*
rm -fr ../../results/IndividualPlots-* 
rm -fr ../../results/collisions_*
rm -fr ../../results/graphConnectivity_*
rm -fr ../../results/batteryConsumption_*
rm -fr ../../results/numberOfRelays_*
rm -fr ../../results/duplicatedMsgs_*
rm -fr ../../results/broadcastSessionTime_*
echo -e "\tDONE"

algos=`cat ${expeCnf} |head -1 |tail -1| awk -F ":" '{print $2}'`
dSpar=`cat ${expeCnf} |head -2 |tail -1| awk -F ":" '{print $2}'| awk -F "_" '{print $1}'`
dMedi=`cat ${expeCnf} |head -2 |tail -1| awk -F ":" '{print $2}'| awk -F "_" '{print $2}'`
dDens=`cat ${expeCnf} |head -2 |tail -1| awk -F ":" '{print $2}'| awk -F "_" '{print $3}'`
echo -e "${dSpar} sparse\n${dMedi} medium\n${dDens} dense" >densities

coCnf=`ls ${CONFIG_PATH}/*_forCol.ini| wc -l`
if [ ${coCnf} -lt 1 ]; then
  $(error_msg_exit "Configurations files to compute collisions can not be zero; check the process to create INI files")
fi

echo "USING CONFIGURATION FILES TO COMPUTE COLLISIONS AND NETWORK CONNECTIVITY.."
coCnfS=`ls ${CONFIG_PATH}/*_forCol.ini`
algosToMv=""
for cfn in ${coCnfS} ; do
    filename=$(basename "$cfn")
    config_name="${filename%.*}"
    algo=$(get_protocol_from_config_name $config_name)
    algosToMv="${algosToMv}\n${algo}"
done
for cfn in `echo -e ${algosToMv}| sort -u`; do
  mv ${CONFIG_PATH}/*_p_${cfn}.ini "${resuD}/tmp"
done
for cfn in ${coCnfS} ; do
    filename=$(basename "$cfn")
    config_name="${filename%.*}"
    index=$(( ${#config_name} - 7 ))
    newName="${config_name:0:$index}.ini"
    mv ${cfn} ${CONFIG_PATH}/${newName}
done

echo -e "\tDONE\nFIRST ROUND: EXECUTION OF PROTOCOLS ${algos} TO COMPUTE COLLISIONS AND NETWORK CONNECTIVITY..."
for dens in `echo -e "${dSpar}\n${dMedi}\n${dDens}"`; do
  for algo in ${algos} ; do
    cnf=`ls ${CONFIG_PATH}/*_d_${dens}*_p_${algo}.ini`
    if [ ! -f ${cnf} ]; then
      echo -e "ERROR: configuration file ${cnf} doesn't exists; verify the process to create INI files\n"
      echo "END OF EXPERIMENT"
      exit 1
    echo -e "END OF EXPERIMENT WITH CONFIGURATION: ${cnf}"
    fi
    echo "START EXPERIMET WITH ALGORITHM: ${algo} AND DENSITY: ${dens}"
    ./run-one-configuration.sh ${cnf} ../../tools/omnetpp-4.6/samples/inet/ 1
    echo -e "\tEND OF EXPERIMENT WITH ALGORITHM: ${algo} AND DENSITY: ${dens}"
  done
done

mv ${resuD}/tmp/*.ini ${CONFIG_PATH}

echo -e "\tFIRST ROUND IS DONE\nSECOND ROUND: EXECUTION OF PROTOCOLS ${algos} TO COMPUTE BROADCASTING MEASURES"
for dens in `echo -e "${dSpar}\n${dMedi}\n${dDens}"`; do
  for algo in ${algos} ; do
    cnf=`ls ${CONFIG_PATH}/*_d_${dens}*_p_${algo}.ini`
    if [ ! -f ${cnf} ]; then
      echo -e "ERROR: configuration file ${cnf} doesn't exists; verify the process to create INI files\n"
      echo "END OF EXPERIMENT"
      exit 1
    echo -e "END OF EXPERIMENT WITH CONFIGURATION: ${cnf}"
    fi
    echo "START EXPERIMET WITH ALGORITHM: ${algo} AND DENSITY: ${dens}"
    ./run-one-configuration.sh ${cnf} ../../tools/omnetpp-4.6/samples/inet/ 0
    echo -e "\tEND OF EXPERIMENT WITH ALGORITHM: ${algo} AND DENSITY: ${dens}"
  done
done

rm densities
mv debugging/topology_* ${resuD}
mv ../../results/collisions_* ${resuD}
mv ../../results/graphConnectivity_* ${resuD}
mv ../../results/IndividualPlots-* ${resuD}
#TODO CHANGE HERE IF YOU WAN TO ADD COVERAGE, MESSAGES SENT AND RECEIVED (TO COMPENSATE THE BAD RESULTS IN POWER CONSUMPTION)
mv ../../results/batteryConsumption_* ${resuD}
mv ../../results/numberOfRelays_* ${resuD}
mv ../../results/duplicatedMsgs_* ${resuD}
mv ../../results/broadcastSessionTime_* ${resuD}
mv ../../results/networkCoverage_* ${resuD}
mv ../../results/sentMsgs_* ${resuD}
mv ../../results/rcvdMsgs_* ${resuD}
mv ../../experiments/configs/builtConfigs/results ${resuD}

echo -e "\tSECOND ROUND IS DONE\nPLOTTING BROADCAST METRICS"
Rscript plotDistributionsOfMetrics.R ${resuD}

echo -e "\tPLOTTING PROCEDURE IS DONE\nEXPERIMENT ${expeN} HAS FINISHED !!!"
exit 1

minimum_density=100000
maximum_density=0
algorithms=()

for config in ${CONFIG_PATH}/*.ini ; do
    filename=$(basename "$config")
    config_name="${filename%.*}"
    density=$(get_density_from_config_name $config_name)
    protocol=$(get_protocol_from_config_name $config_name)
    
    if [ "$density" -lt "$minimum_density" ]; then
    	minimum_density=$density
    fi
    if [ "$density" -gt "$maximum_density" ]; then
    	maximum_density=$density
    fi
    
    algorithms+=("-a" $protocol)
done
./run-selected-protocols-all-configs.sh -d $minimum_density -D $maximum_density -p ${CONFIG_PATH} ${algorithms[@]}
