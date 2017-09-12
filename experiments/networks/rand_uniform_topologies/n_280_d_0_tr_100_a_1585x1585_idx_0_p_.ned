package rand_uniform_topologies;

import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.bgp.BGPRouter;
import inet.node.inet.AdhocHost;
import inet.node.inet.INetworkNode;
import inet.node.mpls.LDP_LSR;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import broadcasting.CenterHost;

network n_280_d_0_tr_100_a_1585x1585_idx_0_p_
{
    @display("bgb=1585, 1585");

    string mediumType = default("IdealRadioMedium");
    submodules:
        configurator: IPv4NetworkConfigurator {
            @display("p=0,0");
        }
        radioMedium: <mediumType> like IRadioMedium {
            @display("p=0,0");
        }

        hostR1: CenterHost {
            @display("p=1232,1257");
        }
        hostR2: CenterHost {
            @display("p=1388.14,327.132");
        }
        hostR3: CenterHost {
            @display("p=170.578,423.99");
        }
        hostR4: CenterHost {
            @display("p=1036.65,1383.35");
        }
        hostR5: CenterHost {
            @display("p=804,1054");
        }
        hostR6: CenterHost {
            @display("p=478,132");
        }
        hostR7: CenterHost {
            @display("p=1493.44,1203.21");
        }
        hostR8: CenterHost {
            @display("p=1448,1112");
        }
        hostR9: CenterHost {
            @display("p=304,1384");
        }
        hostR10: CenterHost {
            @display("p=519.471,1473.31");
        }
        hostR11: CenterHost {
            @display("p=1474.01,166.775");
        }
        hostR12: CenterHost {
            @display("p=342.546,1276.76");
        }
        hostR13: CenterHost {
            @display("p=191,721");
        }
        hostR14: CenterHost {
            @display("p=362,137");
        }
        hostR15: CenterHost {
            @display("p=1133.6,180.69");
        }
        hostR16: CenterHost {
            @display("p=1203,737");
        }
        hostR17: CenterHost {
            @display("p=907.081,1106.94");
        }
        hostR18: CenterHost {
            @display("p=252,230");
        }
        hostR19: CenterHost {
            @display("p=1455,450");
        }
        hostR20: CenterHost {
            @display("p=1445.81,205.042");
        }
        hostR21: CenterHost {
            @display("p=1164.42,639.11");
        }
        hostR22: CenterHost {
            @display("p=199,333");
        }
        hostR23: CenterHost {
            @display("p=198,899");
        }
        hostR24: CenterHost {
            @display("p=1290,721");
        }
        hostR25: CenterHost {
            @display("p=228,641");
        }
        hostR26: CenterHost {
            @display("p=491.398,431.387");
        }
        hostR27: CenterHost {
            @display("p=1279,148");
        }
        hostR28: CenterHost {
            @display("p=475,1079");
        }
        hostR29: CenterHost {
            @display("p=1279.71,1110.23");
        }
        hostR30: CenterHost {
            @display("p=347.376,1035.01");
        }
        hostR31: CenterHost {
            @display("p=459.54,1462.05");
        }
        hostR32: CenterHost {
            @display("p=207.496,494.108");
        }
        hostR33: CenterHost {
            @display("p=462.221,1349.68");
        }
        hostR34: CenterHost {
            @display("p=374,1452");
        }
        hostR35: CenterHost {
            @display("p=180.87,1210.59");
        }
        hostR36: CenterHost {
            @display("p=365.41,556.575");
        }
        hostR37: CenterHost {
            @display("p=1177,1110");
        }
        hostR38: CenterHost {
            @display("p=382.636,1118.59");
        }
        hostR39: CenterHost {
            @display("p=545.628,1045.68");
        }
        hostR40: CenterHost {
            @display("p=1217.67,568.019");
        }
        hostR41: CenterHost {
            @display("p=1359.94,499.79");
        }
        hostR42: CenterHost {
            @display("p=237,262");
        }
        hostR43: CenterHost {
            @display("p=1146,1271");
        }
        hostR44: CenterHost {
            @display("p=459,188");
        }
        hostR45: CenterHost {
            @display("p=264,1478");
        }
        hostR46: CenterHost {
            @display("p=1455.6,830.829");
        }
        hostR47: CenterHost {
            @display("p=498.481,728.632");
        }
        hostR48: CenterHost {
            @display("p=764,1333");
        }
        hostR49: CenterHost {
            @display("p=1167.65,267.633");
        }
        hostR50: CenterHost {
            @display("p=168,593");
        }
        hostR51: CenterHost {
            @display("p=843.526,362.195");
        }
        hostR52: CenterHost {
            @display("p=526.735,1279.02");
        }
        hostR53: CenterHost {
            @display("p=1286,1270");
        }
        hostR54: CenterHost {
            @display("p=388.561,593.167");
        }
        hostR55: CenterHost {
            @display("p=491.315,804.783");
        }
        hostR56: CenterHost {
            @display("p=885.93,513.952");
        }
        hostR57: CenterHost {
            @display("p=712,1370");
        }
        hostR58: CenterHost {
            @display("p=268.162,1226.32");
        }
        hostR59: CenterHost {
            @display("p=1376.37,940.212");
        }
        hostR60: CenterHost {
            @display("p=399.721,209.912");
        }
        hostR61: CenterHost {
            @display("p=1455,413");
        }
        hostR62: CenterHost {
            @display("p=1218,169");
        }
        hostR63: CenterHost {
            @display("p=974,532");
        }
        hostR64: CenterHost {
            @display("p=648,1373");
        }
        hostR65: CenterHost {
            @display("p=1309.26,1021.43");
        }
        hostR66: CenterHost {
            @display("p=91,864");
        }
        hostR67: CenterHost {
            @display("p=1415,1106");
        }
        hostR68: CenterHost {
            @display("p=328.488,1102.75");
        }
        hostR69: CenterHost {
            @display("p=648,246");
        }
        hostR70: CenterHost {
            @display("p=872.397,1281.63");
        }
        hostR71: CenterHost {
            @display("p=551.481,1172.28");
        }
        hostR72: CenterHost {
            @display("p=338.148,809.575");
        }
        hostR73: CenterHost {
            @display("p=1063,1257");
        }
        hostR74: CenterHost {
            @display("p=1495.04,1287.14");
        }
        hostR75: CenterHost {
            @display("p=341,169");
        }
        hostR76: CenterHost {
            @display("p=447.831,1396.23");
        }
        hostR77: CenterHost {
            @display("p=1506.49,758.021");
        }
        hostR78: CenterHost {
            @display("p=1450,951");
        }
        hostR79: CenterHost {
            @display("p=1205.15,1307.06");
        }
        hostR80: CenterHost {
            @display("p=1218.01,495.005");
        }
        hostR81: CenterHost {
            @display("p=732.809,262.162");
        }
        hostR82: CenterHost {
            @display("p=720,1118");
        }
        hostR83: CenterHost {
            @display("p=437,679");
        }
        hostR84: CenterHost {
            @display("p=1146,890;r=100");
        }
        hostR85: CenterHost {
            @display("p=495.886,1181.17");
        }
        hostR86: CenterHost {
            @display("p=1107.33,440.063");
        }
        hostR87: CenterHost {
            @display("p=1347.57,257.871");
        }
        hostR88: CenterHost {
            @display("p=597.959,447.644");
        }
        hostR89: CenterHost {
            @display("p=519.173,522.887");
        }
        hostR90: CenterHost {
            @display("p=1075,180");
        }
        hostR91: CenterHost {
            @display("p=953.694,304.192");
        }
        hostR92: CenterHost {
            @display("p=769,1266");
        }
        hostR93: CenterHost {
            @display("p=374.723,1249.95");
        }
        hostR94: CenterHost {
            @display("p=413.99,801.846");
        }
        hostR95: CenterHost {
            @display("p=1343.01,422.957");
        }
        hostR96: CenterHost {
            @display("p=1126.62,541.034");
        }
        hostR97: CenterHost {
            @display("p=645,1070");
        }
        hostR98: CenterHost {
            @display("p=1320.2,1199.55");
        }
        hostR99: CenterHost {
            @display("p=447,935");
        }
        hostR100: CenterHost {
            @display("p=1062.72,420.123");
        }
        hostR101: CenterHost {
            @display("p=854.565,1181.27");
        }
        hostR102: CenterHost {
            @display("p=442.026,1235.24");
        }
        hostR103: CenterHost {
            @display("p=260.998,1271.54");
        }
        hostR104: CenterHost {
            @display("p=1210.16,603.704");
        }
        hostR105: CenterHost {
            @display("p=1058.0,1079.22");
        }
        hostR106: CenterHost {
            @display("p=1113,974");
        }
        hostR107: CenterHost {
            @display("p=882.848,478.614");
        }
        hostR108: CenterHost {
            @display("p=1097,295");
        }
        hostR109: CenterHost {
            @display("p=982.135,246.814");
        }
        hostR110: CenterHost {
            @display("p=826.719,445.235");
        }
        hostR111: CenterHost {
            @display("p=720.145,523.875");
        }
        hostR112: CenterHost {
            @display("p=704.079,400.702");
        }
        hostR113: CenterHost {
            @display("p=856.784,246.149");
        }
        hostR114: CenterHost {
            @display("p=873.58,413.334");
        }
        hostR115: CenterHost {
            @display("p=590.492,1166.55");
        }
        hostR116: CenterHost {
            @display("p=975.606,1231.24");
        }
        hostR117: CenterHost {
            @display("p=301.148,1135.16");
        }
        hostR118: CenterHost {
            @display("p=308.518,496.801");
        }
        hostR119: CenterHost {
            @display("p=1177.0,372.192");
        }
        hostR120: CenterHost {
            @display("p=475.893,974.757");
        }
        hostR121: CenterHost {
            @display("p=702.579,429.378");
        }
        hostR122: CenterHost {
            @display("p=559.729,265.842");
        }
        hostR123: CenterHost {
            @display("p=508.052,309.066");
        }
        hostR124: CenterHost {
            @display("p=857.852,358.63");
        }
        hostR125: CenterHost {
            @display("p=575.019,1328.15");
        }
        hostR126: CenterHost {
            @display("p=1225.86,840.665");
        }
        hostR127: CenterHost {
            @display("p=342.268,279.564");
        }
        hostR128: CenterHost {
            @display("p=720,1235");
        }
        hostR129: CenterHost {
            @display("p=1290.18,338.009");
        }
        hostR130: CenterHost {
            @display("p=285,899");
        }
        hostR131: CenterHost {
            @display("p=840.284,1344.14");
        }
        hostR132: CenterHost {
            @display("p=1252,233");
        }
        hostR133: CenterHost {
            @display("p=297.334,1037.53");
        }
        hostR134: CenterHost {
            @display("p=1293.51,890.821");
        }
        hostR135: CenterHost {
            @display("p=409.219,866.9");
        }
        hostR136: CenterHost {
            @display("p=974.665,1156.57");
        }
        hostR137: CenterHost {
            @display("p=1175.11,506.049");
        }
        hostR138: CenterHost {
            @display("p=263.546,429.909");
        }
        hostR139: CenterHost {
            @display("p=398.564,971.472");
        }
        hostR140: CenterHost {
            @display("p=294.393,567.632");
        }
        hostR141: CenterHost {
            @display("p=954.13,954.98");
        }
        hostR142: CenterHost {
            @display("p=600.64,693.24");
        }
        hostR143: CenterHost {
            @display("p=813.636,610.154");
        }
        hostR144: CenterHost {
            @display("p=552.3856,874.905");
        }
        hostR145: CenterHost {
            @display("p=632.58,645.761");
        }
        hostR146: CenterHost {
            @display("p=789.712,828.796");
        }
        hostR147: CenterHost {
            @display("p=588.6754,619.713");
        }
        hostR148: CenterHost {
            @display("p=858.925,915.149");
        }
        hostR149: CenterHost {
            @display("p=563.3085,908.989");
        }
        hostR150: CenterHost {
            @display("p=1016.084,982.891");
        }
        hostR151: CenterHost {
            @display("p=815.491,561.7167");
        }
        hostR152: CenterHost {
            @display("p=563.7552,665.223");
        }
        hostR153: CenterHost {
            @display("p=575.975,673.673");
        }
        hostR154: CenterHost {
            @display("p=554.6081,897.11");
        }
        hostR155: CenterHost {
            @display("p=837.191,953.791");
        }
        hostR156: CenterHost {
            @display("p=580.148,757.695");
        }
        hostR157: CenterHost {
            @display("p=899.937,599.4773");
        }
        hostR158: CenterHost {
            @display("p=527.235,581.8936");
        }
        hostR159: CenterHost {
            @display("p=976.955,882.055");
        }
        hostR160: CenterHost {
            @display("p=551.1765,958.629");
        }
        hostR161: CenterHost {
            @display("p=957.816,814.527");
        }
        hostR162: CenterHost {
            @display("p=645.376,699.635");
        }
        hostR163: CenterHost {
            @display("p=937.07,842.503");
        }
        hostR164: CenterHost {
            @display("p=640.232,519.4727");
        }
        hostR165: CenterHost {
            @display("p=788.71,623.835");
        }
        hostR166: CenterHost {
            @display("p=716.876,661.308");
        }
        hostR167: CenterHost {
            @display("p=731.764,658.594");
        }
        hostR168: CenterHost {
            @display("p=812.193,566.6778");
        }
        hostR169: CenterHost {
            @display("p=860.595,663.429");
        }
        hostR170: CenterHost {
            @display("p=723.627,779.722");
        }
        hostR171: CenterHost {
            @display("p=899.415,997.448");
        }
        hostR172: CenterHost {
            @display("p=565.5777,629.584");
        }
        hostR173: CenterHost {
            @display("p=761.28,749.193");
        }
        hostR174: CenterHost {
            @display("p=870.891,556.9998");
        }
        hostR175: CenterHost {
            @display("p=636.739,568.417");
        }
        hostR176: CenterHost {
            @display("p=573.3377,696.68");
        }
        hostR177: CenterHost {
            @display("p=712.446,611.045");
        }
        hostR178: CenterHost {
            @display("p=507.41098,759.058");
        }
        hostR179: CenterHost {
            @display("p=545.9946,906.062");
        }
        hostR180: CenterHost {
            @display("p=805.395,935.778");
        }
        hostR181: CenterHost {
            @display("p=563.2412,642.294");
        }
        hostR182: CenterHost {
            @display("p=624.063,739.493");
        }
        hostR183: CenterHost {
            @display("p=1009.154,851.798;r=100");
        }
        hostR184: CenterHost {
            @display("p=914.44,879.65");
        }
        hostR185: CenterHost {
            @display("p=633.569,868.769");
        }
        hostR186: CenterHost {
            @display("p=875.889,1005.447");
        }
        hostR187: CenterHost {
            @display("p=722.974,728.942");
        }
        hostR188: CenterHost {
            @display("p=905.146,639.49");
        }
        hostR189: CenterHost {
            @display("p=974.476,1012.499");
        }
        hostR190: CenterHost {
            @display("p=585.708,693.033");
        }
        hostR191: CenterHost {
            @display("p=558.3958,503.79608");
        }
        hostR192: CenterHost {
            @display("p=677.769,793.579");
        }
        hostR193: CenterHost {
            @display("p=768.429,969.074");
        }
        hostR194: CenterHost {
            @display("p=974.74,781.373");
        }
        hostR195: CenterHost {
            @display("p=1008.762,751.528");
        }
        hostR196: CenterHost {
            @display("p=918.126,978.292");
        }
        hostR197: CenterHost {
            @display("p=549.5941,966.501");
        }
        hostR198: CenterHost {
            @display("p=885.955,1002.287");
        }
        hostR199: CenterHost {
            @display("p=869.994,663.506");
        }
        hostR200: CenterHost {
            @display("p=520.9104,674.224");
        }
        hostR201: CenterHost {
            @display("p=939.941,819.631");
        }
        hostR202: CenterHost {
            @display("p=659.964,913.807");
        }
        hostR203: CenterHost {
            @display("p=977.517,669.725");
        }
        hostR204: CenterHost {
            @display("p=611.989,680.899");
        }
        hostR205: CenterHost {
            @display("p=843.646,769.824");
        }
        hostR206: CenterHost {
            @display("p=993.492,931.16");
        }
        hostR207: CenterHost {
            @display("p=853.82,526.7586");
        }
        hostR208: CenterHost {
            @display("p=1029.062,1024.282");
        }
        hostR209: CenterHost {
            @display("p=980.701,960.764");
        }
        hostR210: CenterHost {
            @display("p=503.08578,571.6");
        }
        hostR211: CenterHost {
            @display("p=680.419,972.36");
        }
        hostR212: CenterHost {
            @display("p=743.176,907.812");
        }
        hostR213: CenterHost {
            @display("p=981.69,526.1698");
        }
        hostR214: CenterHost {
            @display("p=759.482,866.56");
        }
        hostR215: CenterHost {
            @display("p=540.7649,959.016");
        }
        hostR216: CenterHost {
            @display("p=899.331,575.4936");
        }
        hostR217: CenterHost {
            @display("p=738.845,888.973");
        }
        hostR218: CenterHost {
            @display("p=973.563,753.918");
        }
        hostR219: CenterHost {
            @display("p=739.272,734.48");
        }
        hostR220: CenterHost {
            @display("p=920.457,995.587");
        }
        hostR221: CenterHost {
            @display("p=749.074,883.264");
        }
        hostR222: CenterHost {
            @display("p=605.532,540.9161");
        }
        hostR223: CenterHost {
            @display("p=1009.569,702.936");
        }
        hostR224: CenterHost {
            @display("p=971.296,945.019");
        }
        hostR225: CenterHost {
            @display("p=776.693,717.131");
        }
        hostR226: CenterHost {
            @display("p=655.947,529.6145");
        }
        hostR227: CenterHost {
            @display("p=1000.548,973.31");
        }
        hostR228: CenterHost {
            @display("p=892.152,965.076");
        }
        hostR229: CenterHost {
            @display("p=564.6182,720.219");
        }
        hostR230: CenterHost {
            @display("p=856.853,740.162");
        }
        hostR231: CenterHost {
            @display("p=587.0233,751.254");
        }
        hostR232: CenterHost {
            @display("p=543.7322,891.943");
        }
        hostR233: CenterHost {
            @display("p=656.242,989.525");
        }
        hostR234: CenterHost {
            @display("p=552.2074,691.705");
        }
        hostR235: CenterHost {
            @display("p=851.622,982.688");
        }
        hostR236: CenterHost {
            @display("p=996.128,964.409");
        }
        hostR237: CenterHost {
            @display("p=854.674,569.3762");
        }
        hostR238: CenterHost {
            @display("p=798.409,652.033");
        }
        hostR239: CenterHost {
            @display("p=558.3085,507.80746");
        }
        hostR240: CenterHost {
            @display("p=589.2799,720.462");
        }
        hostR241: CenterHost {
            @display("p=950.332,764.344");
        }
        hostR242: CenterHost {
            @display("p=904.28,862.103");
        }
        hostR243: CenterHost {
            @display("p=553.1383,563.8684");
        }
        hostR244: CenterHost {
            @display("p=523.9092,571.7624");
        }
        hostR245: CenterHost {
            @display("p=871.064,1021.104");
        }
        hostR246: CenterHost {
            @display("p=676.719,966.678");
        }
        hostR247: CenterHost {
            @display("p=610.403,668.442");
        }
        hostR248: CenterHost {
            @display("p=870.981,513.0926");
        }
        hostR249: CenterHost {
            @display("p=966.725,548.8256");
        }
        hostR250: CenterHost {
            @display("p=572.4258,945.254");
        }
        hostR251: CenterHost {
            @display("p=746.767,1003.847");
        }
        hostR252: CenterHost {
            @display("p=745.88,630.209");
        }
        hostR253: CenterHost {
            @display("p=733.587,531.7154");
        }
        hostR254: CenterHost {
            @display("p=770.261,698.169");
        }
        hostR255: CenterHost {
            @display("p=727.733,631.774");
        }
        hostR256: CenterHost {
            @display("p=965.574,843.259");
        }
        hostR257: CenterHost {
            @display("p=937.502,752.367");
        }
        hostR258: CenterHost {
            @display("p=567.7078,657.365");
        }
        hostR259: CenterHost {
            @display("p=726.293,830.164");
        }
        hostR260: CenterHost {
            @display("p=654.352,759.818");
        }
        hostR261: CenterHost {
            @display("p=968.732,566.5382");
        }
        hostR262: CenterHost {
            @display("p=817.374,671.956");
        }
        hostR263: CenterHost {
            @display("p=781.105,728.572");
        }
        hostR264: CenterHost {
            @display("p=854.069,865.606");
        }
        hostR265: CenterHost {
            @display("p=741.368,567.2135");
        }
        hostR266: CenterHost {
            @display("p=937.174,600.253");
        }
        hostR267: CenterHost {
            @display("p=848.341,855.765");
        }
        hostR268: CenterHost {
            @display("p=647.72,716.286");
        }
        hostR269: CenterHost {
            @display("p=556.2483,921.659");
        }
        hostR270: CenterHost {
            @display("p=586.8264,875.033");
        }
        hostR271: CenterHost {
            @display("p=923.15,968.747");
        }
        hostR272: CenterHost {
            @display("p=902.995,739.166");
        }
        hostR273: CenterHost {
            @display("p=974.598,951.382");
        }
        hostR274: CenterHost {
            @display("p=540.2292,599.8383");
        }
        hostR275: CenterHost {
            @display("p=744.32,849.492");
        }
        hostR276: CenterHost {
            @display("p=719.61,784.047");
        }
        hostR277: CenterHost {
            @display("p=552.7096,929.357");
        }
        hostR278: CenterHost {
            @display("p=858.863,1022.346");
        }
        hostR279: CenterHost {
            @display("p=972.427,682.242");
        }
        hostR280: CenterHost {
            @display("p=1016.85,1027.184");
        }
}
