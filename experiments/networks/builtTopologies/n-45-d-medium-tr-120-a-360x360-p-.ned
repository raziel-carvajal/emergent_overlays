import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network n-45-d-medium-tr-120-a-360x360-p-
{
@display("bgb=360,360");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=29.33, 23.23"); }
hostR1:CenterHost { @display("p=8.44, 89.19"); }
hostR2:CenterHost { @display("p=118.29, 113.49"); }
hostR3:CenterHost { @display("p=32.26, 81.02"); }
hostR4:CenterHost { @display("p=88.91, 37.15"); }
hostR5:CenterHost { @display("p=78.31, 210.42"); }
hostR6:CenterHost { @display("p=54.21, 52.73"); }
hostR7:CenterHost { @display("p=23.58, 10.39"); }
hostR8:CenterHost { @display("p=104.56, 77.71"); }
hostR9:CenterHost { @display("p=116.6, 44.41"); }
hostR10:CenterHost { @display("p=53.98, 149.54"); }
hostR11:CenterHost { @display("p=65.42, 359.18"); }
hostR12:CenterHost { @display("p=18.57, 157.37"); }
hostR13:CenterHost { @display("p=49.5, 222.43"); }
hostR14:CenterHost { @display("p=80.3, 178.07"); }
hostR15:CenterHost { @display("p=217.05, 29.95"); }
hostR16:CenterHost { @display("p=94.51, 9.71"); }
hostR17:CenterHost { @display("p=75.42, 14.28"); }
hostR18:CenterHost { @display("p=84.84, 74.12"); }
hostR19:CenterHost { @display("p=184.56, 112.67"); }
hostR20:CenterHost { @display("p=50.29, 136.61"); }
hostR21:CenterHost { @display("p=115.65, 153.61"); }
hostR22:CenterHost { @display("p=157.53, 156.13"); }
hostR23:CenterHost { @display("p=151.09, 13.88"); }
hostR24:CenterHost { @display("p=233.14, 154.8"); }
hostR25:CenterHost { @display("p=218.57, 63.29"); }
hostR26:CenterHost { @display("p=213.34, 79.11"); }
hostR27:CenterHost { @display("p=92.12, 239.19"); }
hostR28:CenterHost { @display("p=175.4, 233.05"); }
hostR29:CenterHost { @display("p=212.31, 272.03"); }
hostR30:CenterHost { @display("p=331.4, 54.43"); }
hostR31:CenterHost { @display("p=242.16, 99.41"); }
hostR32:CenterHost { @display("p=21.86, 104.66"); }
hostR33:CenterHost { @display("p=124.88, 101.98"); }
hostR34:CenterHost { @display("p=138.86, 22.52"); }
hostR35:CenterHost { @display("p=325.86, 7.68"); }
hostR36:CenterHost { @display("p=16.89, 162.31"); }
hostR37:CenterHost { @display("p=306.82, 105.21"); }
hostR38:CenterHost { @display("p=36.72, 173.39"); }
hostR39:CenterHost { @display("p=63.45, 184.77"); }
hostR40:CenterHost { @display("p=302.37, 73.48"); }
hostR41:CenterHost { @display("p=52.94, 71.14"); }
hostR42:CenterHost { @display("p=225.38, 74.75"); }
hostR43:CenterHost { @display("p=348.58, 135.92"); }
hostR44:CenterHost { @display("p=109.24, 125.75"); }
hostR45:CenterHost { @display("p=180.00, 180.00"); isCenter=true; }
}