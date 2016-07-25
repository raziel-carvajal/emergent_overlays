
## Network configurations
The group of parameters of each network configuration C is described as follows:

- Location aspects
	- Position of the node that is going to trigger broadcasting sessions
		- Located at the center of network area. Here just one node start all broadcast sessions in the whole experiment
		- __Random choice over time. Before the experiment starts, every node knows which broadcast sessions are triggered by him and at what instant during the experiment__
		- Randomly choose a node within a circle with center in the middle of the _map_. This has the same benefit as the previous options and it also guarantees that all messages are received with a similar broadcasting time.
	- Mobility
		- __Static. The position of each node is fixed during the whole experiment__
		- Mobility model. Every node change its position following a mobility model (linear, random, etc.)
	- Churn. Node joins and leave the network at a certain frequency. Note: any of the articles referenced at [1] consider churn
	- Density (position of receivers). We define density as the number of nodes covered by the transmission range of nodes:
		- __From 5 neighbors to 40 neighbors.__
		- Heterogeneous. Number of nodes randomly located at the whole network area without taking into consideration the transmission rage of nodes. With this model, the density of nodes will be defined by the number of total nodes in the whole area; decreasing the number of nodes will tend to have a sparse network.  Note: this model is followed at [1]
- Networking aspects
	- Communication range
		- __Fixed radius. Every node send a message at the maximum transmission range its antenna could cover__. The current value used is __10__.
		- Variable radius. Each node varies the transmission range of its antenna depending on the algorithm (typically to reduce the battery power consumption)
- Energy aspects
	- Battery capacity. We are following the standard model of Oment++.
		- All nodes start with the battery level at __50J__. This is about 1-5% of the capacity in a AAA battery.
	- Antenna technology
		- Currently we use an implementation of the transceiver [Texas Instrument CC1000](http://www.ti.com/lit/ds/symlink/cc1000.pdf)
			- Isotropic antenna that model the power consumption of each antenna state (sleep, sending, receiving, etc)

##Metrics
Before the description of each metric we have to take into account that:

- Broadcast sessions and nodes are identified in a unique way
- Broadcasts are performed every 0.5 seconds
- We perform (right now) __1__ broadcast session. We were doing 300, but we are discussing what is better.

Per algorithm and per network configuration we will measure:

- Network coverage. Percentage of nodes that receive
- Broadcasting session time. Distribution.
- Power consumption
- Duplicated messages
- How many nodes retransmit the message.
- Number of collisions

For more information see [statistical methodology](statistical methodology.md).

### Information about code

Implementation of UDP in the application layer
