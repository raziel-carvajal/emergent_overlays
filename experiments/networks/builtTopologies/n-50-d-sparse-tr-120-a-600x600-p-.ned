import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network n-50-d-sparse-tr-120-a-600x600-p-
{
@display("bgb=600,600");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=7.02, 24.5"); }
hostR1:CenterHost { @display("p=67.15, 110.58"); }
hostR2:CenterHost { @display("p=7.78, 90.75"); }
hostR3:CenterHost { @display("p=32.04, 120.97"); }
hostR4:CenterHost { @display("p=88.01, 18.38"); }
hostR5:CenterHost { @display("p=65.54, 315.72"); }
hostR6:CenterHost { @display("p=118.56, 4.49"); }
hostR7:CenterHost { @display("p=67.73, 358.29"); }
hostR8:CenterHost { @display("p=95.6, 49.59"); }
hostR9:CenterHost { @display("p=50.9, 149.67"); }
hostR10:CenterHost { @display("p=100.7, 25.36"); }
hostR11:CenterHost { @display("p=157.18, 21.22"); }
hostR12:CenterHost { @display("p=232.13, 227.34"); }
hostR13:CenterHost { @display("p=103.24, 73.98"); }
hostR14:CenterHost { @display("p=157.37, 41.95"); }
hostR15:CenterHost { @display("p=215.83, 85.69"); }
hostR16:CenterHost { @display("p=181.83, 260.89"); }
hostR17:CenterHost { @display("p=48.64, 99.56"); }
hostR18:CenterHost { @display("p=193.24, 535.66"); }
hostR19:CenterHost { @display("p=138.45, 101.19"); }
hostR20:CenterHost { @display("p=98.25, 23.79"); }
hostR21:CenterHost { @display("p=323.65, 24.49"); }
hostR22:CenterHost { @display("p=112.96, 126.7"); }
hostR23:CenterHost { @display("p=67.79, 45.76"); }
hostR24:CenterHost { @display("p=320.22, 253.63"); }
hostR25:CenterHost { @display("p=200.06, 37.87"); }
hostR26:CenterHost { @display("p=17.88, 68.77"); }
hostR27:CenterHost { @display("p=273.12, 200.46"); }
hostR28:CenterHost { @display("p=155.41, 13.07"); }
hostR29:CenterHost { @display("p=308.02, 12.9"); }
hostR30:CenterHost { @display("p=102.37, 36.44"); }
hostR31:CenterHost { @display("p=465.33, 111.39"); }
hostR32:CenterHost { @display("p=473.55, 116.78"); }
hostR33:CenterHost { @display("p=155.28, 96.96"); }
hostR34:CenterHost { @display("p=376.51, 310.39"); }
hostR35:CenterHost { @display("p=244.32, 286.58"); }
hostR36:CenterHost { @display("p=215.8, 54.39"); }
hostR37:CenterHost { @display("p=25.7, 156.43"); }
hostR38:CenterHost { @display("p=300.45, 490.61"); }
hostR39:CenterHost { @display("p=154.21, 240.1"); }
hostR40:CenterHost { @display("p=521.25, 79.83"); }
hostR41:CenterHost { @display("p=530.35, 105.91"); }
hostR42:CenterHost { @display("p=235.67, 14.11"); }
hostR43:CenterHost { @display("p=579.26, 165.96"); }
hostR44:CenterHost { @display("p=309.78, 253.38"); }
hostR45:CenterHost { @display("p=298.36, 107.58"); }
hostR46:CenterHost { @display("p=14.66, 249.74"); }
hostR47:CenterHost { @display("p=482.62, 283.6"); }
hostR48:CenterHost { @display("p=281.59, 306.93"); }
hostR49:CenterHost { @display("p=497.47, 114.19"); }
hostR50:CenterHost { @display("p=300.00, 300.00"); isCenter=true; }
}