
import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import broadcasting.CenterHost;
network n_20_d_medium_tr_120_a_240x240_p_
{
@display("bgb=240,240");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR0:CenterHost { @display("p=43.58, 4.44"); }
hostR1:CenterHost { @display("p=114.53, 89.35"); }
hostR2:CenterHost { @display("p=72.25, 75.55"); }
hostR3:CenterHost { @display("p=117.83, 105.02"); }
hostR4:CenterHost { @display("p=6.11, 117.92"); }
hostR5:CenterHost { @display("p=29.63, 37.16"); }
hostR6:CenterHost { @display("p=112.28, 180.97"); }
hostR7:CenterHost { @display("p=74.69, 74.97"); }
hostR8:CenterHost { @display("p=51.71, 115.58"); }
hostR9:CenterHost { @display("p=75.21, 156.61"); }
hostR10:CenterHost { @display("p=173.19, 72.42"); }
hostR11:CenterHost { @display("p=101.19, 5.39"); }
hostR12:CenterHost { @display("p=11.43, 13.43"); }
hostR13:CenterHost { @display("p=104.14, 3.61"); }
hostR14:CenterHost { @display("p=5.83, 27.18"); }
hostR15:CenterHost { @display("p=130.12, 98.51"); }
hostR16:CenterHost { @display("p=64.0, 126.07"); }
hostR17:CenterHost { @display("p=198.46, 126.42"); }
hostR18:CenterHost { @display("p=47.38, 26.63"); }
hostR19:CenterHost { @display("p=200.79, 128.53"); }
hostR20:CenterHost { @display("p=120.00, 120.00"); isCenter=true; }
}
