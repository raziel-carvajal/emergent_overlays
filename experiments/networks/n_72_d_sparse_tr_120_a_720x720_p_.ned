
import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import broadcasting.CenterHost;
network n_72_d_sparse_tr_120_a_720x720_p_
{
@display("bgb=720,720");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=107.8, 58.54"); }
hostR1:CenterHost { @display("p=70.72, 119.97"); }
hostR2:CenterHost { @display("p=20.21, 76.07"); }
hostR3:CenterHost { @display("p=42.94, 44.46"); }
hostR4:CenterHost { @display("p=81.82, 296.94"); }
hostR5:CenterHost { @display("p=115.07, 331.86"); }
hostR6:CenterHost { @display("p=115.5, 426.92"); }
hostR7:CenterHost { @display("p=38.1, 220.06"); }
hostR8:CenterHost { @display("p=93.83, 129.91"); }
hostR9:CenterHost { @display("p=20.16, 152.77"); }
hostR10:CenterHost { @display("p=107.89, 708.22"); }
hostR11:CenterHost { @display("p=1.25, 349.37"); }
hostR12:CenterHost { @display("p=96.12, 108.6"); }
hostR13:CenterHost { @display("p=194.51, 20.11"); }
hostR14:CenterHost { @display("p=1.22, 193.0"); }
hostR15:CenterHost { @display("p=129.75, 238.23"); }
hostR16:CenterHost { @display("p=164.0, 251.37"); }
hostR17:CenterHost { @display("p=169.25, 190.81"); }
hostR18:CenterHost { @display("p=182.99, 61.03"); }
hostR19:CenterHost { @display("p=101.43, 17.12"); }
hostR20:CenterHost { @display("p=104.36, 283.44"); }
hostR21:CenterHost { @display("p=203.09, 288.35"); }
hostR22:CenterHost { @display("p=214.75, 510.57"); }
hostR23:CenterHost { @display("p=105.62, 590.02"); }
hostR24:CenterHost { @display("p=338.94, 79.26"); }
hostR25:CenterHost { @display("p=259.63, 46.44"); }
hostR26:CenterHost { @display("p=174.03, 201.86"); }
hostR27:CenterHost { @display("p=135.74, 24.87"); }
hostR28:CenterHost { @display("p=35.53, 7.02"); }
hostR29:CenterHost { @display("p=310.98, 113.35"); }
hostR30:CenterHost { @display("p=16.01, 271.04"); }
hostR31:CenterHost { @display("p=225.43, 278.45"); }
hostR32:CenterHost { @display("p=209.7, 456.75"); }
hostR33:CenterHost { @display("p=287.47, 401.58"); }
hostR34:CenterHost { @display("p=296.99, 17.78"); }
hostR35:CenterHost { @display("p=299.96, 529.59"); }
hostR36:CenterHost { @display("p=69.44, 60.12"); }
hostR37:CenterHost { @display("p=431.02, 3.51"); }
hostR38:CenterHost { @display("p=153.0, 94.65"); }
hostR39:CenterHost { @display("p=417.18, 231.16"); }
hostR40:CenterHost { @display("p=306.27, 155.17"); }
hostR41:CenterHost { @display("p=197.88, 326.56"); }
hostR42:CenterHost { @display("p=218.09, 357.32"); }
hostR43:CenterHost { @display("p=273.71, 254.69"); }
hostR44:CenterHost { @display("p=451.58, 212.13"); }
hostR45:CenterHost { @display("p=450.41, 352.58"); }
hostR46:CenterHost { @display("p=223.13, 395.13"); }
hostR47:CenterHost { @display("p=336.83, 66.5"); }
hostR48:CenterHost { @display("p=21.96, 113.29"); }
hostR49:CenterHost { @display("p=231.3, 4.55"); }
hostR50:CenterHost { @display("p=135.05, 98.75"); }
hostR51:CenterHost { @display("p=73.1, 21.64"); }
hostR52:CenterHost { @display("p=34.96, 192.21"); }
hostR53:CenterHost { @display("p=386.77, 137.11"); }
hostR54:CenterHost { @display("p=66.34, 1.23"); }
hostR55:CenterHost { @display("p=147.93, 172.64"); }
hostR56:CenterHost { @display("p=305.61, 174.29"); }
hostR57:CenterHost { @display("p=530.68, 423.3"); }
hostR58:CenterHost { @display("p=59.86, 582.75"); }
hostR59:CenterHost { @display("p=182.51, 545.06"); }
hostR60:CenterHost { @display("p=406.0, 0.76"); }
hostR61:CenterHost { @display("p=337.99, 102.08"); }
hostR62:CenterHost { @display("p=438.37, 67.13"); }
hostR63:CenterHost { @display("p=91.46, 194.17"); }
hostR64:CenterHost { @display("p=198.71, 131.83"); }
hostR65:CenterHost { @display("p=622.87, 141.65"); }
hostR66:CenterHost { @display("p=212.23, 327.59"); }
hostR67:CenterHost { @display("p=598.23, 160.23"); }
hostR68:CenterHost { @display("p=527.29, 475.55"); }
hostR69:CenterHost { @display("p=265.21, 260.64"); }
hostR70:CenterHost { @display("p=687.38, 666.23"); }
hostR71:CenterHost { @display("p=229.93, 248.94"); }
hostR72:CenterHost { @display("p=360.00, 360.00"); isCenter=true; }
}
