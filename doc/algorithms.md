# A brief introduction to a taxonomy of broadcasting protocols
We are using the [taxonomy proposed by Ruiz et al. in 2015](papers/others/survey.pdf). This taxonomy is a useful way to classify broadcasting algorithms based on their features -- how they work, what can the information they use, what kind of physical devices they can use and so on. The taxonomy we follow is described by a tree where in its first level we found, those algorithms who build an **Underlying Topology** (**UT**) and those who do **Not** build an **Underlying Topology** (**NUT**). In the second level of the tree we found those protocols who **Vary** the **Transmission Range** (**VTxR**) and those who keep a **Fixed Transmission Range** (**FTxR**) as it is shown in the next figure:

![Taxonomy](taxonomy.png)

For the moment, we are interested on algorithms where the antenna transmission range is fixed (the red areas in the picture above). Observe that there are these protocols can be further subclassfied depending on other features (e.g., underlying topology, context-awareness, etc.)

Each algorithm below can be located under one leaf in the taxonomy; we will give the leaf every time we present a method.

**Note: protocols with the check mark &#10004; are implemented while those with &#10008; are not**

# Underlying topology algorithms with a fixed transmission range
| Title  | Topology | Name | Rank | Year | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Forward-node-set-based broadcast in clustered mobile ad hoc networks [FNSB](papers/others/wcmc2003.pdf) &#10008; | Cluster | [Wireless Communications and Mobile Computing](http://www.scimagojr.com/journalsearch.php?q=17543&tip=sid&clean=0)**(journal)**| A | 2003 |
| Connectivity Based k-hop Clustering in Wireless Networks [K-HOP](papers/others/10.1.1.104.5681.pdf) &#10008;| Cluster |  [Proceedings of the Annual Hawaii International Conference on System Sciences](http://www.scimagojr.com/journalsearch.php?q=145755&tip=sid&clean=0)**(conf)** | A | 2003 |
| Extended Multipoint Relays to Determine Connected Dominating Sets in MANETs [CDS-MPR](papers/implemented/cds.pdf) &#10008; | MPR, CDS | [IEEE Transactions on Computers](http://www.scimagojr.com/journalsearch.php?q=25033&tip=sid&clean=0)**(journal)**| A* | 2006 |
|Dominating sets and neighbor elimination-based broadcasting algorithms in wireless networks [CDS](papers/others/DominartingSets02.pdf) &#10008; | CDS | [IEEE Transactions on Parallel and Distributed Systems](http://www.scimagojr.com/journalsearch.php?q=26098&tip=sid&clean=0)**(journal)** | A* | 2002 |
| BODYF – A Parameterless Broadcasting Protocol Over Dynamic Forest [BODYF](papers/others/10.1.1.371.7527.pdf) &#10008; | Tree | [IEEE International Conference on High Performance Computing and Simulation (HPCS)](http://lipn.univ-paris13.fr/~bennani/CSRank.html)**(conf)**| B | 2008 |
| On Demand Routing in Large Ad Hoc Wireless Networks with Passive Clustering [AODV/PC](papers/others/kwon-wcnc00.pdf) &#10008;| Cluster | [IEEE Wireless Communications and Networking Conference, WCNC](http://www.scimagojr.com/journalsearch.php?q=145653&tip=sid&clean=0)**(conf)** | B | 2000 |
| On Calculating Power-Aware Connected Dominating Sets for Efficient Routing in Ad Hoc Wireless Networks [CDS](papers/others/jcn.pdf) &#10004; | CDS |[JOURNAL OF COMMUNICATIONS AND NETWORKS](http://www.scimagojr.com/journalsearch.php?q=4800154012&tip=sid&clean=0) **(journal)**| C | 2000 |
| Information dissemination in VANETs based upon a tree topology [DAGRS/BODYF](papers/others/91e59974989554f70cd9cf64d8ac7a1ca9dd.pdf) &#10008; | Tree | [Journal of Ad Hoc Networks](http://www.scimagojr.com/journalsearch.php?q=26799&tip=sid&clean=0)**(journal)** | ? | 2012 |



