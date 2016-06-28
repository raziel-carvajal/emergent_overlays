import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network n-40-d-dense-tr-120-a-240x240-p-
{
@display("bgb=240,240");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=79.7, 107.51"); }
hostR1:CenterHost { @display("p=28.12, 28.5"); }
hostR2:CenterHost { @display("p=117.51, 63.46"); }
hostR3:CenterHost { @display("p=70.55, 33.65"); }
hostR4:CenterHost { @display("p=50.21, 115.32"); }
hostR5:CenterHost { @display("p=5.67, 9.86"); }
hostR6:CenterHost { @display("p=111.32, 112.68"); }
hostR7:CenterHost { @display("p=97.97, 62.36"); }
hostR8:CenterHost { @display("p=2.51, 22.77"); }
hostR9:CenterHost { @display("p=116.97, 28.09"); }
hostR10:CenterHost { @display("p=104.1, 238.15"); }
hostR11:CenterHost { @display("p=77.86, 31.12"); }
hostR12:CenterHost { @display("p=73.03, 4.76"); }
hostR13:CenterHost { @display("p=90.1, 111.47"); }
hostR14:CenterHost { @display("p=44.88, 101.51"); }
hostR15:CenterHost { @display("p=73.3, 68.36"); }
hostR16:CenterHost { @display("p=79.54, 98.32"); }
hostR17:CenterHost { @display("p=38.22, 196.46"); }
hostR18:CenterHost { @display("p=59.46, 162.63"); }
hostR19:CenterHost { @display("p=1.65, 20.81"); }
hostR20:CenterHost { @display("p=163.92, 68.9"); }
hostR21:CenterHost { @display("p=119.82, 2.34"); }
hostR22:CenterHost { @display("p=113.16, 18.26"); }
hostR23:CenterHost { @display("p=34.97, 98.86"); }
hostR24:CenterHost { @display("p=32.29, 100.68"); }
hostR25:CenterHost { @display("p=200.32, 36.24"); }
hostR26:CenterHost { @display("p=224.58, 90.3"); }
hostR27:CenterHost { @display("p=103.36, 58.87"); }
hostR28:CenterHost { @display("p=1.85, 23.8"); }
hostR29:CenterHost { @display("p=188.36, 91.44"); }
hostR30:CenterHost { @display("p=20.36, 67.26"); }
hostR31:CenterHost { @display("p=193.48, 112.29"); }
hostR32:CenterHost { @display("p=145.31, 119.84"); }
hostR33:CenterHost { @display("p=207.08, 66.94"); }
hostR34:CenterHost { @display("p=163.14, 213.8"); }
hostR35:CenterHost { @display("p=40.0, 63.67"); }
hostR36:CenterHost { @display("p=19.45, 54.03"); }
hostR37:CenterHost { @display("p=31.44, 28.87"); }
hostR38:CenterHost { @display("p=31.26, 231.17"); }
hostR39:CenterHost { @display("p=75.58, 141.84"); }
hostR40:CenterHost { @display("p=120.00, 120.00"); isCenter=true; }
}