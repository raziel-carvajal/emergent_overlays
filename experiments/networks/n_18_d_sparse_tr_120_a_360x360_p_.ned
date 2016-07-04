

import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import broadcasting.CenterHost;
network n_18_d_sparse_tr_120_a_360x360_p_
{
@display("bgb=360,360");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=26.33, 0.3"); }
hostR1:CenterHost { @display("p=107.65, 68.54"); }
hostR2:CenterHost { @display("p=99.6, 1.17"); }
hostR3:CenterHost { @display("p=56.28, 42.96"); }
hostR4:CenterHost { @display("p=47.76, 65.4"); }
hostR5:CenterHost { @display("p=84.74, 38.91"); }
hostR6:CenterHost { @display("p=193.16, 56.58"); }
hostR7:CenterHost { @display("p=139.74, 12.95"); }
hostR8:CenterHost { @display("p=102.43, 90.05"); }
hostR9:CenterHost { @display("p=192.33, 7.81"); }
hostR10:CenterHost { @display("p=197.55, 136.07"); }
//hostR11:CenterHost { @display("p=20.24, 311.13"); }
hostR11:CenterHost { @display("p=180.24, 250.13"); }
hostR12:CenterHost { @display("p=157.67, 84.88"); }
hostR13:CenterHost { @display("p=178.71, 44.51"); }
hostR14:CenterHost { @display("p=229.61, 236.37"); }
hostR15:CenterHost { @display("p=307.59, 188.6"); }
hostR16:CenterHost { @display("p=342.27, 291.4"); }
hostR17:CenterHost { @display("p=23.37, 90.79"); }
hostR18:CenterHost { @display("p=180.00, 180.00"); isCenter=true; }
}
