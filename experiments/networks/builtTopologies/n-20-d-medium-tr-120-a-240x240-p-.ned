import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network n-20-d-medium-tr-120-a-240x240-p-
{
@display("bgb=240,240");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=95.64, 35.0"); }
hostR1:CenterHost { @display("p=21.82, 9.06"); }
hostR2:CenterHost { @display("p=20.87, 13.37"); }
hostR3:CenterHost { @display("p=1.59, 79.6"); }
hostR4:CenterHost { @display("p=10.67, 10.79"); }
hostR5:CenterHost { @display("p=11.72, 124.89"); }
hostR6:CenterHost { @display("p=72.22, 1.27"); }
hostR7:CenterHost { @display("p=82.38, 9.2"); }
hostR8:CenterHost { @display("p=97.96, 148.84"); }
hostR9:CenterHost { @display("p=90.19, 125.65"); }
hostR10:CenterHost { @display("p=85.35, 11.23"); }
hostR11:CenterHost { @display("p=31.56, 21.64"); }
hostR12:CenterHost { @display("p=23.01, 82.61"); }
hostR13:CenterHost { @display("p=183.92, 113.59"); }
hostR14:CenterHost { @display("p=223.97, 116.2"); }
hostR15:CenterHost { @display("p=183.56, 180.07"); }
hostR16:CenterHost { @display("p=153.7, 105.43"); }
hostR17:CenterHost { @display("p=58.57, 90.38"); }
hostR18:CenterHost { @display("p=82.06, 84.31"); }
hostR19:CenterHost { @display("p=1.08, 153.34"); }
hostR20:CenterHost { @display("p=120.00, 120.00"); isCenter=true; }
}