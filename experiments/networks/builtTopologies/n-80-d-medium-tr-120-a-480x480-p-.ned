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
hostR0:CenterHost { @display("p=102.42, 106.93"); }
hostR1:CenterHost { @display("p=87.27, 85.6"); }
hostR2:CenterHost { @display("p=43.78, 97.99"); }
hostR3:CenterHost { @display("p=88.92, 20.82"); }
hostR4:CenterHost { @display("p=97.65, 13.18"); }
hostR5:CenterHost { @display("p=80.56, 122.98"); }
hostR6:CenterHost { @display("p=100.13, 233.65"); }
hostR7:CenterHost { @display("p=60.81, 34.62"); }
hostR8:CenterHost { @display("p=26.47, 72.58"); }
hostR9:CenterHost { @display("p=2.65, 104.78"); }
hostR10:CenterHost { @display("p=115.18, 292.48"); }
hostR11:CenterHost { @display("p=36.68, 25.22"); }
hostR12:CenterHost { @display("p=17.69, 82.05"); }
hostR13:CenterHost { @display("p=91.83, 287.65"); }
hostR14:CenterHost { @display("p=41.7, 84.15"); }
hostR15:CenterHost { @display("p=88.8, 454.15"); }
hostR16:CenterHost { @display("p=3.16, 220.78"); }
hostR17:CenterHost { @display("p=19.55, 280.36"); }
hostR18:CenterHost { @display("p=4.66, 351.56"); }
hostR19:CenterHost { @display("p=16.76, 473.37"); }
hostR20:CenterHost { @display("p=121.34, 54.19"); }
hostR21:CenterHost { @display("p=11.42, 50.88"); }
hostR22:CenterHost { @display("p=115.74, 52.31"); }
hostR23:CenterHost { @display("p=170.37, 109.96"); }
hostR24:CenterHost { @display("p=156.84, 101.84"); }
hostR25:CenterHost { @display("p=160.46, 72.47"); }
hostR26:CenterHost { @display("p=229.94, 86.49"); }
hostR27:CenterHost { @display("p=53.12, 221.17"); }
hostR28:CenterHost { @display("p=42.14, 169.65"); }
hostR29:CenterHost { @display("p=24.25, 77.14"); }
hostR30:CenterHost { @display("p=209.17, 212.26"); }
hostR31:CenterHost { @display("p=0.56, 216.78"); }
hostR32:CenterHost { @display("p=218.66, 40.01"); }
hostR33:CenterHost { @display("p=125.18, 300.55"); }
hostR34:CenterHost { @display("p=186.76, 19.65"); }
hostR35:CenterHost { @display("p=47.48, 235.37"); }
hostR36:CenterHost { @display("p=44.73, 20.21"); }
hostR37:CenterHost { @display("p=60.45, 22.63"); }
hostR38:CenterHost { @display("p=39.32, 141.35"); }
hostR39:CenterHost { @display("p=190.97, 266.58"); }
hostR40:CenterHost { @display("p=346.78, 85.03"); }
hostR41:CenterHost { @display("p=225.18, 110.81"); }
hostR42:CenterHost { @display("p=52.04, 38.45"); }
hostR43:CenterHost { @display("p=131.97, 78.08"); }
hostR44:CenterHost { @display("p=143.3, 73.33"); }
hostR45:CenterHost { @display("p=44.88, 30.7"); }
hostR46:CenterHost { @display("p=130.41, 164.87"); }
hostR47:CenterHost { @display("p=93.98, 10.1"); }
hostR48:CenterHost { @display("p=18.81, 186.91"); }
hostR49:CenterHost { @display("p=250.56, 35.4"); }
hostR50:CenterHost { @display("p=72.03, 107.81"); }
hostR51:CenterHost { @display("p=27.78, 314.32"); }
hostR52:CenterHost { @display("p=80.93, 228.42"); }
hostR53:CenterHost { @display("p=152.19, 233.22"); }
hostR54:CenterHost { @display("p=262.25, 246.18"); }
hostR55:CenterHost { @display("p=0.88, 169.67"); }
hostR56:CenterHost { @display("p=101.38, 444.38"); }
hostR57:CenterHost { @display("p=64.82, 115.6"); }
hostR58:CenterHost { @display("p=104.03, 279.12"); }
hostR59:CenterHost { @display("p=96.78, 264.8"); }
hostR60:CenterHost { @display("p=275.16, 30.04"); }
hostR61:CenterHost { @display("p=321.01, 52.73"); }
hostR62:CenterHost { @display("p=372.06, 80.8"); }
hostR63:CenterHost { @display("p=14.89, 25.88"); }
hostR64:CenterHost { @display("p=150.85, 53.49"); }
hostR65:CenterHost { @display("p=154.44, 34.09"); }
hostR66:CenterHost { @display("p=167.29, 204.3"); }
hostR67:CenterHost { @display("p=15.46, 41.38"); }
hostR68:CenterHost { @display("p=164.33, 214.84"); }
hostR69:CenterHost { @display("p=164.68, 185.39"); }
hostR70:CenterHost { @display("p=214.36, 238.16"); }
hostR71:CenterHost { @display("p=255.58, 183.34"); }
hostR72:CenterHost { @display("p=11.39, 129.11"); }
hostR73:CenterHost { @display("p=173.34, 331.33"); }
hostR74:CenterHost { @display("p=342.15, 269.47"); }
hostR75:CenterHost { @display("p=452.65, 191.01"); }
hostR76:CenterHost { @display("p=389.94, 166.21"); }
hostR77:CenterHost { @display("p=159.04, 336.69"); }
hostR78:CenterHost { @display("p=415.23, 10.46"); }
hostR79:CenterHost { @display("p=245.3, 426.13"); }
hostR80:CenterHost { @display("p=240.00, 240.00"); isCenter=true; }
}