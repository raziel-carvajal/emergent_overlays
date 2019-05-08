package rand_uniform_topologies;
  import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
  import inet.node.inet.INetworkNode;
  import inet.physicallayer.contract.packetlevel.IRadioMedium;
  import broadcasting.CenterHost;
network n_11_d_0_tr_15_a_50x50_idx_0_p_{
@display("bgb=50, 50");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator {
@display("p=0,0");
}
radioMedium: <mediumType> like IRadioMedium{
@display("p=0,0");}
hostR1: CenterHost {@display("p=10.635637423,45.5543421193");}
hostR2: CenterHost {@display("p=28.544243859,38.6900984139");}
hostR3: CenterHost {@display("p=18.5585677271,2.4939951461");}
hostR4: CenterHost {@display("p=47.0813452193,32.0101687535");}
hostR5: CenterHost {@display("p=8.01791510249,12.8162339377");}
hostR6: CenterHost {@display("p=3.35356314803,23.1884953134");}
hostR7: CenterHost {@display("p=0.0110501765284,2.58573552885");}
hostR8: CenterHost {@display("p=21.3359298371,41.6338592431");}
hostR9: CenterHost {@display("p=18.8905292089,16.3135667928");}
hostR10: CenterHost {@display("p=36.8051576193,23.0005538234");}
hostR11: CenterHost {@display("p=25.0,25.0");}
}