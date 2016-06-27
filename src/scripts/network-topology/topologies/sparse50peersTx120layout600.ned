import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network sparse50peersTx120layout600
{
@display("bgb=600,600");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=23.57, 104.32"); }
hostR1:CenterHost { @display("p=89.89, 85.53"); }
hostR2:CenterHost { @display("p=61.78, 188.12"); }
hostR3:CenterHost { @display("p=101.85, 80.36"); }
hostR4:CenterHost { @display("p=64.01, 39.42"); }
hostR5:CenterHost { @display("p=85.18, 340.69"); }
hostR6:CenterHost { @display("p=77.39, 181.1"); }
hostR7:CenterHost { @display("p=91.95, 391.14"); }
hostR8:CenterHost { @display("p=69.42, 241.84"); }
hostR9:CenterHost { @display("p=20.36, 168.69"); }
hostR10:CenterHost { @display("p=228.66, 112.81"); }
hostR11:CenterHost { @display("p=56.8, 117.24"); }
hostR12:CenterHost { @display("p=201.14, 28.91"); }
hostR13:CenterHost { @display("p=85.86, 104.03"); }
hostR14:CenterHost { @display("p=187.98, 6.16"); }
hostR15:CenterHost { @display("p=78.68, 97.09"); }
hostR16:CenterHost { @display("p=179.17, 384.22"); }
hostR17:CenterHost { @display("p=135.96, 464.94"); }
hostR18:CenterHost { @display("p=111.14, 14.67"); }
hostR19:CenterHost { @display("p=47.94, 207.62"); }
hostR20:CenterHost { @display("p=143.67, 1.53"); }
hostR21:CenterHost { @display("p=168.83, 71.47"); }
hostR22:CenterHost { @display("p=201.99, 214.47"); }
hostR23:CenterHost { @display("p=113.35, 76.36"); }
hostR24:CenterHost { @display("p=28.73, 69.6"); }
hostR25:CenterHost { @display("p=93.54, 221.71"); }
hostR26:CenterHost { @display("p=112.3, 250.39"); }
hostR27:CenterHost { @display("p=300.08, 175.19"); }
hostR28:CenterHost { @display("p=128.16, 112.19"); }
hostR29:CenterHost { @display("p=12.16, 57.52"); }
hostR30:CenterHost { @display("p=292.65, 37.51"); }
hostR31:CenterHost { @display("p=329.47, 92.5"); }
hostR32:CenterHost { @display("p=73.74, 61.88"); }
hostR33:CenterHost { @display("p=20.55, 55.26"); }
hostR34:CenterHost { @display("p=72.11, 64.49"); }
hostR35:CenterHost { @display("p=323.88, 229.5"); }
hostR36:CenterHost { @display("p=145.72, 458.61"); }
hostR37:CenterHost { @display("p=277.44, 248.16"); }
hostR38:CenterHost { @display("p=37.92, 196.65"); }
hostR39:CenterHost { @display("p=466.2, 385.07"); }
hostR40:CenterHost { @display("p=573.6, 110.18"); }
hostR41:CenterHost { @display("p=416.79, 9.27"); }
hostR42:CenterHost { @display("p=408.26, 21.87"); }
hostR43:CenterHost { @display("p=80.07, 128.76"); }
hostR44:CenterHost { @display("p=523.51, 168.68"); }
hostR45:CenterHost { @display("p=165.8, 38.67"); }
hostR46:CenterHost { @display("p=570.72, 138.03"); }
hostR47:CenterHost { @display("p=336.54, 129.55"); }
hostR48:CenterHost { @display("p=163.84, 199.25"); }
hostR49:CenterHost { @display("p=106.39, 367.47"); }
hostR50:CenterHost { @display("p=300.00, 300.00"); isCenter=true; }
}