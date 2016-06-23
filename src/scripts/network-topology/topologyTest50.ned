import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network topologyTest50
{
@display("bgb=200,200");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR1:CenterHost { @display("p=192.06, 175.22"); }
hostR2:CenterHost { @display("p=103.46, 98.01"); }
hostR3:CenterHost { @display("p=56.10, 50.36"); }
hostR4:CenterHost { @display("p=95.44, 160.97"); }
hostR5:CenterHost { @display("p=157.56, 105.83"); }
hostR6:CenterHost { @display("p=97.50, 131.97"); }
hostR7:CenterHost { @display("p=30.45, 124.51"); }
hostR8:CenterHost { @display("p=16.09, 67.59"); }
hostR9:CenterHost { @display("p=34.13, 89.06"); }
hostR10:CenterHost { @display("p=143.23, 0.24"); }
hostR11:CenterHost { @display("p=131.49, 103.51"); }
hostR12:CenterHost { @display("p=75.13, 190.53"); }
hostR13:CenterHost { @display("p=198.47, 164.13"); }
hostR14:CenterHost { @display("p=33.84, 56.99"); }
hostR15:CenterHost { @display("p=128.95, 133.96"); }
hostR16:CenterHost { @display("p=164.25, 83.12"); }
hostR17:CenterHost { @display("p=181.56, 175.31"); }
hostR18:CenterHost { @display("p=178.71, 46.17"); }
hostR19:CenterHost { @display("p=195.34, 85.89"); }
hostR20:CenterHost { @display("p=98.66, 128.68"); }
hostR21:CenterHost { @display("p=76.97, 105.42"); }
hostR22:CenterHost { @display("p=150.64, 88.10"); }
hostR23:CenterHost { @display("p=91.64, 42.88"); }
hostR24:CenterHost { @display("p=139.67, 1.32"); }
hostR25:CenterHost { @display("p=27.04, 45.08"); }
hostR26:CenterHost { @display("p=102.44, 67.58"); }
hostR27:CenterHost { @display("p=193.94, 65.11"); }
hostR28:CenterHost { @display("p=110.48, 52.70"); }
hostR29:CenterHost { @display("p=169.24, 175.78"); }
hostR30:CenterHost { @display("p=5.67, 42.40"); }
hostR31:CenterHost { @display("p=13.61, 70.94"); }
hostR32:CenterHost { @display("p=88.31, 192.59"); }
hostR33:CenterHost { @display("p=55.33, 174.42"); }
hostR34:CenterHost { @display("p=8.22, 59.91"); }
hostR35:CenterHost { @display("p=104.40, 183.00"); }
hostR36:CenterHost { @display("p=186.00, 118.06"); }
hostR37:CenterHost { @display("p=138.22, 0.47"); }
hostR38:CenterHost { @display("p=80.90, 185.07"); }
hostR39:CenterHost { @display("p=68.06, 65.81"); }
hostR40:CenterHost { @display("p=118.69, 170.59"); }
hostR41:CenterHost { @display("p=80.02, 169.08"); }
hostR42:CenterHost { @display("p=67.05, 12.43"); }
hostR43:CenterHost { @display("p=5.17, 21.94"); }
hostR44:CenterHost { @display("p=141.53, 166.91"); }
hostR45:CenterHost { @display("p=112.78, 91.04"); }
hostR46:CenterHost { @display("p=66.96, 178.45"); }
hostR47:CenterHost { @display("p=138.12, 22.78"); }
hostR48:CenterHost { @display("p=17.53, 66.55"); }
hostR49:CenterHost { @display("p=135.14, 157.33"); }
hostR50:CenterHost { @display("p=23.49, 177.06"); }
hostR51:CenterHost { @display("p=100.00, 100.00"); isCenter=true; }
}