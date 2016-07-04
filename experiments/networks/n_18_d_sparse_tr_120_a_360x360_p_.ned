package builtTopologies;import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
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
hostR0:CenterHost { @display("p=57.85, 8.39"); }
hostR1:CenterHost { @display("p=100.47, 25.73"); }
hostR2:CenterHost { @display("p=49.14, 19.98"); }
hostR3:CenterHost { @display("p=64.29, 222.73"); }
hostR4:CenterHost { @display("p=83.03, 169.01"); }
hostR5:CenterHost { @display("p=46.25, 100.04"); }
hostR6:CenterHost { @display("p=104.79, 49.6"); }
hostR7:CenterHost { @display("p=36.71, 24.45"); }
hostR8:CenterHost { @display("p=117.03, 237.29"); }
hostR9:CenterHost { @display("p=31.94, 85.64"); }
hostR10:CenterHost { @display("p=225.38, 95.91"); }
hostR11:CenterHost { @display("p=88.81, 103.01"); }
hostR12:CenterHost { @display("p=202.53, 55.37"); }
hostR13:CenterHost { @display("p=62.86, 6.54"); }
hostR14:CenterHost { @display("p=281.37, 216.87"); }
hostR15:CenterHost { @display("p=156.86, 82.34"); }
hostR16:CenterHost { @display("p=9.31, 67.09"); }
hostR17:CenterHost { @display("p=75.2, 111.5"); }
hostR18:CenterHost { @display("p=180.00, 180.00"); isCenter=true; }
}