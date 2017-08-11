//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

package hand_made_topologies;
import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;

import broadcasting.CenterHost;

// - create a network and specify the size to 500x500
// - drop an IPv4NetworkConfigurator and rename it to "configurator"
// - drop an IdealRadioMedium module and rename to "radioMedium"
// - drop two standardhosts at the 100,100 and 400,400 position and
//   rename them to hostA and hostB
network SmallNetwork_1PoI
{
    @display("bgb=700,700");
    string hostType = default("WirelessHost");
    string mediumType = default("IdealRadioMedium");
    submodules:
        configurator: IPv4NetworkConfigurator {
            @display("p=149,29");
        }
        radioMedium: <mediumType> like IRadioMedium {
            @display("p=309,24");
        }
//                hostR0: INetworkNode {
//                    @display("p=362,312;r=180");
//                }
        hostR1: CenterHost {
            @display("p=362,312;r=75");
        }
        hostR2: CenterHost {
            @display("p=293,312;r=75");
        }
        hostR3: CenterHost {
            @display("p=430,312;r=75");
        }
        hostR4: CenterHost {
            @display("p=362,365;r=75");
        }
        hostR5: CenterHost {
            @display("p=362,254;r=75");
        }
        hostR6: CenterHost {
            @display("p=496,312;r=75");
        }
        hostR7: CenterHost {
            @display("p=223,312;r=75");
        }
        hostR8: CenterHost {
            @display("p=254,371;r=75");
        }
        hostR9: CenterHost {
            @display("p=254,262;r=75");
        }
        hostR10: CenterHost {
            @display("p=475,371;r=75");
        }
        hostR11: CenterHost {
            @display("p=475,262;r=75");
        }
        hostR12: CenterHost {
            @display("p=362,193;r=75");
        }
        hostR13: CenterHost {
            @display("p=362,436;r=75");
        }
        hostR14: CenterHost {
            @display("p=566,312;r=75");
        }
        hostR15: CenterHost {
            @display("p=612,262;r=75");
        }
        hostR16: CenterHost {
            @display("p=622,198;r=75");
        }
        hostR17: CenterHost {
            @display("p=157,312;r=75");
        }
        hostR18: CenterHost {
            @display("p=118,356;r=75");
        }
        hostR19: CenterHost {
            @display("p=87,414;r=75");
        }
        hostR20: CenterHost {
            @display("p=367,495;r=75");
        }
        hostR21: CenterHost {
            @display("p=367,557;r=75");
        }
        hostR22: CenterHost {
            @display("p=367,136;r=75");
        }
        hostR23: CenterHost {
            @display("p=367,79;r=75");
        }
        hostR24: CenterHost {
            @display("p=319,398;r=75");
        }
        hostR25: CenterHost {
            @display("p=424,404;r=75");
        }
}
