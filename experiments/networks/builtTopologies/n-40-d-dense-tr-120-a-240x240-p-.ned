import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network n-40-d-dense-tr-120-a-240x240-p-
{
@display("bgb=240,240");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=80.28, 1.82"); }
hostR1:CenterHost { @display("p=19.8, 16.4"); }
hostR2:CenterHost { @display("p=26.43, 17.13"); }
hostR3:CenterHost { @display("p=101.57, 101.14"); }
hostR4:CenterHost { @display("p=74.39, 110.78"); }
hostR5:CenterHost { @display("p=81.87, 74.17"); }
hostR6:CenterHost { @display("p=75.1, 116.73"); }
hostR7:CenterHost { @display("p=28.32, 45.44"); }
hostR8:CenterHost { @display("p=35.45, 19.86"); }
hostR9:CenterHost { @display("p=27.31, 30.35"); }
hostR10:CenterHost { @display("p=109.16, 18.2"); }
hostR11:CenterHost { @display("p=1.39, 142.17"); }
hostR12:CenterHost { @display("p=113.08, 204.97"); }
hostR13:CenterHost { @display("p=65.19, 65.98"); }
hostR14:CenterHost { @display("p=48.97, 32.29"); }
hostR15:CenterHost { @display("p=11.36, 186.6"); }
hostR16:CenterHost { @display("p=31.28, 43.59"); }
hostR17:CenterHost { @display("p=72.18, 213.93"); }
hostR18:CenterHost { @display("p=66.07, 235.75"); }
hostR19:CenterHost { @display("p=36.87, 219.99"); }
hostR20:CenterHost { @display("p=193.11, 32.64"); }
hostR21:CenterHost { @display("p=92.59, 118.65"); }
hostR22:CenterHost { @display("p=128.01, 14.42"); }
hostR23:CenterHost { @display("p=113.99, 31.24"); }
hostR24:CenterHost { @display("p=34.96, 13.95"); }
hostR25:CenterHost { @display("p=8.51, 110.25"); }
hostR26:CenterHost { @display("p=75.9, 63.6"); }
hostR27:CenterHost { @display("p=90.36, 91.47"); }
hostR28:CenterHost { @display("p=160.63, 86.26"); }
hostR29:CenterHost { @display("p=233.34, 1.95"); }
hostR30:CenterHost { @display("p=25.72, 10.49"); }
hostR31:CenterHost { @display("p=196.91, 29.67"); }
hostR32:CenterHost { @display("p=167.52, 215.91"); }
hostR33:CenterHost { @display("p=165.09, 82.35"); }
hostR34:CenterHost { @display("p=164.18, 162.35"); }
hostR35:CenterHost { @display("p=114.75, 220.6"); }
hostR36:CenterHost { @display("p=23.26, 189.01"); }
hostR37:CenterHost { @display("p=161.6, 82.09"); }
hostR38:CenterHost { @display("p=12.72, 122.63"); }
hostR39:CenterHost { @display("p=165.56, 144.5"); }
hostR40:CenterHost { @display("p=120.00, 120.00"); isCenter=true; }
}