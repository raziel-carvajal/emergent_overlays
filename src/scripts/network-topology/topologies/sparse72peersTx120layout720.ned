import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network sparse72peersTx120layout720
{
@display("bgb=720,720");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=54.96, 8.41"); }
hostR1:CenterHost { @display("p=96.91, 49.67"); }
hostR2:CenterHost { @display("p=83.64, 223.07"); }
hostR3:CenterHost { @display("p=33.99, 126.69"); }
hostR4:CenterHost { @display("p=60.1, 48.89"); }
hostR5:CenterHost { @display("p=103.59, 188.25"); }
hostR6:CenterHost { @display("p=1.94, 336.07"); }
hostR7:CenterHost { @display("p=54.06, 420.63"); }
hostR8:CenterHost { @display("p=40.99, 317.58"); }
hostR9:CenterHost { @display("p=83.44, 205.85"); }
hostR10:CenterHost { @display("p=68.69, 1.86"); }
hostR11:CenterHost { @display("p=1.53, 359.25"); }
hostR12:CenterHost { @display("p=34.49, 110.17"); }
hostR13:CenterHost { @display("p=47.71, 98.03"); }
hostR14:CenterHost { @display("p=161.05, 126.95"); }
hostR15:CenterHost { @display("p=206.42, 179.87"); }
hostR16:CenterHost { @display("p=195.15, 208.39"); }
hostR17:CenterHost { @display("p=115.59, 216.69"); }
hostR18:CenterHost { @display("p=33.63, 156.03"); }
hostR19:CenterHost { @display("p=121.9, 364.71"); }
hostR20:CenterHost { @display("p=79.04, 71.57"); }
hostR21:CenterHost { @display("p=166.67, 3.79"); }
hostR22:CenterHost { @display("p=116.8, 305.34"); }
hostR23:CenterHost { @display("p=23.34, 453.88"); }
hostR24:CenterHost { @display("p=142.15, 16.27"); }
hostR25:CenterHost { @display("p=281.93, 102.19"); }
hostR26:CenterHost { @display("p=144.96, 129.98"); }
hostR27:CenterHost { @display("p=221.16, 231.25"); }
hostR28:CenterHost { @display("p=131.85, 309.64"); }
hostR29:CenterHost { @display("p=122.18, 129.49"); }
hostR30:CenterHost { @display("p=212.97, 111.17"); }
hostR31:CenterHost { @display("p=155.49, 104.97"); }
hostR32:CenterHost { @display("p=233.45, 567.85"); }
hostR33:CenterHost { @display("p=125.83, 187.44"); }
hostR34:CenterHost { @display("p=229.56, 69.38"); }
hostR35:CenterHost { @display("p=210.95, 673.29"); }
hostR36:CenterHost { @display("p=188.81, 9.15"); }
hostR37:CenterHost { @display("p=67.72, 28.58"); }
hostR38:CenterHost { @display("p=462.14, 112.52"); }
hostR39:CenterHost { @display("p=54.31, 157.48"); }
hostR40:CenterHost { @display("p=331.08, 332.35"); }
hostR41:CenterHost { @display("p=351.29, 77.0"); }
hostR42:CenterHost { @display("p=180.56, 321.77"); }
hostR43:CenterHost { @display("p=107.67, 366.53"); }
hostR44:CenterHost { @display("p=322.96, 380.87"); }
hostR45:CenterHost { @display("p=414.63, 499.97"); }
hostR46:CenterHost { @display("p=63.91, 717.92"); }
hostR47:CenterHost { @display("p=451.25, 159.04"); }
hostR48:CenterHost { @display("p=146.39, 52.75"); }
hostR49:CenterHost { @display("p=551.95, 63.28"); }
hostR50:CenterHost { @display("p=533.67, 56.13"); }
hostR51:CenterHost { @display("p=537.42, 30.85"); }
hostR52:CenterHost { @display("p=230.72, 50.85"); }
hostR53:CenterHost { @display("p=10.33, 107.39"); }
hostR54:CenterHost { @display("p=83.33, 264.62"); }
hostR55:CenterHost { @display("p=552.2, 417.43"); }
hostR56:CenterHost { @display("p=241.09, 57.98"); }
hostR57:CenterHost { @display("p=586.98, 6.77"); }
hostR58:CenterHost { @display("p=549.46, 18.26"); }
hostR59:CenterHost { @display("p=538.5, 44.38"); }
hostR60:CenterHost { @display("p=5.95, 108.62"); }
hostR61:CenterHost { @display("p=279.57, 19.48"); }
hostR62:CenterHost { @display("p=595.9, 78.66"); }
hostR63:CenterHost { @display("p=326.42, 75.63"); }
hostR64:CenterHost { @display("p=273.29, 167.09"); }
hostR65:CenterHost { @display("p=52.88, 53.09"); }
hostR66:CenterHost { @display("p=666.36, 300.75"); }
hostR67:CenterHost { @display("p=163.06, 136.15"); }
hostR68:CenterHost { @display("p=347.22, 307.47"); }
hostR69:CenterHost { @display("p=694.61, 210.44"); }
hostR70:CenterHost { @display("p=311.59, 114.79"); }
hostR71:CenterHost { @display("p=381.02, 579.5"); }
hostR72:CenterHost { @display("p=360.00, 360.00"); isCenter=true; }
}