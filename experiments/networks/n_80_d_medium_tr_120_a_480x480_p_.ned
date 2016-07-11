import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import broadcasting.CenterHost;
network n_80_d_medium_tr_120_a_480x480_p_
{
@display("bgb=480,480");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=104.52, 25.19"); }
hostR1:CenterHost { @display("p=9.79, 69.53"); }
hostR2:CenterHost { @display("p=97.7, 54.22"); }
hostR3:CenterHost { @display("p=17.94, 19.35"); }
hostR4:CenterHost { @display("p=111.41, 46.96"); }
hostR5:CenterHost { @display("p=73.63, 164.85"); }
hostR6:CenterHost { @display("p=10.97, 36.14"); }
hostR7:CenterHost { @display("p=28.06, 9.36"); }
hostR8:CenterHost { @display("p=46.26, 229.47"); }
hostR9:CenterHost { @display("p=18.54, 14.07"); }
hostR10:CenterHost { @display("p=114.79, 302.55"); }
hostR11:CenterHost { @display("p=84.02, 186.01"); }
hostR12:CenterHost { @display("p=53.69, 265.96"); }
hostR13:CenterHost { @display("p=98.46, 131.77"); }
hostR14:CenterHost { @display("p=46.85, 154.33"); }
hostR15:CenterHost { @display("p=32.15, 27.27"); }
hostR16:CenterHost { @display("p=50.81, 381.23"); }
hostR17:CenterHost { @display("p=109.89, 57.57"); }
hostR18:CenterHost { @display("p=68.01, 111.89"); }
hostR19:CenterHost { @display("p=115.84, 158.52"); }
hostR20:CenterHost { @display("p=42.43, 83.01"); }
hostR21:CenterHost { @display("p=190.19, 33.59"); }
hostR22:CenterHost { @display("p=170.34, 40.19"); }
hostR23:CenterHost { @display("p=225.27, 46.43"); }
hostR24:CenterHost { @display("p=200.76, 71.31"); }
hostR25:CenterHost { @display("p=151.53, 207.95"); }
hostR26:CenterHost { @display("p=214.89, 55.23"); }
hostR27:CenterHost { @display("p=101.2, 95.45"); }
hostR28:CenterHost { @display("p=53.92, 34.34"); }
hostR29:CenterHost { @display("p=185.63, 126.65"); }
hostR30:CenterHost { @display("p=121.34, 0.73"); }
hostR31:CenterHost { @display("p=25.94, 11.88"); }
hostR32:CenterHost { @display("p=174.95, 218.69"); }
hostR33:CenterHost { @display("p=209.68, 283.05"); }
hostR34:CenterHost { @display("p=60.95, 269.2"); }
hostR35:CenterHost { @display("p=112.65, 424.2"); }
hostR36:CenterHost { @display("p=167.82, 301.86"); }
hostR37:CenterHost { @display("p=5.01, 373.92"); }
hostR38:CenterHost { @display("p=212.58, 401.11"); }
hostR39:CenterHost { @display("p=235.34, 404.92"); }
hostR40:CenterHost { @display("p=61.28, 89.54"); }
hostR41:CenterHost { @display("p=222.12, 84.31"); }
hostR42:CenterHost { @display("p=223.2, 43.97"); }
hostR43:CenterHost { @display("p=36.11, 0.26"); }
hostR44:CenterHost { @display("p=260.14, 113.46"); }
hostR45:CenterHost { @display("p=214.74, 116.96"); }
hostR46:CenterHost { @display("p=300.67, 87.6"); }
hostR47:CenterHost { @display("p=54.79, 230.14"); }
hostR48:CenterHost { @display("p=335.35, 227.25"); }
hostR49:CenterHost { @display("p=56.11, 24.89"); }
hostR50:CenterHost { @display("p=75.73, 89.89"); }
hostR51:CenterHost { @display("p=113.15, 209.06"); }
hostR52:CenterHost { @display("p=356.53, 154.53"); }
hostR53:CenterHost { @display("p=257.09, 43.08"); }
hostR54:CenterHost { @display("p=173.29, 232.87"); }
hostR55:CenterHost { @display("p=187.22, 9.34"); }
hostR56:CenterHost { @display("p=179.52, 420.78"); }
hostR57:CenterHost { @display("p=141.27, 311.7"); }
hostR58:CenterHost { @display("p=318.89, 346.73"); }
hostR59:CenterHost { @display("p=307.74, 76.48"); }
hostR60:CenterHost { @display("p=99.77, 100.81"); }
hostR61:CenterHost { @display("p=109.87, 23.65"); }
hostR62:CenterHost { @display("p=331.87, 62.88"); }
hostR63:CenterHost { @display("p=398.03, 99.78"); }
hostR64:CenterHost { @display("p=30.33, 113.74"); }
hostR65:CenterHost { @display("p=42.97, 107.36"); }
hostR66:CenterHost { @display("p=471.65, 0.98"); }
hostR67:CenterHost { @display("p=141.39, 90.86"); }
hostR68:CenterHost { @display("p=405.96, 127.53"); }
hostR69:CenterHost { @display("p=162.05, 210.64"); }
hostR70:CenterHost { @display("p=440.46, 41.46"); }
hostR71:CenterHost { @display("p=62.98, 255.87"); }
hostR72:CenterHost { @display("p=209.83, 260.68"); }
hostR73:CenterHost { @display("p=392.74, 32.29"); }
hostR74:CenterHost { @display("p=246.95, 248.16"); }
hostR75:CenterHost { @display("p=406.22, 309.47"); }
hostR76:CenterHost { @display("p=188.12, 299.98"); }
hostR77:CenterHost { @display("p=222.89, 401.57"); }
hostR78:CenterHost { @display("p=48.88, 117.48"); }
hostR79:CenterHost { @display("p=208.24, 133.61"); }
hostR80:CenterHost { @display("p=240.00, 240.00"); isCenter=true; }
}
