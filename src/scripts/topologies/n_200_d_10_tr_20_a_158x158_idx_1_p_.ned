package builtTopologies;

import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import broadcasting.CenterHost;

network n_200_d_10_tr_20_a_158x158_idx_1_p_.ned {
  @display("bgb=158, 158");

  string mediumType = default("IdealRadioMedium");
  submodules:
  configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
  radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
  
  hostR0 : CenterHost{ @display("p=123.104329496,133.321010204");  }
  
  hostR1 : CenterHost{ @display("p=109.736177711,26.1028899187");  }
  
  hostR2 : CenterHost{ @display("p=61.2009534212,3.63360790464");  }
  
  hostR3 : CenterHost{ @display("p=131.270623475,84.8465226279");  }
  
  hostR4 : CenterHost{ @display("p=153.517288837,25.8667316756");  }
  
  hostR5 : CenterHost{ @display("p=52.1903714659,98.1813883011");  }
  
  hostR6 : CenterHost{ @display("p=63.9967596418,82.1883282653");  }
  
  hostR7 : CenterHost{ @display("p=25.8480826832,102.914324517");  }
  
  hostR8 : CenterHost{ @display("p=18.538454687,149.917971449");  }
  
  hostR9 : CenterHost{ @display("p=87.9256799014,18.9068821534");  }
  
  hostR10 : CenterHost{ @display("p=111.583403418,138.610919018");  }
  
  hostR11 : CenterHost{ @display("p=57.9384234371,22.4658436739");  }
  
  hostR12 : CenterHost{ @display("p=113.298369522,116.291299823");  }
  
  hostR13 : CenterHost{ @display("p=17.9480555318,134.390040902");  }
  
  hostR14 : CenterHost{ @display("p=60.925666116,49.2583505758");  }
  
  hostR15 : CenterHost{ @display("p=23.3093789882,76.2753239019");  }
  
  hostR16 : CenterHost{ @display("p=84.7450282747,60.7495793151");  }
  
  hostR17 : CenterHost{ @display("p=136.141343189,118.579022363");  }
  
  hostR18 : CenterHost{ @display("p=60.4097176619,29.2093450926");  }
  
  hostR19 : CenterHost{ @display("p=71.6547015316,146.537607145");  }
  
  hostR20 : CenterHost{ @display("p=8.81340363571,73.5065548385");  }
  
  hostR21 : CenterHost{ @display("p=82.6189056573,18.1704720315");  }
  
  hostR22 : CenterHost{ @display("p=68.606897601,43.3070932513");  }
  
  hostR23 : CenterHost{ @display("p=41.7275178109,81.6312500389");  }
  
  hostR24 : CenterHost{ @display("p=7.40799241713,6.25185517449");  }
  
  hostR25 : CenterHost{ @display("p=35.8759240217,67.3088531986");  }
  
  hostR26 : CenterHost{ @display("p=85.7846600257,128.376231986");  }
  
  hostR27 : CenterHost{ @display("p=81.8544304694,157.666797601");  }
  
  hostR28 : CenterHost{ @display("p=142.009089385,61.9848632192");  }
  
  hostR29 : CenterHost{ @display("p=18.9022023038,85.2595748702");  }
  
  hostR30 : CenterHost{ @display("p=143.744081804,79.296001651");  }
  
  hostR31 : CenterHost{ @display("p=31.6153060888,58.3545233414");  }
  
  hostR32 : CenterHost{ @display("p=25.3817286587,20.5411009557");  }
  
  hostR33 : CenterHost{ @display("p=120.208619159,39.7579623152");  }
  
  hostR34 : CenterHost{ @display("p=39.6139278392,61.7732190845");  }
  
  hostR35 : CenterHost{ @display("p=118.101972428,51.3306325325");  }
  
  hostR36 : CenterHost{ @display("p=126.797452601,156.657381242");  }
  
  hostR37 : CenterHost{ @display("p=42.959919537,141.682562321");  }
  
  hostR38 : CenterHost{ @display("p=38.0885792275,23.0990197372");  }
  
  hostR39 : CenterHost{ @display("p=109.911225916,103.690779567"); isCenter=true; }
  
  hostR40 : CenterHost{ @display("p=99.1569783496,85.2646174547");  }
  
  hostR41 : CenterHost{ @display("p=12.4360401062,85.904528453");  }
  
  hostR42 : CenterHost{ @display("p=116.436209854,93.2424074308");  }
  
  hostR43 : CenterHost{ @display("p=10.339565036,68.8788223467");  }
  
  hostR44 : CenterHost{ @display("p=153.391852794,62.0369636743");  }
  
  hostR45 : CenterHost{ @display("p=68.0675392858,43.9347592818");  }
  
  hostR46 : CenterHost{ @display("p=61.6432447957,107.231995217");  }
  
  hostR47 : CenterHost{ @display("p=13.7953522785,81.5467483831");  }
  
  hostR48 : CenterHost{ @display("p=120.756308627,40.4148120031");  }
  
  hostR49 : CenterHost{ @display("p=6.93819389805,61.5078277121");  }
  
  hostR50 : CenterHost{ @display("p=69.0039215239,140.070022576");  }
  
  hostR51 : CenterHost{ @display("p=39.1783391054,147.036043789");  }
  
  hostR52 : CenterHost{ @display("p=31.7703909257,94.4666748725");  }
  
  hostR53 : CenterHost{ @display("p=51.0626451784,48.0352799596");  }
  
  hostR54 : CenterHost{ @display("p=103.529803746,77.0948870006");  }
  
  hostR55 : CenterHost{ @display("p=131.908695718,34.098747091");  }
  
  hostR56 : CenterHost{ @display("p=156.477278363,58.1189366335");  }
  
  hostR57 : CenterHost{ @display("p=113.090717072,30.5694279118");  }
  
  hostR58 : CenterHost{ @display("p=22.4619235304,147.202861906");  }
  
  hostR59 : CenterHost{ @display("p=11.639868669,91.2204555194");  }
  
  hostR60 : CenterHost{ @display("p=26.6404466509,137.744488409");  }
  
  hostR61 : CenterHost{ @display("p=46.8963358305,39.7143726462");  }
  
  hostR62 : CenterHost{ @display("p=123.736915973,60.4992328614");  }
  
  hostR63 : CenterHost{ @display("p=114.905415044,46.6749340282");  }
  
  hostR64 : CenterHost{ @display("p=135.76958313,89.8773870563");  }
  
  hostR65 : CenterHost{ @display("p=11.8727592167,58.6163083639");  }
  
  hostR66 : CenterHost{ @display("p=42.7151426865,140.050102434");  }
  
  hostR67 : CenterHost{ @display("p=58.0825470828,34.1024776084");  }
  
  hostR68 : CenterHost{ @display("p=18.394594673,52.6972671435");  }
  
  hostR69 : CenterHost{ @display("p=21.9711354419,34.9384788257");  }
  
  hostR70 : CenterHost{ @display("p=132.054820368,140.293018065");  }
  
  hostR71 : CenterHost{ @display("p=146.01980065,87.6513244388");  }
  
  hostR72 : CenterHost{ @display("p=40.8175241506,24.1931635297");  }
  
  hostR73 : CenterHost{ @display("p=121.142396235,74.8582329126");  }
  
  hostR74 : CenterHost{ @display("p=70.4646142314,98.5591431058");  }
  
  hostR75 : CenterHost{ @display("p=14.5060304231,49.6316464711");  }
  
  hostR76 : CenterHost{ @display("p=17.3533291695,119.156788053");  }
  
  hostR77 : CenterHost{ @display("p=148.358178165,121.360662689");  }
  
  hostR78 : CenterHost{ @display("p=64.8584922857,32.1684145413");  }
  
  hostR79 : CenterHost{ @display("p=64.809065948,98.5019382994");  }
  
  hostR80 : CenterHost{ @display("p=45.719308787,156.255070451");  }
  
  hostR81 : CenterHost{ @display("p=140.503633439,91.3614421679");  }
  
  hostR82 : CenterHost{ @display("p=59.4514845656,118.674613841");  }
  
  hostR83 : CenterHost{ @display("p=10.0046352604,56.8748969387");  }
  
  hostR84 : CenterHost{ @display("p=107.047697769,109.40514854");  }
  
  hostR85 : CenterHost{ @display("p=30.7582922726,154.743153963");  }
  
  hostR86 : CenterHost{ @display("p=127.917516243,91.6770447688");  }
  
  hostR87 : CenterHost{ @display("p=63.5360051071,73.9460742049");  }
  
  hostR88 : CenterHost{ @display("p=73.7742167207,93.0006315422");  }
  
  hostR89 : CenterHost{ @display("p=60.2949417089,25.9089066225");  }
  
  hostR90 : CenterHost{ @display("p=144.75059773,9.56970790903");  }
  
  hostR91 : CenterHost{ @display("p=112.527155783,45.5762766512");  }
  
  hostR92 : CenterHost{ @display("p=115.350081856,110.250197842");  }
  
  hostR93 : CenterHost{ @display("p=29.8029177891,79.9288078548");  }
  
  hostR94 : CenterHost{ @display("p=136.914196333,115.254559884");  }
  
  hostR95 : CenterHost{ @display("p=130.531226031,1.06768422468");  }
  
  hostR96 : CenterHost{ @display("p=38.2743527157,46.0665196024");  }
  
  hostR97 : CenterHost{ @display("p=138.811901807,68.2653189025");  }
  
  hostR98 : CenterHost{ @display("p=36.1722561095,127.05513732");  }
  
  hostR99 : CenterHost{ @display("p=48.4407104497,127.792958625");  }
  
  hostR100 : CenterHost{ @display("p=144.163182983,58.4203821906");  }
  
  hostR101 : CenterHost{ @display("p=63.6389826161,122.425322819");  }
  
  hostR102 : CenterHost{ @display("p=155.963865691,117.060581994");  }
  
  hostR103 : CenterHost{ @display("p=64.2705372134,149.512151033");  }
  
  hostR104 : CenterHost{ @display("p=123.786786244,27.8039212377");  }
  
  hostR105 : CenterHost{ @display("p=139.639399562,70.8401113711");  }
  
  hostR106 : CenterHost{ @display("p=74.8833265229,144.648493719");  }
  
  hostR107 : CenterHost{ @display("p=40.5462179579,26.3065040964");  }
  
  hostR108 : CenterHost{ @display("p=142.043587763,141.204475332");  }
  
  hostR109 : CenterHost{ @display("p=93.6829304517,84.6570593177");  }
  
  hostR110 : CenterHost{ @display("p=82.668884718,92.2274015487");  }
  
  hostR111 : CenterHost{ @display("p=17.2970299396,142.072607809");  }
  
  hostR112 : CenterHost{ @display("p=34.1695024935,81.3615264112");  }
  
  hostR113 : CenterHost{ @display("p=70.4034968102,41.3763806029");  }
  
  hostR114 : CenterHost{ @display("p=102.187089679,139.460570059");  }
  
  hostR115 : CenterHost{ @display("p=96.5122279723,22.8969927983");  }
  
  hostR116 : CenterHost{ @display("p=46.3483966701,156.730971108");  }
  
  hostR117 : CenterHost{ @display("p=70.1644032204,132.787868701");  }
  
  hostR118 : CenterHost{ @display("p=115.853540165,113.085111663");  }
  
  hostR119 : CenterHost{ @display("p=67.7695730481,136.708732248");  }
  
  hostR120 : CenterHost{ @display("p=153.677195069,50.2765966786");  }
  
  hostR121 : CenterHost{ @display("p=54.1656452425,28.3830796312");  }
  
  hostR122 : CenterHost{ @display("p=43.1913718841,93.6427013112");  }
  
  hostR123 : CenterHost{ @display("p=14.1939621019,79.8984352792");  }
  
  hostR124 : CenterHost{ @display("p=2.64534771413,75.079421361");  }
  
  hostR125 : CenterHost{ @display("p=65.0104487155,111.264122022");  }
  
  hostR126 : CenterHost{ @display("p=85.9648224413,129.837163038");  }
  
  hostR127 : CenterHost{ @display("p=5.69923697083,1.37306577285");  }
  
  hostR128 : CenterHost{ @display("p=132.74175548,46.5891515667");  }
  
  hostR129 : CenterHost{ @display("p=145.739266599,61.6404584445");  }
  
  hostR130 : CenterHost{ @display("p=148.242552317,14.3378255007");  }
  
  hostR131 : CenterHost{ @display("p=123.163746016,50.8438657944");  }
  
  hostR132 : CenterHost{ @display("p=28.4325866609,10.024521498");  }
  
  hostR133 : CenterHost{ @display("p=14.9334525453,112.507045876");  }
  
  hostR134 : CenterHost{ @display("p=127.22337801,111.748681922");  }
  
  hostR135 : CenterHost{ @display("p=54.8303022829,89.864802896");  }
  
  hostR136 : CenterHost{ @display("p=141.459589932,135.374663774");  }
  
  hostR137 : CenterHost{ @display("p=86.026822744,94.0407070683");  }
  
  hostR138 : CenterHost{ @display("p=47.4332577836,157.972558818");  }
  
  hostR139 : CenterHost{ @display("p=61.5341159586,97.2123374591");  }
  
  hostR140 : CenterHost{ @display("p=75.4158048025,11.9341338971");  }
  
  hostR141 : CenterHost{ @display("p=42.7558778272,71.1218134466");  }
  
  hostR142 : CenterHost{ @display("p=83.3647992663,107.367854666");  }
  
  hostR143 : CenterHost{ @display("p=15.7168713932,107.481331391");  }
  
  hostR144 : CenterHost{ @display("p=95.6731685201,136.786781376");  }
  
  hostR145 : CenterHost{ @display("p=47.9370519939,23.232559844");  }
  
  hostR146 : CenterHost{ @display("p=108.10854491,107.708548922");  }
  
  hostR147 : CenterHost{ @display("p=62.744164896,2.55640417317");  }
  
  hostR148 : CenterHost{ @display("p=99.0040375614,19.1517801125");  }
  
  hostR149 : CenterHost{ @display("p=86.5726392794,3.45831034081");  }
  
  hostR150 : CenterHost{ @display("p=132.786475449,25.9111729047");  }
  
  hostR151 : CenterHost{ @display("p=156.087796022,115.235655613");  }
  
  hostR152 : CenterHost{ @display("p=91.4916813262,20.5967824612");  }
  
  hostR153 : CenterHost{ @display("p=115.178912724,134.720795995");  }
  
  hostR154 : CenterHost{ @display("p=153.672894462,31.9735966687");  }
  
  hostR155 : CenterHost{ @display("p=39.1651207227,20.7245392492");  }
  
  hostR156 : CenterHost{ @display("p=36.1627451371,148.637565987");  }
  
  hostR157 : CenterHost{ @display("p=63.7648970776,25.8891611499");  }
  
  hostR158 : CenterHost{ @display("p=97.7717854893,94.009865665");  }
  
  hostR159 : CenterHost{ @display("p=126.161269037,65.9743277063");  }
  
  hostR160 : CenterHost{ @display("p=79.8237659781,135.046633024");  }
  
  hostR161 : CenterHost{ @display("p=31.1013271609,84.5164752565");  }
  
  hostR162 : CenterHost{ @display("p=112.947019159,60.1645477781");  }
  
  hostR163 : CenterHost{ @display("p=71.8389241317,15.1109467669");  }
  
  hostR164 : CenterHost{ @display("p=26.4127030337,102.383340109");  }
  
  hostR165 : CenterHost{ @display("p=102.13420787,141.336539994");  }
  
  hostR166 : CenterHost{ @display("p=9.7491005979,8.3079420895");  }
  
  hostR167 : CenterHost{ @display("p=23.745643775,43.7003151324");  }
  
  hostR168 : CenterHost{ @display("p=94.9842054478,77.2432126266");  }
  
  hostR169 : CenterHost{ @display("p=112.418782756,35.566642053");  }
  
  hostR170 : CenterHost{ @display("p=20.0477771504,28.8819485113");  }
  
  hostR171 : CenterHost{ @display("p=49.6081931146,57.4338209135");  }
  
  hostR172 : CenterHost{ @display("p=49.7718422015,26.4907133725");  }
  
  hostR173 : CenterHost{ @display("p=142.693514611,134.451113642");  }
  
  hostR174 : CenterHost{ @display("p=42.7546039092,144.265432469");  }
  
  hostR175 : CenterHost{ @display("p=112.102782468,33.4018362762");  }
  
  hostR176 : CenterHost{ @display("p=126.269772548,0.000294202666773");  }
  
  hostR177 : CenterHost{ @display("p=143.087118433,142.64764584");  }
  
  hostR178 : CenterHost{ @display("p=32.0857800981,38.3389066513");  }
  
  hostR179 : CenterHost{ @display("p=11.0100605518,152.325670819");  }
  
  hostR180 : CenterHost{ @display("p=83.3313432617,31.5057322566");  }
  
  hostR181 : CenterHost{ @display("p=113.321073539,62.7709236498");  }
  
  hostR182 : CenterHost{ @display("p=12.5399761606,41.6554740695");  }
  
  hostR183 : CenterHost{ @display("p=81.9205093899,9.26725083358");  }
  
  hostR184 : CenterHost{ @display("p=128.60573164,85.306885168");  }
  
  hostR185 : CenterHost{ @display("p=57.6858309161,17.6693386564");  }
  
  hostR186 : CenterHost{ @display("p=130.170551766,110.07610541");  }
  
  hostR187 : CenterHost{ @display("p=98.6585825666,121.263735032");  }
  
  hostR188 : CenterHost{ @display("p=40.3065835727,33.8715299402");  }
  
  hostR189 : CenterHost{ @display("p=106.033030642,60.4581021679");  }
  
  hostR190 : CenterHost{ @display("p=101.030270279,64.1245587613");  }
  
  hostR191 : CenterHost{ @display("p=37.0109732783,113.874597137");  }
  
  hostR192 : CenterHost{ @display("p=86.2151012708,89.5509323723");  }
  
  hostR193 : CenterHost{ @display("p=106.140749412,130.100568895");  }
  
  hostR194 : CenterHost{ @display("p=111.619239408,94.3341986586");  }
  
  hostR195 : CenterHost{ @display("p=93.205561477,140.582368261");  }
  
  hostR196 : CenterHost{ @display("p=129.36348837,54.0478758032");  }
  
  hostR197 : CenterHost{ @display("p=108.878534978,151.054989928");  }
  
  hostR198 : CenterHost{ @display("p=74.5687000172,63.6856933942");  }
  
  hostR199 : CenterHost{ @display("p=35.4476195236,115.714057905");  }
  
}