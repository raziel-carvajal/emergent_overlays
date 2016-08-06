
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

Per __algorithm__ and per __network configuration__ we collect the following data:

- Percentage of nodes that receive the message in a broadcast session. With that information we have a vector where each element correspond to a broadcast session. For instance, if vector[3] = 60 it means that in broadcast session 3, 60% of the nodes received the message. Using this vector we can compute the __metric Network coverage__. So far, we are using the __mean__ to compute this metric.
- For those broadcast sessions where the coverage reach a minimum threshold __T__, we can compute the __Broadcasting session time__. For a single experiment, this value can be shown using the mean or as a distribution. We are using a threshold __T__ of 100%, but in some papers this value is less (__95%__) or not even considered.
- Power consumption along the experiment. This is, at different time, what is the __residual capacity__ in the battery. We expect that the more a node transmit, the lower is its residual capacity.
- For those broadcast sessions where the coverage reach a minimum threshold __T__, we compute the number of __duplicated messages__ received at each node. Then we find the mean value for the whole experiment.
- How many nodes __retransmit the message__. This has yet to be done, but the idea is to compute for each broadcast session how many nodes retransmit the message.
- __Number of collisions__ (yet to be done). Since we are using an antenna model that emulates collisions, we can measure the total number of collisions in the experiments, or the number of collisions per node.

Note that all the values mentioned are collected for each pair (algorithm, network configuration). We can have many such pairs sharing the same algorithm and configuration. The question is than in such a case we _must_ aggregate the results somehow.
1. For each experiment, We must aggregate the results that are not a single value (e.g., network coverage).
2. We must aggregate the results of many pairs.

For more information see [statistical methodology](statistical methodology.md).

### Information about code

Implementation of UDP in the application layer
