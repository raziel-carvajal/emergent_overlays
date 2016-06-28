import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network n-32-d-sparse-tr-120-a-480x480-p-
{
@display("bgb=480,480");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=38.84, 6.63"); }
hostR1:CenterHost { @display("p=33.18, 41.41"); }
hostR2:CenterHost { @display("p=65.34, 48.97"); }
hostR3:CenterHost { @display("p=48.51, 192.84"); }
hostR4:CenterHost { @display("p=50.28, 273.13"); }
hostR5:CenterHost { @display("p=54.98, 132.38"); }
hostR6:CenterHost { @display("p=27.84, 289.82"); }
hostR7:CenterHost { @display("p=98.71, 184.44"); }
hostR8:CenterHost { @display("p=70.9, 26.04"); }
hostR9:CenterHost { @display("p=141.7, 118.41"); }
hostR10:CenterHost { @display("p=63.74, 104.9"); }
hostR11:CenterHost { @display("p=105.99, 142.38"); }
hostR12:CenterHost { @display("p=136.83, 330.34"); }
hostR13:CenterHost { @display("p=160.96, 240.84"); }
hostR14:CenterHost { @display("p=239.52, 25.08"); }
hostR15:CenterHost { @display("p=189.13, 180.69"); }
hostR16:CenterHost { @display("p=355.41, 92.97"); }
hostR17:CenterHost { @display("p=134.35, 68.68"); }
hostR18:CenterHost { @display("p=69.63, 75.31"); }
hostR19:CenterHost { @display("p=123.53, 94.76"); }
hostR20:CenterHost { @display("p=197.6, 333.75"); }
hostR21:CenterHost { @display("p=125.31, 140.39"); }
hostR22:CenterHost { @display("p=190.33, 133.06"); }
hostR23:CenterHost { @display("p=318.47, 216.74"); }
hostR24:CenterHost { @display("p=270.53, 91.79"); }
hostR25:CenterHost { @display("p=362.22, 56.55"); }
hostR26:CenterHost { @display("p=172.41, 185.69"); }
hostR27:CenterHost { @display("p=222.46, 69.78"); }
hostR28:CenterHost { @display("p=332.35, 95.09"); }
hostR29:CenterHost { @display("p=219.74, 327.04"); }
hostR30:CenterHost { @display("p=34.89, 240.69"); }
hostR31:CenterHost { @display("p=450.96, 161.6"); }
hostR32:CenterHost { @display("p=240.00, 240.00"); isCenter=true; }
}