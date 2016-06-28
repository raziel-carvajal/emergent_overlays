import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network n-18-d-sparse-tr-120-a-360x360-p-
{
@display("bgb=360,360");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=110.27, 98.42"); }
hostR1:CenterHost { @display("p=97.09, 27.47"); }
hostR2:CenterHost { @display("p=60.64, 122.14"); }
hostR3:CenterHost { @display("p=77.83, 226.55"); }
hostR4:CenterHost { @display("p=71.63, 52.96"); }
hostR5:CenterHost { @display("p=42.21, 203.05"); }
hostR6:CenterHost { @display("p=104.99, 59.54"); }
hostR7:CenterHost { @display("p=80.1, 33.91"); }
hostR8:CenterHost { @display("p=44.77, 147.97"); }
hostR9:CenterHost { @display("p=160.17, 236.04"); }
hostR10:CenterHost { @display("p=160.34, 136.73"); }
hostR11:CenterHost { @display("p=239.81, 43.89"); }
hostR12:CenterHost { @display("p=356.62, 116.12"); }
hostR13:CenterHost { @display("p=277.99, 82.81"); }
hostR14:CenterHost { @display("p=105.59, 102.94"); }
hostR15:CenterHost { @display("p=299.93, 160.82"); }
hostR16:CenterHost { @display("p=343.23, 337.07"); }
hostR17:CenterHost { @display("p=112.67, 19.53"); }
hostR18:CenterHost { @display("p=180.00, 180.00"); isCenter=true; }
}