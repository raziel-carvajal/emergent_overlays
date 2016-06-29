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
hostR0:CenterHost { @display("p=72.97, 23.11"); }
hostR1:CenterHost { @display("p=45.13, 18.36"); }
hostR2:CenterHost { @display("p=65.57, 122.57"); }
hostR3:CenterHost { @display("p=75.53, 119.76"); }
hostR4:CenterHost { @display("p=97.07, 81.74"); }
hostR5:CenterHost { @display("p=117.27, 289.62"); }
hostR6:CenterHost { @display("p=68.27, 448.7"); }
hostR7:CenterHost { @display("p=53.19, 421.46"); }
hostR8:CenterHost { @display("p=16.05, 451.04"); }
hostR9:CenterHost { @display("p=118.47, 187.59"); }
hostR10:CenterHost { @display("p=29.34, 541.85"); }
hostR11:CenterHost { @display("p=49.39, 360.7"); }
hostR12:CenterHost { @display("p=180.38, 70.73"); }
hostR13:CenterHost { @display("p=223.77, 23.07"); }
hostR14:CenterHost { @display("p=47.1, 214.17"); }
hostR15:CenterHost { @display("p=205.94, 187.22"); }
hostR16:CenterHost { @display("p=237.97, 338.6"); }
hostR17:CenterHost { @display("p=36.92, 39.75"); }
hostR18:CenterHost { @display("p=175.62, 55.86"); }
hostR19:CenterHost { @display("p=130.65, 113.54"); }
hostR20:CenterHost { @display("p=59.85, 122.71"); }
hostR21:CenterHost { @display("p=134.7, 102.0"); }
hostR22:CenterHost { @display("p=207.87, 348.64"); }
hostR23:CenterHost { @display("p=9.54, 46.66"); }
hostR24:CenterHost { @display("p=98.27, 93.2"); }
hostR25:CenterHost { @display("p=19.57, 21.27"); }
hostR26:CenterHost { @display("p=317.37, 153.92"); }
hostR27:CenterHost { @display("p=52.68, 38.86"); }
hostR28:CenterHost { @display("p=290.78, 163.88"); }
hostR29:CenterHost { @display("p=56.06, 145.2"); }
hostR30:CenterHost { @display("p=204.49, 65.65"); }
hostR31:CenterHost { @display("p=302.12, 5.98"); }
hostR32:CenterHost { @display("p=136.35, 3.02"); }
hostR33:CenterHost { @display("p=223.15, 445.85"); }
hostR34:CenterHost { @display("p=200.83, 417.3"); }
hostR35:CenterHost { @display("p=138.7, 184.8"); }
hostR36:CenterHost { @display("p=464.8, 100.75"); }
hostR37:CenterHost { @display("p=345.05, 87.63"); }
hostR38:CenterHost { @display("p=307.45, 24.08"); }
hostR39:CenterHost { @display("p=128.12, 54.69"); }
hostR40:CenterHost { @display("p=373.62, 169.83"); }
hostR41:CenterHost { @display("p=100.24, 165.69"); }
hostR42:CenterHost { @display("p=371.12, 80.95"); }
hostR43:CenterHost { @display("p=439.6, 475.31"); }
hostR44:CenterHost { @display("p=54.29, 278.9"); }
hostR45:CenterHost { @display("p=129.21, 433.58"); }
hostR46:CenterHost { @display("p=416.97, 442.2"); }
hostR47:CenterHost { @display("p=376.82, 267.5"); }
hostR48:CenterHost { @display("p=434.09, 104.49"); }
hostR49:CenterHost { @display("p=425.84, 81.56"); }
hostR50:CenterHost { @display("p=344.97, 6.8"); }
hostR51:CenterHost { @display("p=307.52, 124.8"); }
hostR52:CenterHost { @display("p=264.71, 220.14"); }
hostR53:CenterHost { @display("p=570.1, 101.24"); }
hostR54:CenterHost { @display("p=322.61, 349.89"); }
hostR55:CenterHost { @display("p=394.83, 93.27"); }
hostR56:CenterHost { @display("p=260.72, 221.58"); }
hostR57:CenterHost { @display("p=260.1, 177.37"); }
hostR58:CenterHost { @display("p=549.11, 475.12"); }
hostR59:CenterHost { @display("p=192.57, 236.21"); }
hostR60:CenterHost { @display("p=647.5, 82.02"); }
hostR61:CenterHost { @display("p=529.88, 82.68"); }
hostR62:CenterHost { @display("p=268.78, 77.33"); }
hostR63:CenterHost { @display("p=605.03, 85.61"); }
hostR64:CenterHost { @display("p=78.42, 86.58"); }
hostR65:CenterHost { @display("p=703.46, 314.79"); }
hostR66:CenterHost { @display("p=718.61, 65.22"); }
hostR67:CenterHost { @display("p=349.59, 354.14"); }
hostR68:CenterHost { @display("p=109.09, 476.33"); }
hostR69:CenterHost { @display("p=322.63, 270.18"); }
hostR70:CenterHost { @display("p=591.66, 233.31"); }
hostR71:CenterHost { @display("p=677.64, 380.5"); }
hostR72:CenterHost { @display("p=360.00, 360.00"); isCenter=true; }
}