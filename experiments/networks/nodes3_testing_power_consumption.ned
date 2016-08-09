

import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;

//import inet.visualizer.integrated.IntegratedCanvasVisualizer;

import broadcasting.CenterHost;


network nodes3_testing_power_consumption
{
    @display("bgb=500,500");
    string hostType = default("WirelessHost");
    string mediumType = default("IdealRadioMedium");


    //@display("bgb=650,500;bgg=100,1,grey95");
    //@figure[title](type=label; pos=0,-1; anchor=sw; color=darkblue);


    submodules:
        //visualizer: IntegratedCanvasVisualizer {
        //    @display("p=169,25");
        //}

        configurator: IPv4NetworkConfigurator {
            @display("p=149,29");
        }
        radioMedium: <mediumType> like IRadioMedium {
            @display("p=309,24");
        }
        hostR0: CenterHost {
            @display("p=50,218");
            isCenter = true;
        }
        hostR1: CenterHost {
            @display("p=150,218");
        }
        hostR2: CenterHost {
            @display("p=250,218");
        }
}
