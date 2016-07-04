import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import broadcasting.CenterHost;
network n_32_d_sparse_tr_120_a_480x480_p_
{
@display("bgb=480,480");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=29.65, 83.65"); }
hostR1:CenterHost { @display("p=64.51, 56.97"); }
hostR2:CenterHost { @display("p=5.22, 16.86"); }
hostR3:CenterHost { @display("p=23.05, 133.66"); }
hostR4:CenterHost { @display("p=100.63, 65.45"); }
hostR5:CenterHost { @display("p=61.86, 285.8"); }
hostR6:CenterHost { @display("p=11.22, 281.48"); }
hostR7:CenterHost { @display("p=116.34, 451.4"); }
hostR8:CenterHost { @display("p=27.3, 31.73"); }
hostR9:CenterHost { @display("p=66.78, 70.75"); }
hostR10:CenterHost { @display("p=144.42, 98.85"); }
hostR11:CenterHost { @display("p=213.3, 27.32"); }
hostR12:CenterHost { @display("p=104.18, 17.77"); }
hostR13:CenterHost { @display("p=152.08, 213.83"); }
hostR14:CenterHost { @display("p=214.84, 303.98"); }
hostR15:CenterHost { @display("p=93.86, 45.63"); }
hostR16:CenterHost { @display("p=25.58, 7.2"); }
hostR17:CenterHost { @display("p=354.3, 13.07"); }
hostR18:CenterHost { @display("p=299.63, 157.14"); }
hostR19:CenterHost { @display("p=43.8, 187.33"); }
hostR20:CenterHost { @display("p=225.32, 351.65"); }
hostR21:CenterHost { @display("p=136.88, 304.85"); }
hostR22:CenterHost { @display("p=314.58, 208.25"); }
hostR23:CenterHost { @display("p=195.67, 469.06"); }
hostR24:CenterHost { @display("p=358.08, 77.05"); }
hostR25:CenterHost { @display("p=5.99, 99.07"); }
hostR26:CenterHost { @display("p=439.4, 91.85"); }
hostR27:CenterHost { @display("p=449.17, 188.1"); }
hostR28:CenterHost { @display("p=136.1, 218.21"); }
hostR29:CenterHost { @display("p=409.11, 114.31"); }
hostR30:CenterHost { @display("p=442.31, 316.03"); }
hostR31:CenterHost { @display("p=423.05, 165.58"); }
hostR32:CenterHost { @display("p=240.00, 240.00"); isCenter=true; }
}
