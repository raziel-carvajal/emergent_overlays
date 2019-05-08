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
network PoI_1_DenseAtCenter_SparseElswhere
{
    @display("bgb=700,700");
    string hostType = default("WirelessHost");
    string mediumType = default("IdealRadioMedium");
    submodules:
        configurator: IPv4NetworkConfigurator {
            @display("p=550,46");
        }
        radioMedium: <mediumType> like IRadioMedium {
            @display("p=582,25");
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
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR82: CenterHost {
            @display("p=344,312;r=75");
        }
        hostR83: CenterHost {
            @display("p=275,312;r=75");
        }
        hostR84: CenterHost {
            @display("p=412,312;r=75");
        }
        hostR85: CenterHost {
            @display("p=344,365;r=75");
        }
        hostR86: CenterHost {
            @display("p=344,254;r=75");
        }
        hostR87: CenterHost {
            @display("p=478,312;r=75");
        }
        hostR88: CenterHost {
            @display("p=205,312;r=75");
        }
        hostR89: CenterHost {
            @display("p=236,371;r=75");
        }
        hostR90: CenterHost {
            @display("p=236,262;r=75");
        }
        hostR91: CenterHost {
            @display("p=457,371;r=75");
        }
        hostR92: CenterHost {
            @display("p=457,262;r=75");
        }
        hostR93: CenterHost {
            @display("p=344,436;r=75");
        }
        hostR94: CenterHost {
            @display("p=301,398;r=75");
        }
        hostR95: CenterHost {
            @display("p=406,404;r=75");
        }
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR96: CenterHost {
            @display("p=344,337;r=75");
        }
        hostR97: CenterHost {
            @display("p=275,337;r=75");
        }
        hostR98: CenterHost {
            @display("p=412,337;r=75");
        }
        hostR99: CenterHost {
            @display("p=344,390;r=75");
        }
        hostR100: CenterHost {
            @display("p=344,279;r=75");
        }
        hostR101: CenterHost {
            @display("p=478,337;r=75");
        }
        hostR102: CenterHost {
            @display("p=205,337;r=75");
        }
        hostR103: CenterHost {
            @display("p=236,396;r=75");
        }
        hostR104: CenterHost {
            @display("p=236,287;r=75");
        }
        hostR105: CenterHost {
            @display("p=457,396;r=75");
        }
        hostR106: CenterHost {
            @display("p=457,287;r=75");
        }
        hostR107: CenterHost {
            @display("p=344,461;r=75");
        }
        hostR108: CenterHost {
            @display("p=301,423;r=75");
        }
        hostR109: CenterHost {
            @display("p=406,429;r=75");
        }
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR110: CenterHost {
            @display("p=344,284;r=75");
        }
        hostR111: CenterHost {
            @display("p=275,284;r=75");
        }
        hostR112: CenterHost {
            @display("p=412,284;r=75");
        }
        hostR113: CenterHost {
            @display("p=344,337;r=75");
        }
        hostR114: CenterHost {
            @display("p=344,226;r=75");
        }
        hostR115: CenterHost {
            @display("p=478,284;r=75");
        }
        hostR116: CenterHost {
            @display("p=205,284;r=75");
        }
        hostR117: CenterHost {
            @display("p=236,343;r=75");
        }
        hostR118: CenterHost {
            @display("p=236,234;r=75");
        }
        hostR119: CenterHost {
            @display("p=457,343;r=75");
        }
        hostR120: CenterHost {
            @display("p=457,234;r=75");
        }
        hostR121: CenterHost {
            @display("p=344,408;r=75");
        }
        hostR122: CenterHost {
            @display("p=301,370;r=75");
        }
        hostR123: CenterHost {
            @display("p=406,376;r=75");
        }
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR124: CenterHost {
            @display("p=310,342;r=75");
        }
        hostR125: CenterHost {
            @display("p=241,342;r=75");
        }
        hostR126: CenterHost {
            @display("p=378,342;r=75");
        }
        hostR127: CenterHost {
            @display("p=310,395;r=75");
        }
        hostR128: CenterHost {
            @display("p=310,284;r=75");
        }
        hostR129: CenterHost {
            @display("p=444,342;r=75");
        }
        hostR130: CenterHost {
            @display("p=202,401;r=75");
        }
        hostR131: CenterHost {
            @display("p=202,292;r=75");
        }
        hostR132: CenterHost {
            @display("p=423,401;r=75");
        }
        hostR133: CenterHost {
            @display("p=423,292;r=75");
        }
        hostR134: CenterHost {
            @display("p=310,466;r=75");
        }
        hostR135: CenterHost {
            @display("p=267,428;r=75");
        }
        hostR136: CenterHost {
            @display("p=372,434;r=75");
        }
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR137: CenterHost {
            @display("p=388,343;r=75");
        }
        hostR138: CenterHost {
            @display("p=319,343;r=75");
        }
        hostR139: CenterHost {
            @display("p=456,343;r=75");
        }
        hostR140: CenterHost {
            @display("p=388,396;r=75");
        }
        hostR141: CenterHost {
            @display("p=388,285;r=75");
        }
        hostR142: CenterHost {
            @display("p=249,343;r=75");
        }
        hostR143: CenterHost {
            @display("p=280,402;r=75");
        }
        hostR144: CenterHost {
            @display("p=280,293;r=75");
        }
        hostR145: CenterHost {
            @display("p=501,402;r=75");
        }
        hostR146: CenterHost {
            @display("p=501,293;r=75");
        }
        hostR147: CenterHost {
            @display("p=388,467;r=75");
        }
        hostR148: CenterHost {
            @display("p=345,429;r=75");
        }
        hostR149: CenterHost {
            @display("p=450,435;r=75");
        }
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR150: CenterHost {
            @display("p=383,312;r=75");
        }
        hostR151: CenterHost {
            @display("p=314,312;r=75");
        }
        hostR152: CenterHost {
            @display("p=451,312;r=75");
        }
        hostR153: CenterHost {
            @display("p=383,365;r=75");
        }
        hostR154: CenterHost {
            @display("p=383,254;r=75");
        }
        hostR155: CenterHost {
            @display("p=517,312;r=75");
        }
        hostR156: CenterHost {
            @display("p=244,312;r=75");
        }
        hostR157: CenterHost {
            @display("p=275,371;r=75");
        }
        hostR158: CenterHost {
            @display("p=275,262;r=75");
        }
        hostR159: CenterHost {
            @display("p=496,371;r=75");
        }
        hostR160: CenterHost {
            @display("p=496,262;r=75");
        }
        hostR161: CenterHost {
            @display("p=383,436;r=75");
        }
        hostR162: CenterHost {
            @display("p=340,398;r=75");
        }
        hostR163: CenterHost {
            @display("p=445,404;r=75");
        }
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR164: CenterHost {
            @display("p=383,337;r=75");
        }
        hostR165: CenterHost {
            @display("p=314,337;r=75");
        }
        hostR166: CenterHost {
            @display("p=451,337;r=75");
        }
        hostR167: CenterHost {
            @display("p=383,390;r=75");
        }
        hostR168: CenterHost {
            @display("p=383,279;r=75");
        }
        hostR169: CenterHost {
            @display("p=517,337;r=75");
        }
        hostR170: CenterHost {
            @display("p=244,337;r=75");
        }
        hostR171: CenterHost {
            @display("p=275,396;r=75");
        }
        hostR172: CenterHost {
            @display("p=275,287;r=75");
        }
        hostR173: CenterHost {
            @display("p=496,396;r=75");
        }
        hostR174: CenterHost {
            @display("p=496,287;r=75");
        }
        hostR175: CenterHost {
            @display("p=383,461;r=75");
        }
        hostR176: CenterHost {
            @display("p=340,423;r=75");
        }
        hostR177: CenterHost {
            @display("p=445,429;r=75");
        }
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR178: CenterHost {
            @display("p=383,284;r=75");
        }
        hostR179: CenterHost {
            @display("p=314,284;r=75");
        }
        hostR180: CenterHost {
            @display("p=451,284;r=75");
        }
        hostR181: CenterHost {
            @display("p=383,337;r=75");
        }
        hostR182: CenterHost {
            @display("p=383,226;r=75");
        }
        hostR183: CenterHost {
            @display("p=517,284;r=75");
        }
        hostR184: CenterHost {
            @display("p=244,284;r=75");
        }
        hostR185: CenterHost {
            @display("p=275,343;r=75");
        }
        hostR186: CenterHost {
            @display("p=275,234;r=75");
        }
        hostR187: CenterHost {
            @display("p=496,343;r=75");
        }
        hostR188: CenterHost {
            @display("p=496,234;r=75");
        }
        hostR189: CenterHost {
            @display("p=383,408;r=75");
        }
        hostR190: CenterHost {
            @display("p=340,370;r=75");
        }
        hostR191: CenterHost {
            @display("p=445,376;r=75");
        }
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR192: CenterHost {
            @display("p=349,342;r=75");
        }
        hostR193: CenterHost {
            @display("p=280,342;r=75");
        }
        hostR194: CenterHost {
            @display("p=417,342;r=75");
        }
        hostR195: CenterHost {
            @display("p=349,395;r=75");
        }
        hostR196: CenterHost {
            @display("p=349,284;r=75");
        }
        hostR197: CenterHost {
            @display("p=483,342;r=75");
        }
        hostR198: CenterHost {
            @display("p=241,401;r=75");
        }
        hostR199: CenterHost {
            @display("p=241,292;r=75");
        }
        hostR200: CenterHost {
            @display("p=462,401;r=75");
        }
        hostR201: CenterHost {
            @display("p=462,292;r=75");
        }
        hostR202: CenterHost {
            @display("p=349,466;r=75");
        }
        hostR203: CenterHost {
            @display("p=306,428;r=75");
        }
        hostR204: CenterHost {
            @display("p=411,434;r=75");
        }
        //                hostR0: INetworkNode {
        //                    @display("p=362,312;r=180");
        //                }
        hostR205: CenterHost {
            @display("p=427,343;r=75");
        }
        hostR206: CenterHost {
            @display("p=358,343;r=75");
        }
        hostR207: CenterHost {
            @display("p=495,343;r=75");
        }
        hostR208: CenterHost {
            @display("p=427,396;r=75");
        }
        hostR209: CenterHost {
            @display("p=427,285;r=75");
        }
        hostR210: CenterHost {
            @display("p=288,343;r=75");
        }
        hostR211: CenterHost {
            @display("p=319,402;r=75");
        }
        hostR212: CenterHost {
            @display("p=319,293;r=75");
        }
        hostR213: CenterHost {
            @display("p=540,402;r=75");
        }
        hostR214: CenterHost {
            @display("p=540,293;r=75");
        }
        hostR215: CenterHost {
            @display("p=427,467;r=75");
        }
        hostR216: CenterHost {
            @display("p=384,429;r=75");
        }
        hostR217: CenterHost {
            @display("p=489,435;r=75");
        }
        hostR218: CenterHost {
            @display("p=79,46;r=75");
        }
        hostR219: CenterHost {
            @display("p=79,112;r=75");
        }
        hostR220: CenterHost {
            @display("p=141,32;r=75");
        }
        hostR221: CenterHost {
            @display("p=134,145;r=75");
        }
        hostR222: CenterHost {
            @display("p=102,198;r=75");
        }
        hostR223: CenterHost {
            @display("p=79,262;r=75");
        }
        hostR224: CenterHost {
            @display("p=102,312;r=75");
        }
        hostR225: CenterHost {
            @display("p=55,646;r=75");
        }
        hostR226: CenterHost {
            @display("p=69,469;r=75");
        }
        hostR227: CenterHost {
            @display("p=102,524;r=75");
        }
        hostR228: CenterHost {
            @display("p=87,584;r=75");
        }
        hostR229: CenterHost {
            @display("p=306,576;r=75");
        }
        hostR230: CenterHost {
            @display("p=163,557;r=75");
        }
        hostR231: CenterHost {
            @display("p=150,617;r=75");
        }
        hostR232: CenterHost {
            @display("p=228,576;r=75");
        }
        hostR233: CenterHost {
            @display("p=150,495;r=75");
        }
        hostR234: CenterHost {
            @display("p=378,609;r=75");
        }
        hostR235: CenterHost {
            @display("p=445,609;r=75");
        }
        hostR236: CenterHost {
            @display("p=489,576;r=75");
        }
        hostR237: CenterHost {
            @display("p=540,617;r=75");
        }
        hostR238: CenterHost {
            @display("p=550,551;r=75");
        }
        hostR239: CenterHost {
            @display("p=205,664;r=75");
        }
        hostR240: CenterHost {
            @display("p=605,590;r=75");
        }
        hostR241: CenterHost {
            @display("p=651,557;r=75");
        }
        hostR242: CenterHost {
            @display("p=636,646;r=75");
        }
        hostR243: CenterHost {
            @display("p=636,502;r=75");
        }
        hostR244: CenterHost {
            @display("p=589,479;r=75");
        }
        hostR245: CenterHost {
            @display("p=651,447;r=75");
        }
        hostR246: CenterHost {
            @display("p=612,408;r=75");
        }
        hostR247: CenterHost {
            @display("p=661,376;r=75");
        }
        hostR248: CenterHost {
            @display("p=622,325;r=75");
        }
        hostR249: CenterHost {
            @display("p=669,284;r=75");
        }
        hostR250: CenterHost {
            @display("p=669,160;r=75");
        }
        hostR251: CenterHost {
            @display("p=605,145;r=75");
        }
        hostR252: CenterHost {
            @display("p=550,136;r=75");
        }
        hostR253: CenterHost {
            @display("p=501,103;r=75");
        }
        hostR254: CenterHost {
            @display("p=441,136;r=75");
        }
        hostR255: CenterHost {
            @display("p=306,79;r=75");
        }
        hostR256: CenterHost {
            @display("p=202,136;r=75");
        }
}
