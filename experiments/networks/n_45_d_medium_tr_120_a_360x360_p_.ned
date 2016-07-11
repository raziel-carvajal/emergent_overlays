import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import broadcasting.CenterHost;
network n_45_d_medium_tr_120_a_360x360_p_
{
@display("bgb=360,360");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=69.66, 62.22"); }
hostR1:CenterHost { @display("p=108.01, 61.34"); }
hostR2:CenterHost { @display("p=48.6, 105.33"); }
hostR3:CenterHost { @display("p=116.1, 109.24"); }
hostR4:CenterHost { @display("p=61.8, 24.69"); }
hostR5:CenterHost { @display("p=100.54, 107.43"); }
hostR6:CenterHost { @display("p=87.56, 43.82"); }
hostR7:CenterHost { @display("p=30.1, 149.41"); }
hostR8:CenterHost { @display("p=64.63, 135.76"); }
hostR9:CenterHost { @display("p=66.94, 86.76"); }
hostR10:CenterHost { @display("p=30.12, 325.23"); }
hostR11:CenterHost { @display("p=69.72, 98.99"); }
hostR12:CenterHost { @display("p=96.69, 0.68"); }
hostR13:CenterHost { @display("p=55.85, 84.21"); }
hostR14:CenterHost { @display("p=75.14, 9.25"); }
hostR15:CenterHost { @display("p=204.65, 37.16"); }
hostR16:CenterHost { @display("p=36.15, 88.25"); }
hostR17:CenterHost { @display("p=98.79, 72.58"); }
hostR18:CenterHost { @display("p=69.25, 104.64"); }
hostR19:CenterHost { @display("p=107.58, 48.36"); }
hostR20:CenterHost { @display("p=109.31, 50.39"); }
hostR21:CenterHost { @display("p=34.62, 50.73"); }
hostR22:CenterHost { @display("p=115.89, 128.05"); }
hostR23:CenterHost { @display("p=97.16, 112.64"); }
hostR24:CenterHost { @display("p=86.43, 50.64"); }
hostR25:CenterHost { @display("p=45.95, 53.68"); }
hostR26:CenterHost { @display("p=86.36, 104.52"); }
hostR27:CenterHost { @display("p=206.25, 63.66"); }
hostR28:CenterHost { @display("p=90.36, 114.11"); }
hostR29:CenterHost { @display("p=137.48, 116.7"); }
hostR30:CenterHost { @display("p=44.1, 73.3"); }
hostR31:CenterHost { @display("p=203.0, 48.6"); }
hostR32:CenterHost { @display("p=174.57, 16.01"); }
hostR33:CenterHost { @display("p=299.65, 89.19"); }
hostR34:CenterHost { @display("p=260.27, 33.28"); }
hostR35:CenterHost { @display("p=76.07, 159.66"); }
hostR36:CenterHost { @display("p=273.14, 190.15"); }
hostR37:CenterHost { @display("p=282.65, 183.53"); }
hostR38:CenterHost { @display("p=251.05, 144.47"); }
hostR39:CenterHost { @display("p=172.64, 131.27"); }
hostR40:CenterHost { @display("p=195.81, 201.74"); }
hostR41:CenterHost { @display("p=136.3, 302.51"); }
hostR42:CenterHost { @display("p=197.45, 49.02"); }
hostR43:CenterHost { @display("p=285.23, 263.97"); }
hostR44:CenterHost { @display("p=296.99, 355.83"); }
hostR45:CenterHost { @display("p=180.00, 180.00"); isCenter=true; }
}
