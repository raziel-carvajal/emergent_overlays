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


//package cds3;

import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;

import broadcasting.CenterHost;

// - create a network and specify the size to 500x500
// - drop an IPv4NetworkConfigurator and rename it to "configurator"
// - drop an IdealRadioMedium module and rename to "radioMedium"
// - drop two standardhosts at the 100,100 and 400,400 position and
//   rename them to hostA and hostB
network CDSpaper
{
    @display("bgb=500,500;bgg=50,0,white");
    string hostType = default("WirelessHost");
    string mediumType = default("IdealRadioMedium");
    submodules:
        configurator: IPv4NetworkConfigurator {
            @display("p=149,29");
        }
        radioMedium: <mediumType> like IRadioMedium {
            @display("p=309,24");
        }
        hostR0: CenterHost {
            @display("p=84,268;r=70");
//            isCenter = true;
        }
        hostR2: CenterHost {
            @display("p=89,306;r=40");
        }
        hostR3: CenterHost {
            @display("p=103,235;r=45");
        }
        hostR4: CenterHost {
            @display("p=50,262;r=40");
        }
        hostR5: CenterHost {
            @display("p=137,223;r=75");
        }
        hostR6: CenterHost {
            @display("p=197,202;r=85");
        }
        hostR7: CenterHost {
            @display("p=219,175;r=40");
        }
        hostR8: CenterHost {
            @display("p=236,202;r=40");
        }
        hostR9: CenterHost {
            @display("p=225,229;r=40");
        }
        hostR10: CenterHost {
            @display("p=209,256;r=60");
        }
        hostR11: CenterHost {
            @display("p=209,306;r=70");
        }
        hostR13: CenterHost {
            @display("p=180,339;r=50");
        }
        hostR14: CenterHost {
            @display("p=180,339;r=50");
        }
        hostR15: CenterHost {
            @display("p=254,324;r=50");
        }
        hostR16: CenterHost {
            @display("p=254,324;r=50");
        }
}
