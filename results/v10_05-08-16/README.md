# Partial results contained in this folder
In this folder you will find experimental results of the next 6 broadcasting algorithms for MANETs:

- ABBA

- CDS

- DIST2MEAN: one bug was found in this algorithm, do not be surprise if you will not see the corresponding curve of this algorithm on each plot

- EWMA

- FLOODING

- MPRT

##Experimental settings

###General
- Simulation time: 240 s

- Broadcast source: one node during the whole experiment performs every broadcast session

- Number of broadcast sessions: 300

- Timeout between 2 broadcast sessions: 0.5 s

###Node
- Initial energy: 50J
- Mobility: &#10008;

### Network topology
- Area size: 100 X 100 meters

- Density (number of nodes in the cover area of the transceiver)
    - Sparse: 5 nodes
    - Medium: 10 nodes
    - Dense: 15 nodes

- Total number of nodes per density type
    - Sparse: 160 nodes
    - Medium: 319 nodes
    - Dense: 478 nodes

### Transceiver
- Interference mode: &#10008;

- Tunning
    - bitrate: 1Mbps
    - energyConsumerType: "StateBasedEnergyConsumer"
    - offPowerConsumption: 0mW
    - receiverReceivingPowerConsumption: 40mW
    - receiverIdlePowerConsumption: 0mW
    - receiverBusyPowerConsumption: 0mW
    - receiverSynchronizingPowerConsumption: 0mW
    - sleepPowerConsumption: 0mW
    - switchingPowerConsumption: 0mW
    - transmitterIdlePowerConsumption: 0mW
    - transmitterTransmittingPowerConsumption: 40mW