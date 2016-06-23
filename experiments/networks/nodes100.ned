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


import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;


// - create a network and specify the size to 500x500
// - drop an IPv4NetworkConfigurator and rename it to "configurator"
// - drop an IdealRadioMedium module and rename to "radioMedium"
// - drop two standardhosts at the 100,100 and 400,400 position and
//   rename them to hostA and hostB
network nodes100
{
    @display("bgb=894,830");
    string hostType = default("WirelessHost");
    string mediumType = default("IdealRadioMedium");
    submodules:
        configurator: IPv4NetworkConfigurator {
            @display("p=149,29");
        }
        radioMedium: <mediumType> like IRadioMedium {
            @display("p=309,24");
        }
        hostR0: <hostType> like INetworkNode {
            @display("p=157,155");
        }
        hostR1: <hostType> like INetworkNode {
            @display("p=220,116");
        }
        hostR2: <hostType> like INetworkNode {
            @display("p=180,271");
        }
        hostR3: <hostType> like INetworkNode {
            @display("p=234,322");
        }
        hostR4: <hostType> like INetworkNode {
            @display("p=300,165");
        }
        hostR5: <hostType> like INetworkNode {
            @display("p=346,194");
        }
        hostR6: <hostType> like INetworkNode {
            @display("p=346,339");
        }
        hostR7: <hostType> like INetworkNode {
            @display("p=379,283");
        }
        hostR8: <hostType> like INetworkNode {
            @display("p=126,329");
        }
        hostR9: <hostType> like INetworkNode {
            @display("p=267,244");
        }
        hostR10: <hostType> like INetworkNode {
            @display("p=418,165");
        }
        hostR11: <hostType> like INetworkNode {
            @display("p=418,233");
        }
        hostR12: <hostType> like INetworkNode {
            @display("p=141,223");
        }
        hostR13: <hostType> like INetworkNode {
            @display("p=280,391");
        }
        hostR14: <hostType> like INetworkNode {
            @display("p=346,109");
        }
        hostR15: <hostType> like INetworkNode {
            @display("p=507,126");
        }
        hostR16: <hostType> like INetworkNode {
            @display("p=507,194");
        }
        hostR17: <hostType> like INetworkNode {
            @display("p=493,271");
        }
        hostR18: <hostType> like INetworkNode {
            @display("p=457,352");
        }
        hostR19: <hostType> like INetworkNode {
            @display("p=590,126");
        }
        hostR20: <hostType> like INetworkNode {
            @display("p=590,212");
        }
        hostR21: <hostType> like INetworkNode {
            @display("p=572,290");
        }
        hostR22: <hostType> like INetworkNode {
            @display("p=379,418");
        }
        hostR23: <hostType> like INetworkNode {
            @display("p=546,391");
        }
        hostR24: <hostType> like INetworkNode {
            @display("p=172,408");
        }
        hostR25: <hostType> like INetworkNode {
            @display("p=241,468");
        }
        hostR26: <hostType> like INetworkNode {
            @display("p=339,507");
        }
        hostR27: <hostType> like INetworkNode {
            @display("p=454,500");
        }
        hostR28: <hostType> like INetworkNode {
            @display("p=546,492");
        }
        hostR29: <hostType> like INetworkNode {
            @display("p=640,468");
        }
        hostR30: <hostType> like INetworkNode {
            @display("p=654,378");
        }
        hostR31: <hostType> like INetworkNode {
            @display("p=654,290");
        }
        hostR32: <hostType> like INetworkNode {
            @display("p=669,212");
        }
        hostR33: <hostType> like INetworkNode {
            @display("p=404,595");
        }
        hostR34: <hostType> like INetworkNode {
            @display("p=252,556");
        }
        hostR35: <hostType> like INetworkNode {
            @display("p=319,607");
        }
        hostR36: <hostType> like INetworkNode {
            @display("p=165,531");
        }
        hostR37: <hostType> like INetworkNode {
            @display("p=102,477");
        }
        hostR38: <hostType> like INetworkNode {
            @display("p=507,586");
        }
        hostR39: <hostType> like INetworkNode {
            @display("p=611,570");
        }
        hostR40: <hostType> like INetworkNode {
            @display("p=693,138");
        }
        hostR41: <hostType> like INetworkNode {
            @display("p=693,556");
        }
        hostR42: <hostType> like INetworkNode {
            @display("p=722,438");
        }
        hostR43: <hostType> like INetworkNode {
            @display("p=732,352");
        }
        hostR44: <hostType> like INetworkNode {
            @display("p=740,262");
        }
        hostR45: <hostType> like INetworkNode {
            @display("p=771,194");
        }
        hostR46: <hostType> like INetworkNode {
            @display("p=102,116");
        }
        hostR47: <hostType> like INetworkNode {
            @display("p=52,212");
        }
        hostR48: <hostType> like INetworkNode {
            @display("p=52,322");
        }
        hostR49: <hostType> like INetworkNode {
            @display("p=33,430");
        }
        hostR50: <hostType> like INetworkNode {
            @display("p=40,546");
        }
        hostR51: <hostType> like INetworkNode {
            @display("p=118,625");
        }
        hostR52: <hostType> like INetworkNode {
            @display("p=211,634");
        }
        hostR53: <hostType> like INetworkNode {
            @display("p=385,673");
        }
        hostR54: <hostType> like INetworkNode {
            @display("p=481,664");
        }
        hostR55: <hostType> like INetworkNode {
            @display("p=572,652");
        }
        hostR56: <hostType> like INetworkNode {
            @display("p=660,652");
        }
        hostR57: <hostType> like INetworkNode {
            @display("p=761,516");
        }
        hostR58: <hostType> like INetworkNode {
            @display("p=790,126");
        }
        hostR59: <hostType> like INetworkNode {
            @display("p=817,271");
        }
        hostR60: <hostType> like INetworkNode {
            @display("p=841,194");
        }
        hostR61: <hostType> like INetworkNode {
            @display("p=817,352");
        }
        hostR62: <hostType> like INetworkNode {
            @display("p=790,438");
        }
        hostR63: <hostType> like INetworkNode {
            @display("p=841,507");
        }
        hostR64: <hostType> like INetworkNode {
            @display("p=800,586");
        }
        hostR65: <hostType> like INetworkNode {
            @display("p=740,634");
        }
        hostR66: <hostType> like INetworkNode {
            @display("p=829,673");
        }
        hostR67: <hostType> like INetworkNode {
            @display("p=751,712");
        }
        hostR68: <hostType> like INetworkNode {
            @display("p=640,730");
        }
        hostR69: <hostType> like INetworkNode {
            @display("p=291,697");
        }
        hostR70: <hostType> like INetworkNode {
            @display("p=196,703");
        }
        hostR71: <hostType> like INetworkNode {
            @display("p=111,722");
        }
        hostR72: <hostType> like INetworkNode {
            @display("p=52,652");
        }
        hostR73: <hostType> like INetworkNode {
            @display("p=532,736");
        }
        hostR74: <hostType> like INetworkNode {
            @display("p=431,736");
        }
        hostR75: <hostType> like INetworkNode {
            @display("p=443,99");
        }
        hostR76: <hostType> like INetworkNode {
            @display("p=443,24");
        }
        hostR77: <hostType> like INetworkNode {
            @display("p=532,37");
        }
        hostR78: <hostType> like INetworkNode {
            @display("p=629,37");
        }
        hostR79: <hostType> like INetworkNode {
            @display("p=708,37");
        }
        hostR80: <hostType> like INetworkNode {
            @display("p=779,60");
        }
        hostR81: <hostType> like INetworkNode {
            @display("p=841,29");
        }
        hostR82: <hostType> like INetworkNode {
            @display("p=33,29");
        }
        hostR83: <hostType> like INetworkNode {
            @display("p=33,109");
        }
        hostR84: <hostType> like INetworkNode {
            @display("p=228,29");
        }
        hostR85: <hostType> like INetworkNode {
            @display("p=457,438");
        }
        hostR86: <hostType> like INetworkNode {
            @display("p=40,769");
        }
        hostR87: <hostType> like INetworkNode {
            @display("p=149,791");
        }
        hostR88: <hostType> like INetworkNode {
            @display("p=234,791");
        }
        hostR89: <hostType> like INetworkNode {
            @display("p=319,775");
        }
        hostR90: <hostType> like INetworkNode {
            @display("p=404,801");
        }
        hostR91: <hostType> like INetworkNode {
            @display("p=722,783");
        }
        hostR92: <hostType> like INetworkNode {
            @display("p=829,742");
        }
        hostR93: <hostType> like INetworkNode {
            @display("p=590,791");
        }
        hostR94: <hostType> like INetworkNode {
            @display("p=481,791");
        }
        hostR95: <hostType> like INetworkNode {
            @display("p=102,408");
        }
        hostR96: <hostType> like INetworkNode {
            @display("p=220,212");
        }
        hostR97: <hostType> like INetworkNode {
            @display("p=856,418");
        }
        hostR98: <hostType> like INetworkNode {
            @display("p=856,116");
        }
        hostR99: <hostType> like INetworkNode {
            @display("p=385,29");
        }
}