# Non underlying topology algorithms with a fixed transmission range
| Title | Category | Name | Rank | Year | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Optimized broadcast protocol for sensor networks ([durresi](http://ieeexplore.ieee.org/xpl/login.jsp?tp=&arnumber=1453502&url=http%3A%2F%2Fieeexplore.ieee.org%2Fxpls%2Fabs_all.jsp%3Farnumber%3D1453502)) &#10008; | - | IEEE Transactions on Computers | A* | 2005 |
| A broadcasting method considering battery lifetime and distance between nodes in MANET [BMBD](papers/others/) &#10008; | ? | International Conference on Distributed Computing Systems Workshops **(workshop)** | A | 2009 |
| Border node retransmission based probabilistic broadcast protocols in ad-hoc networks [cartigny](papers/others/cartigny.pdf) &#10008; | ? | [Hawaii International Conference on System Sciences](http://portal.core.edu.au/conf-ranks/575/) **(conf)** | A | 2003 |
| Multipoint relaying for flooding broadcast messages in mobile wireless networks [MPR](papers/implemented/mpr.pdf) &#10004; | Neighbor-based | [Hawaii International Conference on System Sciences](http://portal.core.edu.au/conf-ranks/575/) **(conf)**| A  | 2002  | Decentralized heuristic that finds one subset MPR of one-hop neighbors that covers every two-hops neighbors per every peer P in the network |
| Adaptive approaches to relieving broadcast storms in a wireless multihop mobile ad hoc network [AdaptiveCounter](paper/others/AdaptiveCounter.ps) &#10008; | ? | [IEEE Transactions on Computers](http://portal.core.edu.au/jnl-ranks/360/) **(journal)** | A* | 2002 |
| The broadcast storm problem in a mobile ad hoc network [simple flooding](papers/others/flooding.pdf) &#10008;| ? | MobiCom **(conf)** | A* | 1999 |
| Performance improvements for network-wide broadcast with instantaneous network information [banerjee](papers/others/banerjee.pdf) &#10008; | ? | Network and Computer Applications **(journal)**| A | 2012 |
| The broadcast storm problem in a mobile ad hoc network [probabilistic flooding](papers/others/flooding.pdf) &#10008;| ? | MobiCom **(conf)** | A* | 1999 |
| Probabilistic reliable dissemination in large-scale systems [gossip-based](papers/others/gossip-based.pdf) &#10008; | ? | [IEEE Transactions on Parallel Distributed Systems](http://portal.core.edu.au/jnl-ranks/459/) **(journal)**| A* | 2003 |
| Stochastic broadcast for VANET [slavik-stochastic](slavik-stochastic.pdf) &#10008; | ? | [Consumer Communications and Networking Conference](http://portal.core.edu.au/conf-ranks/616/) **(conf)** | B | 2010 |
| Location aided broadcast in wireless ad hoc network systems [SunAndLai](papers/others/SunAndLai.pdf) &#10008; | ? | [IEEE Wireless Communications and Networking Conference](http://portal.core.edu.au/conf-ranks/760/) **(conf)**| B | 2002 |
| An adaptive approach to group communications in multi hop ad hoc networks [Hyper-Flooding](papers/others/hyper-flooding.pdf) &#10008; | ? | International Symposium on Computers and Communications **(conf)**| B | 2002 |
| Resource aware information dissemination in ad hoc networks ([paper](http://ieeexplore.ieee.org/xpl/login.jsp?tp=&arnumber=1266255&url=http%3A%2F%2Fieeexplore.ieee.org%2Fiel5%2F8945%2F28322%2F01266255.pdf%3Farnumber%3D1266255)) &#10008; | Neightbord-based | IEEE International Conference on Networks | B | 2003 |
| Speed adaptive probabilistic flooding in cooperative emergency warning [SAPF](papers/others/SAPF.pdf) &#10008; | ? | International Conference on Wireless Internet **(conf)** | C | 2008 |
| Area-based beaconless reliable broadcasting in sensor networks [ABBA](papers/implemented/abba.pdf) &#10004;| Context-aware/Area-based | [International Journal of Sensor Networks](http://www.scimagojr.com/journalsearch.php?q=19900192159&tip=sid&clean=0) **(journal)** | C | 2006  |
| NPPB: A broadcast scheme in dense VANETs [NPPB](papers/others/NPPB.pdf) &#10008; | ? | [Information Technology Journal](http://portal.core.edu.au/jnl-ranks/573/) **(journal)** | C | 2010 |
| An energy-aware broadcast scheme for directed diffusion in wireless sensor network [CAO](papers/others/CAO.pdf) &#10008; | ? | [Journal of Communication and Computer](http://portal.core.edu.au/jnl-ranks/845/) **(journal)** | C | 2007 |
| Analysis and evaluation of distance-to-mean broadcast method for VANET [MEAN2MEAN](papers/implemented/dist2mean.pdf) &#10004; | Context-aware/Area-based  | Journal of King Saud University - Computer and Information Sciences/INTERNATIONAL JOURNAL OF COMMUNICATION SYSTEMS **(journal)**| ?  | 2013/2015 |
| Research and Realization on Improved MANET Distance Broadcast Algorithm Based on Percolation Theory [Gang](papers/others/gang.pdf) &#10008; | ? | [International Conference on Industrial Control and Electronics Engineering](http://www.scimagojr.com/journalsearch.php?q=21100220414&tip=sid&clean=0) **(conf)** | ? | 2012 |
| DibA: An adaptive broadcasting scheme in mobile ad hoc networks [DibA](papers/others/diba.pdf) &#10008; | ? | [Communication Networks and Services Research Conference](http://www.scimagojr.com/journalsearch.php?q=4700152727&tip=sid&clean=0) **(conf)** | ? | 2009 |
| Color-based broadcasting for ad hoc networks [color-based](papers/others/color-based.pdf) &#10008; | ? | [International Symposium on Modeling and Optimization in Mobile](http://www.scimagojr.com/journalsearch.php?q=21100264322&tip=sid&clean=0) **(conf)** | ? | 2006 |
| A probability-based adaptive scheme for broadcasting in MANETs [ProbA](papers/others/ProbA.pdf) &#10008; | ? | [Conference on Mobile Technology, Application & Systems](http://www.scimagojr.com/journalsearch.php?q=19700170485&tip=sid&clean=0) **(conf)** | ? | 2009 |
| Adaptive multihop broadcast protocols for ad hoc networks [*BHG](papers/others/poznan_cikk.pdf) | ? | [International Symposium on Communication Systems, Networks Digital Signal Processing](http://www.scimagojr.com/journalsearch.php?q=21100218914&tip=sid&clean=0) **(conf)** | ? | 2012 |
| An Efficient Flooding Algorithm for Mobile Ad-hoc Networks [geoflood](papers/others/geoflood.pdf) &#10008; | ? | Workshop on Modeling and Optimizations in Mobile Ad Hoc and Wireless Networks **(workshop)**| ? | 2004 |
| Six-shot broadcast: A context-aware algorithm for efficient message diffusion in MANETs [six-shoot](papers/others/six-shoot.pdf) &#10008; | ? | Confederated International Conferences, CoopIS, DOA, GADA, IS, and ODBASE **(conf)**| ? | 2008 |



# Underlying topology algorithms with a variable transmission range
| Title  | Name | Rank | Year |
| :--- | :--- | :--- | :--- |
| Minimum-Energy Broadcast in All-Wireless Networks: NP-Completeness and Distribution Issues [EWMA](papers/implemented/ewma.pdf) &#10004; | [International Conference on Mobile Computing and Networking](http://portal.core.edu.au/conf-ranks/27/) **(conf)** | A*  | 2002 |
