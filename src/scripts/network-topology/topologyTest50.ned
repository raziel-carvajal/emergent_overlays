import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
network topologyTest50
{
@display("bgb=1908,830");
string hostType = default("WirelessHost");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR1:<hostType> like INetworkNode { @display("p=527.13, 146.38"); }
hostR2:<hostType> like INetworkNode { @display("p=552.67, 364.89"); }
hostR3:<hostType> like INetworkNode { @display("p=462.64, 782.59"); }
hostR4:<hostType> like INetworkNode { @display("p=579.65, 666.02"); }
hostR5:<hostType> like INetworkNode { @display("p=686.30, 829.03"); }
hostR6:<hostType> like INetworkNode { @display("p=148.74, 32.79"); }
hostR7:<hostType> like INetworkNode { @display("p=65.45, 965.35"); }
hostR8:<hostType> like INetworkNode { @display("p=69.18, 529.28"); }
hostR9:<hostType> like INetworkNode { @display("p=733.00, 758.04"); }
hostR10:<hostType> like INetworkNode { @display("p=984.84, 598.70"); }
hostR11:<hostType> like INetworkNode { @display("p=881.54, 371.15"); }
hostR12:<hostType> like INetworkNode { @display("p=233.51, 142.61"); }
hostR13:<hostType> like INetworkNode { @display("p=274.87, 28.30"); }
hostR14:<hostType> like INetworkNode { @display("p=190.20, 799.23"); }
hostR15:<hostType> like INetworkNode { @display("p=754.39, 369.70"); }
hostR16:<hostType> like INetworkNode { @display("p=721.55, 891.67"); }
hostR17:<hostType> like INetworkNode { @display("p=279.38, 203.55"); }
hostR18:<hostType> like INetworkNode { @display("p=424.47, 519.69"); }
hostR19:<hostType> like INetworkNode { @display("p=312.58, 416.48"); }
hostR20:<hostType> like INetworkNode { @display("p=339.28, 422.55"); }
hostR21:<hostType> like INetworkNode { @display("p=628.80, 866.53"); }
hostR22:<hostType> like INetworkNode { @display("p=327.06, 346.23"); }
hostR23:<hostType> like INetworkNode { @display("p=155.28, 494.72"); }
hostR24:<hostType> like INetworkNode { @display("p=711.55, 387.66"); }
hostR25:<hostType> like INetworkNode { @display("p=325.86, 83.49"); }
hostR26:<hostType> like INetworkNode { @display("p=787.83, 519.30"); }
hostR27:<hostType> like INetworkNode { @display("p=324.70, 244.71"); }
hostR28:<hostType> like INetworkNode { @display("p=993.56, 624.16"); }
hostR29:<hostType> like INetworkNode { @display("p=614.65, 413.58"); }
hostR30:<hostType> like INetworkNode { @display("p=883.92, 228.82"); }
hostR31:<hostType> like INetworkNode { @display("p=905.46, 788.67"); }
hostR32:<hostType> like INetworkNode { @display("p=931.11, 64.72"); }
hostR33:<hostType> like INetworkNode { @display("p=342.85, 483.27"); }
hostR34:<hostType> like INetworkNode { @display("p=590.20, 380.43"); }
hostR35:<hostType> like INetworkNode { @display("p=962.30, 375.04"); }
hostR36:<hostType> like INetworkNode { @display("p=740.17, 261.59"); }
hostR37:<hostType> like INetworkNode { @display("p=303.07, 345.60"); }
hostR38:<hostType> like INetworkNode { @display("p=385.17, 671.91"); }
hostR39:<hostType> like INetworkNode { @display("p=56.65, 697.67"); }
hostR40:<hostType> like INetworkNode { @display("p=137.29, 928.40"); }
hostR41:<hostType> like INetworkNode { @display("p=13.48, 545.00"); }
hostR42:<hostType> like INetworkNode { @display("p=876.08, 708.87"); }
hostR43:<hostType> like INetworkNode { @display("p=434.08, 283.72"); }
hostR44:<hostType> like INetworkNode { @display("p=553.51, 631.18"); }
hostR45:<hostType> like INetworkNode { @display("p=407.52, 31.70"); }
hostR46:<hostType> like INetworkNode { @display("p=501.21, 47.35"); }
hostR47:<hostType> like INetworkNode { @display("p=437.23, 301.34"); }
hostR48:<hostType> like INetworkNode { @display("p=905.33, 417.08"); }
hostR49:<hostType> like INetworkNode { @display("p=68.45, 362.27"); }
hostR50:<hostType> like INetworkNode { @display("p=655.16, 681.56"); }
}