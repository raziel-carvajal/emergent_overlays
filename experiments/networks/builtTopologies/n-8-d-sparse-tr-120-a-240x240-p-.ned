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
hostR0:CenterHost { @display("p=16.73, 24.97"); }
hostR1:CenterHost { @display("p=22.5, 52.71"); }
hostR2:CenterHost { @display("p=91.81, 102.09"); }
hostR3:CenterHost { @display("p=2.95, 215.79"); }
hostR4:CenterHost { @display("p=221.57, 93.91"); }
hostR5:CenterHost { @display("p=158.42, 84.9"); }
hostR6:CenterHost { @display("p=66.33, 124.01"); }
hostR7:CenterHost { @display("p=195.19, 141.01"); }
hostR8:CenterHost { @display("p=120.00, 120.00"); isCenter=true; }
}