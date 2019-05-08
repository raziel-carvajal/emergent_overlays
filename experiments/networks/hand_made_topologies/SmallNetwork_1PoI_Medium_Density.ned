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

import inet.physicallayer.idealradio.IdealRadioMedium;
//import inet.physicallayer.ieee80211.packetlevel.Ieee80211RadioMedium;
//import inet.physicallayer.ieee80211.packetlevel.Ieee80211ScalarRadioMedium;
import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import emergent_overlays.tunned_modules.Cellphone;

import inet.common.lifecycle.LifecycleController;

network SmallNetwork_1PoI_Medium_Density
{
    @display("bgb=700,700");
    submodules:
        lifecycleController: LifecycleController;
        radioMedium: IdealRadioMedium;
        //        radioMedium: Ieee80211ScalarRadioMedium;
        //        radioMedium: Ieee80211RadioMedium;
        configurator: IPv4NetworkConfigurator;
        host1: Cellphone {
            @display("p=362,312;r=75");
        }
        host2: Cellphone {
            @display("p=293,312;r=75");
        }
        host3: Cellphone {
            @display("p=430,312;r=75");
        }
        host4: Cellphone {
            @display("p=362,365;r=75");
        }
        host5: Cellphone {
            @display("p=362,254;r=75");
        }
        host6: Cellphone {
            @display("p=496,312;r=75");
        }
        host7: Cellphone {
            @display("p=223,312;r=75");
        }
        host8: Cellphone {
            @display("p=254,371;r=75");
        }
        host9: Cellphone {
            @display("p=254,262;r=75");
        }
        host10: Cellphone {
            @display("p=475,371;r=75");
        }
        host11: Cellphone {
            @display("p=475,262;r=75");
        }
        host12: Cellphone {
            @display("p=362,193;r=75");
        }
        host13: Cellphone {
            @display("p=362,436;r=75");
        }
        host14: Cellphone {
            @display("p=566,312;r=75");
        }
        host15: Cellphone {
            @display("p=612,262;r=75");
        }
        host16: Cellphone {
            @display("p=622,198;r=75");
        }
        host17: Cellphone {
            @display("p=157,312;r=75");
        }
        host18: Cellphone {
            @display("p=118,356;r=75");
        }
        host19: Cellphone {
            @display("p=87,414;r=75");
        }
        host20: Cellphone {
            @display("p=367,495;r=75");
        }
        host21: Cellphone {
            @display("p=367,557;r=75");
        }
        host22: Cellphone {
            @display("p=367,136;r=75");
        }
        host23: Cellphone {
            @display("p=367,79;r=75");
        }
        host24: Cellphone {
            @display("p=319,398;r=75");
        }
        host25: Cellphone {
            @display("p=424,404;r=75");
        }
        //                host0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        host26: Cellphone {
            @display("p=362,337;r=75");
        }
        host27: Cellphone {
            @display("p=293,337;r=75");
        }
        host28: Cellphone {
            @display("p=430,337;r=75");
        }
        host29: Cellphone {
            @display("p=362,390;r=75");
        }
        host30: Cellphone {
            @display("p=362,279;r=75");
        }
        host31: Cellphone {
            @display("p=496,337;r=75");
        }
        host32: Cellphone {
            @display("p=223,337;r=75");
        }
        host33: Cellphone {
            @display("p=254,396;r=75");
        }
        host34: Cellphone {
            @display("p=254,287;r=75");
        }
        host35: Cellphone {
            @display("p=475,396;r=75");
        }
        host36: Cellphone {
            @display("p=475,287;r=75");
        }
        host37: Cellphone {
            @display("p=362,461;r=75");
        }
        host38: Cellphone {
            @display("p=319,423;r=75");
        }
        host39: Cellphone {
            @display("p=424,429;r=75");
        }
        //                host0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        host40: Cellphone {
            @display("p=362,284;r=75");
        }
        host41: Cellphone {
            @display("p=293,284;r=75");
        }
        host42: Cellphone {
            @display("p=430,284;r=75");
        }
        host43: Cellphone {
            @display("p=362,337;r=75");
        }
        host44: Cellphone {
            @display("p=362,226;r=75");
        }
        host45: Cellphone {
            @display("p=496,284;r=75");
        }
        host46: Cellphone {
            @display("p=223,284;r=75");
        }
        host47: Cellphone {
            @display("p=254,343;r=75");
        }
        host48: Cellphone {
            @display("p=254,234;r=75");
        }
        host49: Cellphone {
            @display("p=475,343;r=75");
        }
        host50: Cellphone {
            @display("p=475,234;r=75");
        }
        host51: Cellphone {
            @display("p=362,408;r=75");
        }
        host52: Cellphone {
            @display("p=319,370;r=75");
        }
        host53: Cellphone {
            @display("p=424,376;r=75");
        }
        //                host0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        host54: Cellphone {
            @display("p=328,342;r=75");
        }
        host55: Cellphone {
            @display("p=259,342;r=75");
        }
        host56: Cellphone {
            @display("p=396,342;r=75");
        }
        host57: Cellphone {
            @display("p=328,395;r=75");
        }
        host58: Cellphone {
            @display("p=328,284;r=75");
        }
        host59: Cellphone {
            @display("p=462,342;r=75");
        }
        host60: Cellphone {
            @display("p=189,342;r=75");
        }
        host61: Cellphone {
            @display("p=220,401;r=75");
        }
        host62: Cellphone {
            @display("p=220,292;r=75");
        }
        host63: Cellphone {
            @display("p=441,401;r=75");
        }
        host64: Cellphone {
            @display("p=441,292;r=75");
        }
        host65: Cellphone {
            @display("p=328,466;r=75");
        }
        host66: Cellphone {
            @display("p=285,428;r=75");
        }
        host67: Cellphone {
            @display("p=390,434;r=75");
        }
        //                host0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        host68: Cellphone {
            @display("p=406,343;r=75");
        }
        host69: Cellphone {
            @display("p=337,343;r=75");
        }
        host70: Cellphone {
            @display("p=474,343;r=75");
        }
        host71: Cellphone {
            @display("p=406,396;r=75");
        }
        host72: Cellphone {
            @display("p=406,285;r=75");
        }
        host73: Cellphone {
            @display("p=540,343;r=75");
        }
        host74: Cellphone {
            @display("p=267,343;r=75");
        }
        host75: Cellphone {
            @display("p=298,402;r=75");
        }
        host76: Cellphone {
            @display("p=298,293;r=75");
        }
        host77: Cellphone {
            @display("p=519,402;r=75");
        }
        host78: Cellphone {
            @display("p=519,293;r=75");
        }
        host79: Cellphone {
            @display("p=406,467;r=75");
        }
        host80: Cellphone {
            @display("p=363,429;r=75");
        }
        host81: Cellphone {
            @display("p=468,435;r=75");
        }
}
