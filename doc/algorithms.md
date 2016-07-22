
# A brief introduction to a taxonomy of broadcasting protocols
We are using the [taxonomy proposed by Ruiz et al. in 2015](papers/others/survey.pdf). This taxonomy is a useful way to classify broadcasting algorithms based on their features -- how they work, what can the information they use, what kind of physical devices they can use and so on.

![Taxonomy](taxonomy.png)

For the moment, we are interested on algorithms where the antenna transmission range is fixed (the red areas in the picture above). Observe that there are these protocols can be further classified depending on other features (e.g., underlying topology, context-awareness, etc.)

Each algorithm below can be located under one leaf in the taxonomy; we will give the leaf every time we present a method.

# Implemented

| Title  | Publication Type | Publication Name | Publication Rank | Year | Use Topology |
| ------------- | ------------- | ------------- | ------------- | ------------- | ---- |
|  Multipoint relaying for flooding broadcast messages in mobile wireless networks ([mpr](papers/implemented/mpr.pdf)) | Conference  | Hawaii International Conference on System Sciences  | A  | 2002  | |
| Area-based beaconless reliable broadcasting in sensor networks ([abba](papers/implemented/abba.pdf))  | Journal  | International Journal of Sensor Networks  | Content Cell  | 2006  | No |
| Extended Multipoint Relays to Determine Connected Dominating Sets in MANETs ([cds](papers/implemented/cds.pdf))  | Journal/Magazine  | IEEE Transactions on Computers  | A*  | 2006  |  |
| Analysis and evaluation of distance-to-mean broadcast method for VANET ( [dist2mean](papers/implemented/dist2mean.pdf), [evaluation](papers/implemented/dist2mean-more.pdf) )  | Journal  | Journal of King Saud University - Computer and Information Sciences/INTERNATIONAL JOURNAL OF COMMUNICATION SYSTEMS  | Content Cell  | 2013/2015  | No |
| Minimum-Energy Broadcast in All-Wireless Networks: NP-Completeness and Distribution Issues ([ewma](papers/implemented/ewma.pdf))  | Conference  | International Conference on Mobile Computing and Networking  | A*  | 2002 | Yes |


# Unimplemented

The following table presents algorithms that **don't require underlying topology**, with **fixed transmission range**, and (**context-aware** or **context Oblivious**)

| Title  | Publication Type | Publication Name | Publication Rank | Year | Use Topology |
| ------- | --------- | ---------- | --------- | --------- | ---- |
| The broadcast storm problem in a mobile ad hoc network ([simple flooding](papers/others/flooding.pdf))| Conf | MobiCom | A* | 1999 | |
| An adaptive approach to group communications in multi hop ad hoc networks ([Hyper-Flooding](papers/others/hyper-flooding.pdf)) | Conf | International Symposium on Computers and Communications | B | 2002 | |
| The broadcast storm problem in a mobile ad hoc network ([probabilistic flooding](papers/others/flooding.pdf))| Conf | MobiCom | A* | 1999 | |
| Speed adaptive probabilistic flooding in cooperative emergency warning ([SAPF](papers/others/SAPF.pdf)) | Conf | International Conference on Wireless Internet | - | 2008 | |
| Performance improvements for network-wide broadcast with instantaneous network information ([banerjee](papers/others/banerjee.pdf)) | Journal | Network and Computer Applications | A | 2012 | |
| Research and Realization on Improved MANET Distance Broadcast Algorithm Based on Percolation Theory ([Gang](papers/others/gang.pdf)) | Conf | International Conference on Industrial Control and Electronics Engineering | - | 2012 | |
| DibA: An adaptive broadcasting scheme in mobile ad hoc networks ([DibA](papers/others/diba.pdf)) | Conf | Communication Networks and Services Research Conference | | 2009 | |
| Stochastic broadcast for VANET ([slavik-stochastic](slavik-stochastic.pdf)) | Conf | Consumer Communications and Networking Conference | B | 2010 | |
