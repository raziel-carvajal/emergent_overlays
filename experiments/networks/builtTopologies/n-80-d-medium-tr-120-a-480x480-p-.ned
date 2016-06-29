import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network n-80-d-medium-tr-120-a-480x480-p-
{
@display("bgb=480,480");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=48.18, 69.76"); }
hostR1:CenterHost { @display("p=29.76, 55.12"); }
hostR2:CenterHost { @display("p=13.9, 106.0"); }
hostR3:CenterHost { @display("p=102.79, 29.14"); }
hostR4:CenterHost { @display("p=89.05, 40.05"); }
hostR5:CenterHost { @display("p=112.62, 73.89"); }
hostR6:CenterHost { @display("p=56.34, 101.73"); }
hostR7:CenterHost { @display("p=80.26, 115.36"); }
hostR8:CenterHost { @display("p=36.32, 114.41"); }
hostR9:CenterHost { @display("p=6.75, 90.07"); }
hostR10:CenterHost { @display("p=33.85, 311.84"); }
hostR11:CenterHost { @display("p=87.79, 47.15"); }
hostR12:CenterHost { @display("p=117.92, 116.07"); }
hostR13:CenterHost { @display("p=20.31, 127.34"); }
hostR14:CenterHost { @display("p=26.98, 160.61"); }
hostR15:CenterHost { @display("p=84.8, 154.62"); }
hostR16:CenterHost { @display("p=68.66, 185.11"); }
hostR17:CenterHost { @display("p=81.94, 198.79"); }
hostR18:CenterHost { @display("p=82.64, 275.54"); }
hostR19:CenterHost { @display("p=66.84, 210.87"); }
hostR20:CenterHost { @display("p=8.4, 71.87"); }
hostR21:CenterHost { @display("p=88.81, 79.81"); }
hostR22:CenterHost { @display("p=71.37, 58.22"); }
hostR23:CenterHost { @display("p=51.16, 76.44"); }
hostR24:CenterHost { @display("p=233.6, 107.45"); }
hostR25:CenterHost { @display("p=203.96, 205.17"); }
hostR26:CenterHost { @display("p=146.11, 155.03"); }
hostR27:CenterHost { @display("p=67.61, 40.5"); }
hostR28:CenterHost { @display("p=221.95, 116.31"); }
hostR29:CenterHost { @display("p=104.8, 6.15"); }
hostR30:CenterHost { @display("p=190.9, 76.74"); }
hostR31:CenterHost { @display("p=145.12, 95.97"); }
hostR32:CenterHost { @display("p=173.51, 145.68"); }
hostR33:CenterHost { @display("p=152.31, 236.45"); }
hostR34:CenterHost { @display("p=182.74, 0.69"); }
hostR35:CenterHost { @display("p=133.13, 416.53"); }
hostR36:CenterHost { @display("p=10.56, 2.55"); }
hostR37:CenterHost { @display("p=86.57, 22.79"); }
hostR38:CenterHost { @display("p=76.13, 478.54"); }
hostR39:CenterHost { @display("p=138.32, 391.06"); }
hostR40:CenterHost { @display("p=215.01, 56.92"); }
hostR41:CenterHost { @display("p=27.28, 37.86"); }
hostR42:CenterHost { @display("p=340.73, 39.34"); }
hostR43:CenterHost { @display("p=165.29, 38.63"); }
hostR44:CenterHost { @display("p=98.77, 9.34"); }
hostR45:CenterHost { @display("p=154.65, 164.48"); }
hostR46:CenterHost { @display("p=192.05, 218.69"); }
hostR47:CenterHost { @display("p=52.16, 57.76"); }
hostR48:CenterHost { @display("p=332.83, 167.29"); }
hostR49:CenterHost { @display("p=26.48, 216.99"); }
hostR50:CenterHost { @display("p=191.81, 235.85"); }
hostR51:CenterHost { @display("p=167.48, 82.94"); }
hostR52:CenterHost { @display("p=192.84, 286.61"); }
hostR53:CenterHost { @display("p=3.41, 177.28"); }
hostR54:CenterHost { @display("p=190.82, 286.53"); }
hostR55:CenterHost { @display("p=79.68, 475.65"); }
hostR56:CenterHost { @display("p=127.75, 208.82"); }
hostR57:CenterHost { @display("p=318.56, 375.39"); }
hostR58:CenterHost { @display("p=2.0, 211.69"); }
hostR59:CenterHost { @display("p=88.7, 271.69"); }
hostR60:CenterHost { @display("p=382.28, 100.17"); }
hostR61:CenterHost { @display("p=455.94, 2.92"); }
hostR62:CenterHost { @display("p=197.31, 94.52"); }
hostR63:CenterHost { @display("p=462.59, 28.25"); }
hostR64:CenterHost { @display("p=331.47, 65.01"); }
hostR65:CenterHost { @display("p=226.28, 77.33"); }
hostR66:CenterHost { @display("p=166.22, 62.16"); }
hostR67:CenterHost { @display("p=161.74, 0.98"); }
hostR68:CenterHost { @display("p=210.59, 12.82"); }
hostR69:CenterHost { @display("p=79.65, 5.33"); }
hostR70:CenterHost { @display("p=26.5, 302.96"); }
hostR71:CenterHost { @display("p=24.26, 311.31"); }
hostR72:CenterHost { @display("p=415.27, 274.09"); }
hostR73:CenterHost { @display("p=451.17, 65.68"); }
hostR74:CenterHost { @display("p=405.85, 89.55"); }
hostR75:CenterHost { @display("p=441.31, 288.42"); }
hostR76:CenterHost { @display("p=298.63, 323.79"); }
hostR77:CenterHost { @display("p=166.6, 223.62"); }
hostR78:CenterHost { @display("p=359.83, 103.42"); }
hostR79:CenterHost { @display("p=376.99, 228.77"); }
hostR80:CenterHost { @display("p=240.00, 240.00"); isCenter=true; }
}