
## Our definition of density

For us, the density of a topology is related to the number of neighbors in the vicinity of a node. To be precise, __the density of node n is the number of nodes in the vicinity of n__.

We say that the density of a network G is the mean value of the local densities. This is d(G)=sum(density(n) for all nodes n in G)/|G|.

As usual, we can see a network topology as a graph. In this case, our definition of density of a node is exactly the same as a node degree.   

## Procedure to Generate Topologies
To generate a topology, we simply generate a [Random geometric graph (RGG)](https://en.wikipedia.org/wiki/Random_geometric_graph) using  a __uniform distribution__. In this case, we know that

n*pi*r^2 = expected degree of G,

where __n__ is the number of nodes in the graph __G__, and __r__ is the _normalized_ transmission range.
Using this equation we can build network topologies with a given expected degree.

For instance, let's say that we have a map of _100x100_ and we want to obtain a network with a degree of _5_. So we have,

n*pi*r^2 = 5

and now we can vary to parameters, __r__ or __n__. Fixing the transmission range to _10_ we get __r=0.1__ and __n=159,159__.
This means that we should generate a __RGG__ with 160 nodes to guarantee an expected network degree of 5.
After the network is generated we perform three steps:

1. Scale all the locations to the map size (their generated locations are in [0, 1]^2).
2. Check that the observed degree is close enough to the expected degree (within a 5% error margin).
3. Check that the topology is connected.

__If any such tests fail (either test 2 or 3) the topology is discarded__. Otherwise, we keep it and use it.

## Parameters chosen to generate topologies.

- The __map__ is always __100x100__.
- The __radius__ is __10__.
- The __densities__ vary from __5__ to __40__ using a step of __5__. 
