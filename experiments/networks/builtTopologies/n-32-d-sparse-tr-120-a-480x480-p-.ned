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
hostR0:CenterHost { @display("p=56.69, 118.06"); }
hostR1:CenterHost { @display("p=96.47, 71.11"); }
hostR2:CenterHost { @display("p=97.25, 191.78"); }
hostR3:CenterHost { @display("p=70.92, 55.81"); }
hostR4:CenterHost { @display("p=107.07, 57.59"); }
hostR5:CenterHost { @display("p=74.34, 198.6"); }
hostR6:CenterHost { @display("p=23.89, 433.94"); }
hostR7:CenterHost { @display("p=111.14, 200.22"); }
hostR8:CenterHost { @display("p=204.3, 34.16"); }
hostR9:CenterHost { @display("p=4.96, 67.63"); }
hostR10:CenterHost { @display("p=216.39, 227.75"); }
hostR11:CenterHost { @display("p=138.95, 85.4"); }
hostR12:CenterHost { @display("p=68.47, 328.98"); }
hostR13:CenterHost { @display("p=122.25, 23.54"); }
hostR14:CenterHost { @display("p=198.79, 128.09"); }
hostR15:CenterHost { @display("p=222.52, 9.28"); }
hostR16:CenterHost { @display("p=62.11, 91.62"); }
hostR17:CenterHost { @display("p=196.64, 29.69"); }
hostR18:CenterHost { @display("p=282.06, 90.52"); }
hostR19:CenterHost { @display("p=238.37, 142.89"); }
hostR20:CenterHost { @display("p=231.5, 13.13"); }
hostR21:CenterHost { @display("p=167.82, 5.09"); }
hostR22:CenterHost { @display("p=30.21, 314.63"); }
hostR23:CenterHost { @display("p=64.97, 449.01"); }
hostR24:CenterHost { @display("p=231.06, 46.35"); }
hostR25:CenterHost { @display("p=303.21, 30.74"); }
hostR26:CenterHost { @display("p=239.26, 134.99"); }
hostR27:CenterHost { @display("p=27.74, 222.87"); }
hostR28:CenterHost { @display("p=88.77, 219.88"); }
hostR29:CenterHost { @display("p=406.97, 296.25"); }
hostR30:CenterHost { @display("p=167.69, 338.13"); }
hostR31:CenterHost { @display("p=48.02, 93.12"); }
hostR32:CenterHost { @display("p=240.00, 240.00"); isCenter=true; }
}