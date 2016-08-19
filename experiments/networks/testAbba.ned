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
network testAbba
{
    @display("bgb=500,500;bgg=25,0,white");
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
            @display("p=250,250");
            isCenter = true;
        }
        hostR1: CenterHost {
            @display("p=300,250");
        }
        hostR2: CenterHost {
            @display("p=194,250");
        }
        hostR3: CenterHost {
            @display("p=250,196");
        }
        hostR4: CenterHost {
            @display("p=250,306");
        }
        hostR5: CenterHost {
            @display("p=300,206");
        }
        hostR6: CenterHost {
            @display("p=204,206");
        }
        hostR7: CenterHost {
            @display("p=204,299");
        }
        hostR8: CenterHost {
            @display("p=300,306");
        }
        hostR9: CenterHost {
            @display("p=353,250");
        }
        hostR10: CenterHost {
            @display("p=272,142");
        }
        hostR11: CenterHost {
            @display("p=149,250");
        }
        hostR12: CenterHost {
            @display("p=250,356");
        }
        hostR13: CenterHost {
            @display("p=362,206");
        }
        hostR14: CenterHost {
            @display("p=349,173");
        }
        hostR15: CenterHost {
            @display("p=310,149");
        }
        hostR16: CenterHost {
            @display("p=218,149");
        }
        hostR17: CenterHost {
            @display("p=166,173");
        }
        hostR18: CenterHost {
            @display("p=141,217");
        }
        hostR19: CenterHost {
            @display("p=149,299");
        }
        hostR20: CenterHost {
            @display("p=172,339");
        }
        hostR21: CenterHost {
            @display("p=211,356");
        }
        hostR22: CenterHost {
            @display("p=300,356");
        }
        hostR23: CenterHost {
            @display("p=349,339");
        }
        hostR24: CenterHost {
            @display("p=353,306");
        }
        hostR25: CenterHost {
            @display("p=80,356");
        }
        hostR26: CenterHost {
            @display("p=80,266");
        }
        hostR27: CenterHost {
            @display("p=339,97");
        }
        hostR28: CenterHost {
            @display("p=425,299");
        }
        hostR29: CenterHost {
            @display("p=425,339");
        }
        hostR30: CenterHost {
            @display("p=401,379");
        }
        hostR31: CenterHost {
            @display("p=353,389");
        }
        hostR32: CenterHost {
            @display("p=310,405");
        }
        hostR33: CenterHost {
            @display("p=257,412");
        }
        hostR34: CenterHost {
            @display("p=211,412");
        }
        hostR35: CenterHost {
            @display("p=166,396");
        }
        hostR36: CenterHost {
            @display("p=119,379");
        }
        hostR37: CenterHost {
            @display("p=74,315");
        }
        hostR38: CenterHost {
            @display("p=88,217");
        }
        hostR39: CenterHost {
            @display("p=102,163");
        }
        hostR40: CenterHost {
            @display("p=133,130");
        }
        hostR41: CenterHost {
            @display("p=188,103");
        }
        hostR42: CenterHost {
            @display("p=233,89");
        }
        hostR43: CenterHost {
            @display("p=289,89");
        }
        hostR44: CenterHost {
            @display("p=378,109");
        }
        hostR45: CenterHost {
            @display("p=407,130");
        }
        hostR46: CenterHost {
            @display("p=425,163");
        }
        hostR47: CenterHost {
            @display("p=431,206");
        }
        hostR48: CenterHost {
            @display("p=431,250");
        }
}
