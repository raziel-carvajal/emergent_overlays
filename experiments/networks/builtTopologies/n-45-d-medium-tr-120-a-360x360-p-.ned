import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network n-45-d-medium-tr-120-a-360x360-p-
{
@display("bgb=360,360");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=20.79, 71.37"); }
hostR1:CenterHost { @display("p=107.2, 111.76"); }
hostR2:CenterHost { @display("p=66.93, 37.91"); }
hostR3:CenterHost { @display("p=40.09, 100.85"); }
hostR4:CenterHost { @display("p=79.19, 113.11"); }
hostR5:CenterHost { @display("p=105.23, 6.96"); }
hostR6:CenterHost { @display("p=52.8, 59.69"); }
hostR7:CenterHost { @display("p=21.85, 51.17"); }
hostR8:CenterHost { @display("p=44.97, 0.81"); }
hostR9:CenterHost { @display("p=22.76, 7.6"); }
hostR10:CenterHost { @display("p=110.13, 257.22"); }
hostR11:CenterHost { @display("p=12.25, 37.86"); }
hostR12:CenterHost { @display("p=80.44, 270.8"); }
hostR13:CenterHost { @display("p=98.01, 108.04"); }
hostR14:CenterHost { @display("p=61.97, 285.24"); }
hostR15:CenterHost { @display("p=79.42, 82.03"); }
hostR16:CenterHost { @display("p=90.81, 37.34"); }
hostR17:CenterHost { @display("p=142.89, 85.69"); }
hostR18:CenterHost { @display("p=78.71, 78.39"); }
hostR19:CenterHost { @display("p=83.73, 109.68"); }
hostR20:CenterHost { @display("p=122.7, 126.8"); }
hostR21:CenterHost { @display("p=235.14, 195.24"); }
hostR22:CenterHost { @display("p=210.36, 1.71"); }
hostR23:CenterHost { @display("p=50.94, 83.78"); }
hostR24:CenterHost { @display("p=180.06, 76.19"); }
hostR25:CenterHost { @display("p=189.68, 138.18"); }
hostR26:CenterHost { @display("p=110.62, 310.34"); }
hostR27:CenterHost { @display("p=148.34, 129.54"); }
hostR28:CenterHost { @display("p=232.28, 263.19"); }
hostR29:CenterHost { @display("p=29.46, 255.35"); }
hostR30:CenterHost { @display("p=40.12, 86.12"); }
hostR31:CenterHost { @display("p=38.88, 12.26"); }
hostR32:CenterHost { @display("p=184.41, 50.21"); }
hostR33:CenterHost { @display("p=254.14, 52.47"); }
hostR34:CenterHost { @display("p=344.06, 19.65"); }
hostR35:CenterHost { @display("p=23.52, 187.14"); }
hostR36:CenterHost { @display("p=329.09, 208.23"); }
hostR37:CenterHost { @display("p=46.44, 180.85"); }
hostR38:CenterHost { @display("p=67.07, 232.48"); }
hostR39:CenterHost { @display("p=282.09, 164.54"); }
hostR40:CenterHost { @display("p=101.4, 351.17"); }
hostR41:CenterHost { @display("p=79.81, 359.84"); }
hostR42:CenterHost { @display("p=197.23, 271.79"); }
hostR43:CenterHost { @display("p=20.7, 174.99"); }
hostR44:CenterHost { @display("p=7.41, 325.69"); }
hostR45:CenterHost { @display("p=180.00, 180.00"); isCenter=true; }
}