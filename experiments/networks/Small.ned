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

//package abba2;

import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;

import broadcasting.CenterHost;

// - create a network and specify the size to 500x500
// - drop an IPv4NetworkConfigurator and rename it to "configurator"
// - drop an IdealRadioMedium module and rename to "radioMedium"
// - drop two standardhosts at the 100,100 and 400,400 position and
//   rename them to hostA and hostB
network Small
{
    @display("bgb=500,500");
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
            @display("p=116.928,217.72801;r=75");
            //isCenter=true;
        }
        hostR1: CenterHost {
            @display("p=179.42401,217.72801;r=75");
        }
        hostR2: CenterHost {
            @display("p=250,218;r=75");
        }
        hostR3: CenterHost {
            @display("p=280,166;r=75");
        }
        hostR4: CenterHost {
            @display("p=280,273;r=75");
        }
        hostR5: CenterHost {
            @display("p=83,166;r=75");
        }
        hostR6: CenterHost {
            @display("p=96,260;r=75");
        }
}
