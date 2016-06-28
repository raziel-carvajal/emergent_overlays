import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network n-72-d-sparse-tr-120-a-720x720-p-
{
@display("bgb=720,720");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=73.14, 111.63"); }
hostR1:CenterHost { @display("p=73.39, 92.68"); }
hostR2:CenterHost { @display("p=111.66, 98.93"); }
hostR3:CenterHost { @display("p=12.04, 192.58"); }
hostR4:CenterHost { @display("p=6.77, 318.42"); }
hostR5:CenterHost { @display("p=51.58, 202.79"); }
hostR6:CenterHost { @display("p=0.97, 317.31"); }
hostR7:CenterHost { @display("p=90.48, 293.68"); }
hostR8:CenterHost { @display("p=85.63, 320.39"); }
hostR9:CenterHost { @display("p=57.77, 354.71"); }
hostR10:CenterHost { @display("p=59.06, 389.8"); }
hostR11:CenterHost { @display("p=71.63, 382.09"); }
hostR12:CenterHost { @display("p=56.42, 48.59"); }
hostR13:CenterHost { @display("p=11.13, 27.23"); }
hostR14:CenterHost { @display("p=121.47, 64.38"); }
hostR15:CenterHost { @display("p=175.39, 6.24"); }
hostR16:CenterHost { @display("p=30.39, 17.96"); }
hostR17:CenterHost { @display("p=158.78, 239.05"); }
hostR18:CenterHost { @display("p=191.31, 2.96"); }
hostR19:CenterHost { @display("p=101.51, 200.75"); }
hostR20:CenterHost { @display("p=103.55, 392.37"); }
hostR21:CenterHost { @display("p=196.17, 408.23"); }
hostR22:CenterHost { @display("p=46.37, 433.53"); }
hostR23:CenterHost { @display("p=167.38, 542.05"); }
hostR24:CenterHost { @display("p=329.95, 95.03"); }
hostR25:CenterHost { @display("p=81.02, 109.01"); }
hostR26:CenterHost { @display("p=88.86, 17.04"); }
hostR27:CenterHost { @display("p=134.15, 106.09"); }
hostR28:CenterHost { @display("p=180.92, 140.87"); }
hostR29:CenterHost { @display("p=240.15, 258.82"); }
hostR30:CenterHost { @display("p=136.33, 363.08"); }
hostR31:CenterHost { @display("p=277.04, 259.99"); }
hostR32:CenterHost { @display("p=349.51, 290.27"); }
hostR33:CenterHost { @display("p=173.74, 516.97"); }
hostR34:CenterHost { @display("p=358.7, 169.35"); }
hostR35:CenterHost { @display("p=39.54, 160.28"); }
hostR36:CenterHost { @display("p=249.72, 14.53"); }
hostR37:CenterHost { @display("p=465.71, 77.89"); }
hostR38:CenterHost { @display("p=86.35, 131.23"); }
hostR39:CenterHost { @display("p=248.13, 138.01"); }
hostR40:CenterHost { @display("p=154.97, 225.53"); }
hostR41:CenterHost { @display("p=5.62, 254.71"); }
hostR42:CenterHost { @display("p=137.69, 144.96"); }
hostR43:CenterHost { @display("p=129.15, 359.54"); }
hostR44:CenterHost { @display("p=269.25, 251.85"); }
hostR45:CenterHost { @display("p=65.92, 582.61"); }
hostR46:CenterHost { @display("p=394.2, 111.73"); }
hostR47:CenterHost { @display("p=395.26, 394.96"); }
hostR48:CenterHost { @display("p=351.38, 111.13"); }
hostR49:CenterHost { @display("p=390.63, 116.12"); }
hostR50:CenterHost { @display("p=393.29, 86.28"); }
hostR51:CenterHost { @display("p=151.4, 34.93"); }
hostR52:CenterHost { @display("p=568.61, 130.07"); }
hostR53:CenterHost { @display("p=108.01, 155.43"); }
hostR54:CenterHost { @display("p=250.93, 84.4"); }
hostR55:CenterHost { @display("p=72.72, 59.09"); }
hostR56:CenterHost { @display("p=190.28, 269.55"); }
hostR57:CenterHost { @display("p=435.83, 261.94"); }
hostR58:CenterHost { @display("p=506.51, 587.11"); }
hostR59:CenterHost { @display("p=541.13, 19.15"); }
hostR60:CenterHost { @display("p=396.17, 110.4"); }
hostR61:CenterHost { @display("p=179.28, 64.11"); }
hostR62:CenterHost { @display("p=718.3, 171.06"); }
hostR63:CenterHost { @display("p=306.78, 121.0"); }
hostR64:CenterHost { @display("p=241.49, 281.59"); }
hostR65:CenterHost { @display("p=9.95, 13.29"); }
hostR66:CenterHost { @display("p=423.63, 71.88"); }
hostR67:CenterHost { @display("p=466.6, 268.01"); }
hostR68:CenterHost { @display("p=555.07, 60.15"); }
hostR69:CenterHost { @display("p=290.49, 67.53"); }
hostR70:CenterHost { @display("p=256.71, 58.06"); }
hostR71:CenterHost { @display("p=33.38, 414.99"); }
hostR72:CenterHost { @display("p=360.00, 360.00"); isCenter=true; }
}