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
hostR0:CenterHost { @display("p=90.25, 84.32"); }
hostR1:CenterHost { @display("p=108.99, 71.83"); }
hostR2:CenterHost { @display("p=84.31, 92.95"); }
hostR3:CenterHost { @display("p=71.12, 102.96"); }
hostR4:CenterHost { @display("p=85.75, 66.09"); }
hostR5:CenterHost { @display("p=66.95, 7.33"); }
hostR6:CenterHost { @display("p=40.68, 60.06"); }
hostR7:CenterHost { @display("p=5.42, 18.33"); }
hostR8:CenterHost { @display("p=82.63, 185.79"); }
hostR9:CenterHost { @display("p=11.38, 75.59"); }
hostR10:CenterHost { @display("p=185.69, 112.01"); }
hostR11:CenterHost { @display("p=165.08, 35.4"); }
hostR12:CenterHost { @display("p=69.42, 22.25"); }
hostR13:CenterHost { @display("p=83.02, 119.09"); }
hostR14:CenterHost { @display("p=61.39, 51.34"); }
hostR15:CenterHost { @display("p=89.62, 67.09"); }
hostR16:CenterHost { @display("p=62.84, 234.97"); }
hostR17:CenterHost { @display("p=78.22, 22.43"); }
hostR18:CenterHost { @display("p=235.55, 45.05"); }
hostR19:CenterHost { @display("p=220.07, 207.64"); }
hostR20:CenterHost { @display("p=120.00, 120.00"); isCenter=true; }
}