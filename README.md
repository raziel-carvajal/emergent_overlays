# Framework to Evaluate Dissemination Algorithms in Wireless Ad Hoc Networks
source code and experiments

## Motivation

Our aim is to make a correlation between mobile broadcasting algorithms for MANETs and networks configurations, where every network configuration is characterized by its density (sparse, medium, dense), mobility (nodes changes or not its position according to a mobility model), communication range of nodes (fixed or variable), churn, etc. We aim to have a table T as follows:

| Protocol / Configuration | C1 | C2 | C3 | ... |
|--------------------------|----|----|----|-----|
| P1                       |    |    |    |     |
| P2                       |    |    |    |     |
| ...                      |    |    |    |     |

where each P is an implementation of one broadcasting algorithm. In that survey, there is a taxonomy of broadcasting algorithms that we planned to respect i.e. the comparison will be driven between algorithms of the same category (as first step; once we have some results we will see if a comparison of algorithms from different categories makes sense).

Notice that in some cases protocols have different modes (attributes of the algorithm could be tuned with different values). Instead of having one row per algorithm at table T, we could have a group of rows per each algorithm.

## Algorithms

[Complete List](doc/algorithms.md)

## Network topologies

[Generation of one topology](doc/topology generation.md)

## Parameters and metrics to use

[Parameters and metrics](doc/parameters and metrics.md)

## On energy consumption

[Energy Consumption](doc/on energy consumption.md)

## Statistical Methods

## Summary of Current Status

- 4 Protocols fully implemented.
- 1 Protocol partially implemented. It depends on a dynamic range antenna and we don't have that model in OMNET.
- Using a simple antenna model. The collision model is too simple (there is collision if two nodes in range are sending at the same time). In addition, it is an isotropic antenna ([isotropic radiator](https://en.wikipedia.org/wiki/Isotropic_radiator)) (a.k.a ideal) that despite of being used in almost any simulation is not realistic.
- Generating topologies based on an expected density.
- So far, a single __INPUT PARAMETER__: the density.
- Many output parameters. See [Parameters and metrics](doc/parameters and metrics.md)
  - Alas, we are using simple averages to show the results.
- Overall conclusion so far, we cannot identify differences between algorithms in a clear way.
  - For instance, it is unclear how power consumption is affected by the algorithm.

## Related Works

A brief description of the implemented algorithms is [here](text/).

In the following link, we present a [comparison of our experimental setup with that of previous papers](doc/summary of previous works.docx). In particular, it shows how are the experiments configured in the papers we _implement_.

## TODO List

Some high level requests:

1.  Test the protocols to be sure they are bug-free.
2. Use a better antenna model. OMNET has a more realistic one, we must verify if its model to describe collision is better.
3. Check how power consumption is measured in previous works.
4. Improve the evaluation framework to use __bootstrapping__ to compute confident intervals for each metric.
5. Consider other metrics. For instance, a metric call __Complement of the Integral__ to find how fast the message is broadcast.
6. Consider options to statistically compare algorithms. The correlation of Spearman was mentioned in the dicussions here, but we have to discuss a bit more with our colleague.
7. Consider the __cumulative distribution frequency__ to present the results. Raziel is already working on that.

Detailed list:

[List (sorry, it has a mix of some languages: English, Spanish, some words in French and some gibberish I tend to write under pressure :-))](TODO.md)

## Installation instructions

## Running experiments
We evaluate a group of broadcasting algorithms for MANET's in three configuration of networks where N peers communicate with each other. Each network is described by its density, our understanding of density is the amount of neighbors that each peer reaches within its transmission range; we consider three types of density: sparse, medium and dense.

To set up one experiment refer to `experiments/configs/experimet.cnf` where three options are allowed:

- Algorithms: list of broadcasting algorithms (separated by one space). Every name must be equal to one of the folders located at  `src/protocols` where you will find the implementation of each broadcasting protocol
- Densities: three integers (separated by underscores) to represent networks densities
- ExpeName: string without spaces to name one experiment. IMPORTANT: avoid using underscores in this string

To execute one experiment go to `src/scripts` and run this script `./all.sh`, you will find the plots and datasets at the `results` directory.