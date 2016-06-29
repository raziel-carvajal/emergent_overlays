import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network n-50-d-sparse-tr-120-a-600x600-p-
{
@display("bgb=600,600");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=103.38, 8.13"); }
hostR1:CenterHost { @display("p=51.26, 4.06"); }
hostR2:CenterHost { @display("p=89.03, 196.21"); }
hostR3:CenterHost { @display("p=86.75, 6.97"); }
hostR4:CenterHost { @display("p=62.17, 273.02"); }
hostR5:CenterHost { @display("p=103.44, 184.38"); }
hostR6:CenterHost { @display("p=39.27, 451.07"); }
hostR7:CenterHost { @display("p=112.97, 215.67"); }
hostR8:CenterHost { @display("p=48.88, 359.49"); }
hostR9:CenterHost { @display("p=25.73, 355.66"); }
hostR10:CenterHost { @display("p=207.81, 9.18"); }
hostR11:CenterHost { @display("p=116.81, 97.2"); }
hostR12:CenterHost { @display("p=99.01, 67.96"); }
hostR13:CenterHost { @display("p=82.74, 168.48"); }
hostR14:CenterHost { @display("p=223.73, 81.3"); }
hostR15:CenterHost { @display("p=188.71, 68.58"); }
hostR16:CenterHost { @display("p=90.6, 161.58"); }
hostR17:CenterHost { @display("p=127.84, 92.05"); }
hostR18:CenterHost { @display("p=170.26, 314.84"); }
hostR19:CenterHost { @display("p=183.2, 588.04"); }
hostR20:CenterHost { @display("p=154.21, 68.04"); }
hostR21:CenterHost { @display("p=77.17, 117.86"); }
hostR22:CenterHost { @display("p=11.5, 219.13"); }
hostR23:CenterHost { @display("p=262.59, 180.32"); }
hostR24:CenterHost { @display("p=127.73, 169.34"); }
hostR25:CenterHost { @display("p=155.57, 187.99"); }
hostR26:CenterHost { @display("p=90.67, 22.69"); }
hostR27:CenterHost { @display("p=260.83, 333.27"); }
hostR28:CenterHost { @display("p=188.95, 577.46"); }
hostR29:CenterHost { @display("p=182.4, 386.32"); }
hostR30:CenterHost { @display("p=155.77, 51.5"); }
hostR31:CenterHost { @display("p=302.03, 45.1"); }
hostR32:CenterHost { @display("p=26.57, 209.03"); }
hostR33:CenterHost { @display("p=166.27, 195.64"); }
hostR34:CenterHost { @display("p=257.53, 295.64"); }
hostR35:CenterHost { @display("p=149.31, 33.09"); }
hostR36:CenterHost { @display("p=113.54, 478.59"); }
hostR37:CenterHost { @display("p=464.08, 306.35"); }
hostR38:CenterHost { @display("p=45.14, 398.25"); }
hostR39:CenterHost { @display("p=433.53, 403.42"); }
hostR40:CenterHost { @display("p=474.95, 99.57"); }
hostR41:CenterHost { @display("p=555.3, 85.09"); }
hostR42:CenterHost { @display("p=10.22, 48.93"); }
hostR43:CenterHost { @display("p=83.9, 92.68"); }
hostR44:CenterHost { @display("p=385.05, 144.3"); }
hostR45:CenterHost { @display("p=40.86, 41.01"); }
hostR46:CenterHost { @display("p=76.89, 53.02"); }
hostR47:CenterHost { @display("p=461.77, 37.92"); }
hostR48:CenterHost { @display("p=372.2, 310.14"); }
hostR49:CenterHost { @display("p=139.42, 390.67"); }
hostR50:CenterHost { @display("p=300.00, 300.00"); isCenter=true; }
}