
import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import broadcasting.CenterHost;
network n_50_d_sparse_tr_120_a_600x600_p_
{
@display("bgb=600,600");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=104.91, 62.21"); }
hostR1:CenterHost { @display("p=70.49, 117.88"); }
hostR2:CenterHost { @display("p=74.9, 37.01"); }
hostR3:CenterHost { @display("p=42.27, 82.92"); }
hostR4:CenterHost { @display("p=85.67, 116.81"); }
hostR5:CenterHost { @display("p=48.52, 278.56"); }
hostR6:CenterHost { @display("p=92.25, 431.24"); }
hostR7:CenterHost { @display("p=34.05, 113.7"); }
hostR8:CenterHost { @display("p=77.91, 498.62"); }
hostR9:CenterHost { @display("p=94.07, 34.38"); }
hostR10:CenterHost { @display("p=118.79, 26.02"); }
hostR11:CenterHost { @display("p=233.7, 41.95"); }
hostR12:CenterHost { @display("p=172.95, 177.52"); }
hostR13:CenterHost { @display("p=142.61, 165.57"); }
hostR14:CenterHost { @display("p=129.55, 238.55"); }
hostR15:CenterHost { @display("p=229.26, 312.94"); }
hostR16:CenterHost { @display("p=222.1, 396.08"); }
hostR17:CenterHost { @display("p=78.14, 125.99"); }
hostR18:CenterHost { @display("p=180.0, 330.74"); }
hostR19:CenterHost { @display("p=87.87, 108.46"); }
hostR20:CenterHost { @display("p=154.55, 93.38"); }
hostR21:CenterHost { @display("p=204.41, 106.5"); }
hostR22:CenterHost { @display("p=81.85, 156.26"); }
hostR23:CenterHost { @display("p=328.97, 190.92"); }
hostR24:CenterHost { @display("p=186.42, 119.58"); }
hostR25:CenterHost { @display("p=150.35, 131.27"); }
hostR26:CenterHost { @display("p=137.09, 234.55"); }
hostR27:CenterHost { @display("p=348.91, 183.06"); }
hostR28:CenterHost { @display("p=155.53, 596.37"); }
hostR29:CenterHost { @display("p=208.48, 114.32"); }
hostR30:CenterHost { @display("p=316.27, 112.05"); }
hostR31:CenterHost { @display("p=151.2, 119.53"); }
hostR32:CenterHost { @display("p=33.88, 62.85"); }
hostR33:CenterHost { @display("p=153.44, 202.91"); }
hostR34:CenterHost { @display("p=147.35, 77.75"); }
hostR35:CenterHost { @display("p=147.17, 37.58"); }
hostR36:CenterHost { @display("p=84.15, 10.67"); }
hostR37:CenterHost { @display("p=422.4, 431.34"); }
hostR38:CenterHost { @display("p=153.68, 299.07"); }
hostR39:CenterHost { @display("p=51.23, 149.02"); }
hostR40:CenterHost { @display("p=550.33, 70.84"); }
hostR41:CenterHost { @display("p=540.93, 23.62"); }
hostR42:CenterHost { @display("p=217.24, 203.66"); }
hostR43:CenterHost { @display("p=47.71, 63.08"); }
hostR44:CenterHost { @display("p=141.21, 288.44"); }
hostR45:CenterHost { @display("p=197.36, 87.12"); }
hostR46:CenterHost { @display("p=366.85, 200.93"); }
hostR47:CenterHost { @display("p=599.06, 398.19"); }
hostR48:CenterHost { @display("p=394.95, 376.0"); }
hostR49:CenterHost { @display("p=282.85, 519.99"); }
hostR50:CenterHost { @display("p=300.00, 300.00"); isCenter=true; }
}
