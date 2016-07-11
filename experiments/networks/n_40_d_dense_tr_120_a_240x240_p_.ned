import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import broadcasting.CenterHost;
network n_40_d_dense_tr_120_a_240x240_p_
{
@display("bgb=240,240");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=20.6, 65.86"); }
hostR1:CenterHost { @display("p=107.79, 80.96"); }
hostR2:CenterHost { @display("p=96.44, 80.19"); }
hostR3:CenterHost { @display("p=16.85, 0.54"); }
hostR4:CenterHost { @display("p=15.77, 90.62"); }
hostR5:CenterHost { @display("p=32.63, 114.53"); }
hostR6:CenterHost { @display("p=31.64, 23.84"); }
hostR7:CenterHost { @display("p=60.11, 49.54"); }
hostR8:CenterHost { @display("p=15.71, 52.44"); }
hostR9:CenterHost { @display("p=58.42, 101.78"); }
hostR10:CenterHost { @display("p=14.32, 69.23"); }
hostR11:CenterHost { @display("p=115.18, 213.71"); }
hostR12:CenterHost { @display("p=20.89, 87.8"); }
hostR13:CenterHost { @display("p=62.14, 6.47"); }
hostR14:CenterHost { @display("p=17.47, 59.99"); }
hostR15:CenterHost { @display("p=95.89, 169.99"); }
hostR16:CenterHost { @display("p=81.29, 161.99"); }
hostR17:CenterHost { @display("p=87.64, 12.18"); }
hostR18:CenterHost { @display("p=46.86, 238.34"); }
hostR19:CenterHost { @display("p=33.98, 106.92"); }
hostR20:CenterHost { @display("p=15.58, 70.37"); }
hostR21:CenterHost { @display("p=13.76, 87.35"); }
hostR22:CenterHost { @display("p=210.24, 22.54"); }
hostR23:CenterHost { @display("p=19.15, 45.35"); }
hostR24:CenterHost { @display("p=82.0, 106.78"); }
hostR25:CenterHost { @display("p=156.3, 98.87"); }
hostR26:CenterHost { @display("p=51.1, 46.42"); }
hostR27:CenterHost { @display("p=197.37, 110.57"); }
hostR28:CenterHost { @display("p=151.14, 62.71"); }
hostR29:CenterHost { @display("p=42.77, 79.51"); }
hostR30:CenterHost { @display("p=118.49, 201.05"); }
hostR31:CenterHost { @display("p=119.37, 47.94"); }
hostR32:CenterHost { @display("p=156.02, 70.33"); }
hostR33:CenterHost { @display("p=20.15, 18.37"); }
hostR34:CenterHost { @display("p=4.63, 178.75"); }
hostR35:CenterHost { @display("p=151.0, 230.7"); }
hostR36:CenterHost { @display("p=158.39, 181.95"); }
hostR37:CenterHost { @display("p=72.82, 237.15"); }
hostR38:CenterHost { @display("p=182.93, 46.13"); }
hostR39:CenterHost { @display("p=78.38, 216.52"); }
hostR40:CenterHost { @display("p=120.00, 120.00"); isCenter=true; }
}
