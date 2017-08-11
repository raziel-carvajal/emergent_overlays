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
network SmallNetwork_1PoI_Medium_Density
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
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR26: CenterHost {
            @display("p=362,337;r=75");
        }
        hostR27: CenterHost {
            @display("p=293,337;r=75");
        }
        hostR28: CenterHost {
            @display("p=430,337;r=75");
        }
        hostR29: CenterHost {
            @display("p=362,390;r=75");
        }
        hostR30: CenterHost {
            @display("p=362,279;r=75");
        }
        hostR31: CenterHost {
            @display("p=496,337;r=75");
        }
        hostR32: CenterHost {
            @display("p=223,337;r=75");
        }
        hostR33: CenterHost {
            @display("p=254,396;r=75");
        }
        hostR34: CenterHost {
            @display("p=254,287;r=75");
        }
        hostR35: CenterHost {
            @display("p=475,396;r=75");
        }
        hostR36: CenterHost {
            @display("p=475,287;r=75");
        }
        hostR37: CenterHost {
            @display("p=362,461;r=75");
        }
        hostR38: CenterHost {
            @display("p=319,423;r=75");
        }
        hostR39: CenterHost {
            @display("p=424,429;r=75");
        }
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR40: CenterHost {
            @display("p=362,284;r=75");
        }
        hostR41: CenterHost {
            @display("p=293,284;r=75");
        }
        hostR42: CenterHost {
            @display("p=430,284;r=75");
        }
        hostR43: CenterHost {
            @display("p=362,337;r=75");
        }
        hostR44: CenterHost {
            @display("p=362,226;r=75");
        }
        hostR45: CenterHost {
            @display("p=496,284;r=75");
        }
        hostR46: CenterHost {
            @display("p=223,284;r=75");
        }
        hostR47: CenterHost {
            @display("p=254,343;r=75");
        }
        hostR48: CenterHost {
            @display("p=254,234;r=75");
        }
        hostR49: CenterHost {
            @display("p=475,343;r=75");
        }
        hostR50: CenterHost {
            @display("p=475,234;r=75");
        }
        hostR51: CenterHost {
            @display("p=362,408;r=75");
        }
        hostR52: CenterHost {
            @display("p=319,370;r=75");
        }
        hostR53: CenterHost {
            @display("p=424,376;r=75");
        }
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR54: CenterHost {
            @display("p=328,342;r=75");
        }
        hostR55: CenterHost {
            @display("p=259,342;r=75");
        }
        hostR56: CenterHost {
            @display("p=396,342;r=75");
        }
        hostR57: CenterHost {
            @display("p=328,395;r=75");
        }
        hostR58: CenterHost {
            @display("p=328,284;r=75");
        }
        hostR59: CenterHost {
            @display("p=462,342;r=75");
        }
        hostR60: CenterHost {
            @display("p=189,342;r=75");
        }
        hostR61: CenterHost {
            @display("p=220,401;r=75");
        }
        hostR62: CenterHost {
            @display("p=220,292;r=75");
        }
        hostR63: CenterHost {
            @display("p=441,401;r=75");
        }
        hostR64: CenterHost {
            @display("p=441,292;r=75");
        }
        hostR65: CenterHost {
            @display("p=328,466;r=75");
        }
        hostR66: CenterHost {
            @display("p=285,428;r=75");
        }
        hostR67: CenterHost {
            @display("p=390,434;r=75");
        }
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR68: CenterHost {
            @display("p=406,343;r=75");
        }
        hostR69: CenterHost {
            @display("p=337,343;r=75");
        }
        hostR70: CenterHost {
            @display("p=474,343;r=75");
        }
        hostR71: CenterHost {
            @display("p=406,396;r=75");
        }
        hostR72: CenterHost {
            @display("p=406,285;r=75");
        }
        hostR73: CenterHost {
            @display("p=540,343;r=75");
        }
        hostR74: CenterHost {
            @display("p=267,343;r=75");
        }
        hostR75: CenterHost {
            @display("p=298,402;r=75");
        }
        hostR76: CenterHost {
            @display("p=298,293;r=75");
        }
        hostR77: CenterHost {
            @display("p=519,402;r=75");
        }
        hostR78: CenterHost {
            @display("p=519,293;r=75");
        }
        hostR79: CenterHost {
            @display("p=406,467;r=75");
        }
        hostR80: CenterHost {
            @display("p=363,429;r=75");
        }
        hostR81: CenterHost {
            @display("p=468,435;r=75");
        }
}
