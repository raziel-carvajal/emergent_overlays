import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network n-8-d-sparse-tr-120-a-240x240-p-
{
@display("bgb=240,240");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=29.23, 94.27"); }
hostR1:CenterHost { @display("p=99.58, 58.29"); }
hostR2:CenterHost { @display("p=29.43, 227.42"); }
hostR3:CenterHost { @display("p=106.67, 89.96"); }
hostR4:CenterHost { @display("p=116.17, 93.29"); }
hostR5:CenterHost { @display("p=73.58, 68.85"); }
hostR6:CenterHost { @display("p=184.71, 201.71"); }
hostR7:CenterHost { @display("p=78.5, 215.43"); }
hostR8:CenterHost { @display("p=120.00, 120.00"); isCenter=true; }
}