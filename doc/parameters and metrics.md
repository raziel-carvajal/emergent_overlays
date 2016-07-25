# Evaluation of broadcasting algorithms for MANET's under different scenarios

Our aim is to make a correlation between mobile broadcasting algorithms for MANETs and networks configurations, where every network configuration is characterized by its density (sparse, medium, dense), mobility (nodes changes or not its position according to a mobility model), communication range of nodes (fixed or variable), churn, etc. We aim to have a table T as follows:

| Protocol / Configuration | C1 | C2 | C3 | ... |
|--------------------------|----|----|----|-----|
| P1                       |    |    |    |     |
| P2                       |    |    |    |     |
| ...                      |    |    |    |     |

where each P is an implementation of one broadcasting algorithm (we are using as reference the algorithms described in the following survey [1]). In that survey, there is a taxonomy of broadcasting algorithms that we planned to respect i.e. the comparison will be driven between algorithms of the same category (as first step; once we have some results we will see if a comparison of algorithms from different categories makes sense).

Notice that in some cases protocols have different modes (ottributes of the algorithm could be tuned with different values). Instead of having one row per algorithm at table T, we could have a group of rows per each algorithm.

## Network configurations
The group of parameters of each network configuration C is described as follows:

- Location aspects
	- Position of the node that is going to trigger broadcasting sessions
		- Located at the center of network area. Here just one node start all broadcast sessions in the whole experiment
		- Random choice over time. Before the experiment starts, every node knows which broadcast sessions are triggered by him and at what instant during the experiment
		- Randomly choose a node within a circle with center in the middle of the _map_. This has the same benefit as the previous options and it also guarantees that all messages are received with a similar broadcasting time.
	- Mobility
		- Static. The position of each node is fixed during the whole experiment
		- Mobility model. Every node change its position following a mobility model (linear, random, etc.)
	- Churn. Node joins and leave the network at a certain frequency. Note: any of the articles referenced at [1] consider churn
	- Density (position of receivers). We define density as the number of nodes covered by the transmission range of nodes:
		- Sparse. 2 nodes
		- Medium. 5 nodes
		- Dense. 10 nodes
		- Heterogeneous. Number of nodes randomly located at the whole network area without taking into consideration the transmission rage of nodes. With this model, the density of nodes will be defined by the number of total nodes in the whole area; decreasing the number of nodes will tend to have a sparse network.  Note: this model is followed at [1]
- Networking aspects
	- Communication range
		- Fixed radius. Every node send a message at the maximum transmission range its antenna could cover
		- Variable radius. Each node varies the transmission range of its antenna depending on the algorithm (typically to reduce the battery power consumption)
- Energy aspects
	- Battery capacity. We are following the standard model of Oment++
	- Antenna technology
		- Currently we use an implementation of the transceiver [Texas Instrument CC1000](http://www.ti.com/lit/ds/symlink/cc1000.pdf)
			- Isotropic antenna that model the power consumption of each antenna state (sleep, sending, receiving, etc)

##Metrics
Before the description of each metric we have to take into account that:

- Broadcast sessions and nodes are identified in a unique way
- Brodcast are performed every 0.5 seconds

Per algorithm and per network configuration we will measure:

- Network coverage. Percentage of nodes that receive 
- Broadcasting session time. Distribution 
- Power consumption
- Duplicated messages

Every cell on the table T will be filled with the metrics that were described in this section.

## Others
### Broadcasting settings
- every 0.5 seconds one broadcasting session is performed

### Information about code

Implementation of UDP in the application layer

### Current State
- Algorithms implementation
	- Currently we have 3 implementation running
		- ABBA
		- MWST
	- Future Implementations
		- Multi point relay
		- Connected dominating set

##Protocols
## References
1. Ruiz P et al. Survey on Broadcasting Algorithms for Mobile Ad Hoc Networks
