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
hostR0:CenterHost { @display("p=42.62, 77.17"); }
hostR1:CenterHost { @display("p=28.95, 9.52"); }
hostR2:CenterHost { @display("p=48.71, 185.43"); }
hostR3:CenterHost { @display("p=105.64, 10.72"); }
hostR4:CenterHost { @display("p=115.41, 253.89"); }
hostR5:CenterHost { @display("p=8.43, 149.33"); }
hostR6:CenterHost { @display("p=180.63, 15.77"); }
hostR7:CenterHost { @display("p=134.22, 67.78"); }
hostR8:CenterHost { @display("p=88.1, 105.48"); }
hostR9:CenterHost { @display("p=171.16, 135.52"); }
hostR10:CenterHost { @display("p=208.31, 56.65"); }
hostR11:CenterHost { @display("p=211.29, 59.24"); }
hostR12:CenterHost { @display("p=313.52, 3.06"); }
hostR13:CenterHost { @display("p=50.69, 102.37"); }
hostR14:CenterHost { @display("p=49.76, 38.9"); }
hostR15:CenterHost { @display("p=111.46, 209.38"); }
hostR16:CenterHost { @display("p=266.83, 331.24"); }
hostR17:CenterHost { @display("p=248.6, 286.36"); }
hostR18:CenterHost { @display("p=180.00, 180.00"); isCenter=true; }
}