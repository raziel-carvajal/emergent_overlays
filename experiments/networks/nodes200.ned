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
network nodes200
{
    @display("bgb=1908,830");
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
        hostR100: <hostType> like INetworkNode {
            @display("p=1037,145");
        }
        hostR101: <hostType> like INetworkNode {
            @display("p=1100,106");
        }
        hostR102: <hostType> like INetworkNode {
            @display("p=1060,261");
        }
        hostR103: <hostType> like INetworkNode {
            @display("p=1114,312");
        }
        hostR104: <hostType> like INetworkNode {
            @display("p=1171,68");
        }
        hostR105: <hostType> like INetworkNode {
            @display("p=1210,177");
        }
        hostR106: <hostType> like INetworkNode {
            @display("p=1226,329");
        }
        hostR107: <hostType> like INetworkNode {
            @display("p=1259,273");
        }
        hostR108: <hostType> like INetworkNode {
            @display("p=1006,319");
        }
        hostR109: <hostType> like INetworkNode {
            @display("p=1147,234");
        }
        hostR110: <hostType> like INetworkNode {
            @display("p=1298,155");
        }
        hostR111: <hostType> like INetworkNode {
            @display("p=1298,223");
        }
        hostR112: <hostType> like INetworkNode {
            @display("p=1021,213");
        }
        hostR113: <hostType> like INetworkNode {
            @display("p=1160,381");
        }
        hostR114: <hostType> like INetworkNode {
            @display("p=1226,99");
        }
        hostR115: <hostType> like INetworkNode {
            @display("p=1387,116");
        }
        hostR116: <hostType> like INetworkNode {
            @display("p=1387,184");
        }
        hostR117: <hostType> like INetworkNode {
            @display("p=1373,261");
        }
        hostR118: <hostType> like INetworkNode {
            @display("p=1337,342");
        }
        hostR119: <hostType> like INetworkNode {
            @display("p=1470,116");
        }
        hostR120: <hostType> like INetworkNode {
            @display("p=1470,202");
        }
        hostR121: <hostType> like INetworkNode {
            @display("p=1452,280");
        }
        hostR122: <hostType> like INetworkNode {
            @display("p=1259,408");
        }
        hostR123: <hostType> like INetworkNode {
            @display("p=1426,381");
        }
        hostR124: <hostType> like INetworkNode {
            @display("p=1052,398");
        }
        hostR125: <hostType> like INetworkNode {
            @display("p=1121,458");
        }
        hostR126: <hostType> like INetworkNode {
            @display("p=1219,497");
        }
        hostR127: <hostType> like INetworkNode {
            @display("p=1334,490");
        }
        hostR128: <hostType> like INetworkNode {
            @display("p=1426,482");
        }
        hostR129: <hostType> like INetworkNode {
            @display("p=1520,458");
        }
        hostR130: <hostType> like INetworkNode {
            @display("p=1534,368");
        }
        hostR131: <hostType> like INetworkNode {
            @display("p=1534,280");
        }
        hostR132: <hostType> like INetworkNode {
            @display("p=1549,202");
        }
        hostR133: <hostType> like INetworkNode {
            @display("p=1284,585");
        }
        hostR134: <hostType> like INetworkNode {
            @display("p=1132,546");
        }
        hostR135: <hostType> like INetworkNode {
            @display("p=1199,597");
        }
        hostR136: <hostType> like INetworkNode {
            @display("p=1045,521");
        }
        hostR137: <hostType> like INetworkNode {
            @display("p=982,467");
        }
        hostR138: <hostType> like INetworkNode {
            @display("p=1387,576");
        }
        hostR139: <hostType> like INetworkNode {
            @display("p=1491,560");
        }
        hostR140: <hostType> like INetworkNode {
            @display("p=1573,128");
        }
        hostR141: <hostType> like INetworkNode {
            @display("p=1573,546");
        }
        hostR142: <hostType> like INetworkNode {
            @display("p=1602,428");
        }
        hostR143: <hostType> like INetworkNode {
            @display("p=1612,342");
        }
        hostR144: <hostType> like INetworkNode {
            @display("p=1620,252");
        }
        hostR145: <hostType> like INetworkNode {
            @display("p=1651,184");
        }
        hostR146: <hostType> like INetworkNode {
            @display("p=982,106");
        }
        hostR147: <hostType> like INetworkNode {
            @display("p=932,202");
        }
        hostR148: <hostType> like INetworkNode {
            @display("p=932,312");
        }
        hostR149: <hostType> like INetworkNode {
            @display("p=913,420");
        }
        hostR150: <hostType> like INetworkNode {
            @display("p=920,536");
        }
        hostR151: <hostType> like INetworkNode {
            @display("p=998,615");
        }
        hostR152: <hostType> like INetworkNode {
            @display("p=1091,624");
        }
        hostR153: <hostType> like INetworkNode {
            @display("p=1265,663");
        }
        hostR154: <hostType> like INetworkNode {
            @display("p=1361,654");
        }
        hostR155: <hostType> like INetworkNode {
            @display("p=1452,642");
        }
        hostR156: <hostType> like INetworkNode {
            @display("p=1540,642");
        }
        hostR157: <hostType> like INetworkNode {
            @display("p=1641,506");
        }
        hostR158: <hostType> like INetworkNode {
            @display("p=1670,116");
        }
        hostR159: <hostType> like INetworkNode {
            @display("p=1697,261");
        }
        hostR160: <hostType> like INetworkNode {
            @display("p=1721,184");
        }
        hostR161: <hostType> like INetworkNode {
            @display("p=1697,342");
        }
        hostR162: <hostType> like INetworkNode {
            @display("p=1670,428");
        }
        hostR163: <hostType> like INetworkNode {
            @display("p=1721,497");
        }
        hostR164: <hostType> like INetworkNode {
            @display("p=1680,576");
        }
        hostR165: <hostType> like INetworkNode {
            @display("p=1620,624");
        }
        hostR166: <hostType> like INetworkNode {
            @display("p=1709,663");
        }
        hostR167: <hostType> like INetworkNode {
            @display("p=1631,702");
        }
        hostR168: <hostType> like INetworkNode {
            @display("p=1520,720");
        }
        hostR169: <hostType> like INetworkNode {
            @display("p=1171,687");
        }
        hostR170: <hostType> like INetworkNode {
            @display("p=1076,693");
        }
        hostR171: <hostType> like INetworkNode {
            @display("p=991,712");
        }
        hostR172: <hostType> like INetworkNode {
            @display("p=932,642");
        }
        hostR173: <hostType> like INetworkNode {
            @display("p=1412,726");
        }
        hostR174: <hostType> like INetworkNode {
            @display("p=1311,726");
        }
        hostR175: <hostType> like INetworkNode {
            @display("p=1323,89");
        }
        hostR176: <hostType> like INetworkNode {
            @display("p=913,99");
        }
        hostR177: <hostType> like INetworkNode {
            @display("p=1337,428");
        }
        hostR178: <hostType> like INetworkNode {
            @display("p=920,759");
        }
        hostR179: <hostType> like INetworkNode {
            @display("p=1029,781");
        }
        hostR180: <hostType> like INetworkNode {
            @display("p=1114,781");
        }
        hostR181: <hostType> like INetworkNode {
            @display("p=1199,765");
        }
        hostR182: <hostType> like INetworkNode {
            @display("p=1284,791");
        }
        hostR183: <hostType> like INetworkNode {
            @display("p=1602,773");
        }
        hostR184: <hostType> like INetworkNode {
            @display("p=1709,732");
        }
        hostR185: <hostType> like INetworkNode {
            @display("p=1470,781");
        }
        hostR186: <hostType> like INetworkNode {
            @display("p=1361,781");
        }
        hostR187: <hostType> like INetworkNode {
            @display("p=982,398");
        }
        hostR188: <hostType> like INetworkNode {
            @display("p=1100,202");
        }
        hostR189: <hostType> like INetworkNode {
            @display("p=1736,408");
        }
        hostR190: <hostType> like INetworkNode {
            @display("p=1736,106");
        }
        hostR191: <hostType> like INetworkNode {
            @display("p=1303,24");
        }
        hostR192: <hostType> like INetworkNode {
            @display("p=1392,37");
        }
        hostR193: <hostType> like INetworkNode {
            @display("p=1489,37");
        }
        hostR194: <hostType> like INetworkNode {
            @display("p=1568,37");
        }
        hostR195: <hostType> like INetworkNode {
            @display("p=1639,60");
        }
        hostR196: <hostType> like INetworkNode {
            @display("p=1701,29");
        }
        hostR197: <hostType> like INetworkNode {
            @display("p=943,29");
        }
        hostR198: <hostType> like INetworkNode {
            @display("p=1088,29");
        }
        hostR199: <hostType> like INetworkNode {
            @display("p=1245,29");
        }
}
