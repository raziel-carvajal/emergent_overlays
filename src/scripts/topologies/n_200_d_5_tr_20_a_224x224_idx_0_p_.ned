package builtTopologies;

import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import broadcasting.CenterHost;

network n_200_d_5_tr_20_a_224x224_idx_0_p_.ned {
  @display("bgb=224, 224");

  string mediumType = default("IdealRadioMedium");
  submodules:
  configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
  radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
  
  hostR0 : CenterHost{ @display("p=212.601664089,200.546309062");  }
  
  hostR1 : CenterHost{ @display("p=111.863184468,195.411519304");  }
  
  hostR2 : CenterHost{ @display("p=85.3868193283,69.4761562613");  }
  
  hostR3 : CenterHost{ @display("p=164.018143137,156.821804672");  }
  
  hostR4 : CenterHost{ @display("p=30.7401531757,182.203886142");  }
  
  hostR5 : CenterHost{ @display("p=163.582971973,14.1964836186");  }
  
  hostR6 : CenterHost{ @display("p=193.426308153,107.133173932");  }
  
  hostR7 : CenterHost{ @display("p=51.0952256019,202.679642403");  }
  
  hostR8 : CenterHost{ @display("p=110.931960681,25.9974736441");  }
  
  hostR9 : CenterHost{ @display("p=26.5202224623,96.9398743555");  }
  
  hostR10 : CenterHost{ @display("p=48.4905675487,88.6487988324");  }
  
  hostR11 : CenterHost{ @display("p=29.3761420078,59.4440275771");  }
  
  hostR12 : CenterHost{ @display("p=87.8135938965,209.094340197");  }
  
  hostR13 : CenterHost{ @display("p=45.8885788529,127.311279292");  }
  
  hostR14 : CenterHost{ @display("p=30.7629413226,124.928873859");  }
  
  hostR15 : CenterHost{ @display("p=156.164268944,121.68370871");  }
  
  hostR16 : CenterHost{ @display("p=13.0595397571,122.311852722");  }
  
  hostR17 : CenterHost{ @display("p=173.74289908,29.2656768849");  }
  
  hostR18 : CenterHost{ @display("p=15.4404081037,205.682979438");  }
  
  hostR19 : CenterHost{ @display("p=200.000973385,118.435824055");  }
  
  hostR20 : CenterHost{ @display("p=188.006415586,9.9825905344");  }
  
  hostR21 : CenterHost{ @display("p=7.62662912305,107.994875412");  }
  
  hostR22 : CenterHost{ @display("p=196.275601415,81.7143524909");  }
  
  hostR23 : CenterHost{ @display("p=167.930319446,131.224274794");  }
  
  hostR24 : CenterHost{ @display("p=83.8217785689,148.717632487");  }
  
  hostR25 : CenterHost{ @display("p=212.198984694,203.641831282");  }
  
  hostR26 : CenterHost{ @display("p=54.6310818213,95.644654088");  }
  
  hostR27 : CenterHost{ @display("p=53.2681954678,62.402185334");  }
  
  hostR28 : CenterHost{ @display("p=39.9642239601,17.2319569694");  }
  
  hostR29 : CenterHost{ @display("p=25.6766807119,121.606057475");  }
  
  hostR30 : CenterHost{ @display("p=124.665569352,101.544062792");  }
  
  hostR31 : CenterHost{ @display("p=52.853775579,109.027240237");  }
  
  hostR32 : CenterHost{ @display("p=126.149895071,12.9434772933");  }
  
  hostR33 : CenterHost{ @display("p=129.498859403,122.531377263");  }
  
  hostR34 : CenterHost{ @display("p=128.122450309,205.090052568");  }
  
  hostR35 : CenterHost{ @display("p=198.963327963,23.6078585976");  }
  
  hostR36 : CenterHost{ @display("p=73.7638629503,99.3011460206");  }
  
  hostR37 : CenterHost{ @display("p=33.456660378,51.6537318426");  }
  
  hostR38 : CenterHost{ @display("p=105.436253681,80.0424500328");  }
  
  hostR39 : CenterHost{ @display("p=196.94379664,107.123514408");  }
  
  hostR40 : CenterHost{ @display("p=6.36439846079,213.792979619");  }
  
  hostR41 : CenterHost{ @display("p=124.94509384,100.773933859");  }
  
  hostR42 : CenterHost{ @display("p=93.949318479,84.9687391055");  }
  
  hostR43 : CenterHost{ @display("p=83.2601425498,140.230465709");  }
  
  hostR44 : CenterHost{ @display("p=75.8989135456,149.279102837");  }
  
  hostR45 : CenterHost{ @display("p=209.713463681,86.6164500787");  }
  
  hostR46 : CenterHost{ @display("p=154.535123153,34.6401409041");  }
  
  hostR47 : CenterHost{ @display("p=207.529897759,84.1825067738");  }
  
  hostR48 : CenterHost{ @display("p=39.2727445437,47.2713622756");  }
  
  hostR49 : CenterHost{ @display("p=64.4652182641,69.1649326892");  }
  
  hostR50 : CenterHost{ @display("p=77.684183535,219.12495918");  }
  
  hostR51 : CenterHost{ @display("p=209.444069943,21.987232722");  }
  
  hostR52 : CenterHost{ @display("p=94.8533214142,81.2562392624");  }
  
  hostR53 : CenterHost{ @display("p=188.421172213,97.1829994284");  }
  
  hostR54 : CenterHost{ @display("p=212.979615908,121.586815482");  }
  
  hostR55 : CenterHost{ @display("p=30.1596247876,104.344227737");  }
  
  hostR56 : CenterHost{ @display("p=99.19309383,70.8576434891");  }
  
  hostR57 : CenterHost{ @display("p=138.294601585,88.279396685");  }
  
  hostR58 : CenterHost{ @display("p=126.202562236,66.4318240545");  }
  
  hostR59 : CenterHost{ @display("p=132.984956193,72.4033261307");  }
  
  hostR60 : CenterHost{ @display("p=204.669448355,190.9955847");  }
  
  hostR61 : CenterHost{ @display("p=9.31245494143,42.769418572");  }
  
  hostR62 : CenterHost{ @display("p=196.333953756,33.5418941618");  }
  
  hostR63 : CenterHost{ @display("p=6.93510994093,163.195747858");  }
  
  hostR64 : CenterHost{ @display("p=30.0661007776,59.0295695683");  }
  
  hostR65 : CenterHost{ @display("p=151.841184073,201.698864053");  }
  
  hostR66 : CenterHost{ @display("p=143.612698226,82.7500926864");  }
  
  hostR67 : CenterHost{ @display("p=209.745146941,98.1253676256");  }
  
  hostR68 : CenterHost{ @display("p=89.3522777765,135.018935255");  }
  
  hostR69 : CenterHost{ @display("p=124.507924394,104.885366669");  }
  
  hostR70 : CenterHost{ @display("p=4.55490227159,220.677595975");  }
  
  hostR71 : CenterHost{ @display("p=122.662124808,206.478216807");  }
  
  hostR72 : CenterHost{ @display("p=183.835303447,220.75253479");  }
  
  hostR73 : CenterHost{ @display("p=62.0532337118,88.5586981976");  }
  
  hostR74 : CenterHost{ @display("p=208.366999073,218.235980492");  }
  
  hostR75 : CenterHost{ @display("p=101.734956671,92.8818627792");  }
  
  hostR76 : CenterHost{ @display("p=98.8655645367,70.9797504995");  }
  
  hostR77 : CenterHost{ @display("p=185.251705226,41.1688991892");  }
  
  hostR78 : CenterHost{ @display("p=153.900797776,61.7070396836");  }
  
  hostR79 : CenterHost{ @display("p=65.8858215676,20.9977649698");  }
  
  hostR80 : CenterHost{ @display("p=192.76288714,213.076663821");  }
  
  hostR81 : CenterHost{ @display("p=26.2419375335,168.120089078");  }
  
  hostR82 : CenterHost{ @display("p=71.2122205659,182.664027038");  }
  
  hostR83 : CenterHost{ @display("p=64.8851050249,187.345902346");  }
  
  hostR84 : CenterHost{ @display("p=35.6024196245,31.5681782799");  }
  
  hostR85 : CenterHost{ @display("p=64.5577350999,207.102430785");  }
  
  hostR86 : CenterHost{ @display("p=32.0712177601,190.955653387");  }
  
  hostR87 : CenterHost{ @display("p=85.4264679577,203.400686509");  }
  
  hostR88 : CenterHost{ @display("p=98.9676778539,74.237868519");  }
  
  hostR89 : CenterHost{ @display("p=59.2639741195,139.515870345");  }
  
  hostR90 : CenterHost{ @display("p=159.30750566,143.573507461");  }
  
  hostR91 : CenterHost{ @display("p=144.062593362,96.5872347684");  }
  
  hostR92 : CenterHost{ @display("p=148.510435782,218.526864234");  }
  
  hostR93 : CenterHost{ @display("p=24.8251685481,53.646087573");  }
  
  hostR94 : CenterHost{ @display("p=18.3460947155,104.908383923");  }
  
  hostR95 : CenterHost{ @display("p=158.740645609,193.869319681");  }
  
  hostR96 : CenterHost{ @display("p=209.906351007,185.028820574");  }
  
  hostR97 : CenterHost{ @display("p=37.7834405818,161.41583202");  }
  
  hostR98 : CenterHost{ @display("p=64.2060452928,111.580963744");  }
  
  hostR99 : CenterHost{ @display("p=161.993323242,148.616615981");  }
  
  hostR100 : CenterHost{ @display("p=84.2345843094,121.849716848");  }
  
  hostR101 : CenterHost{ @display("p=100.226964532,33.9735619944");  }
  
  hostR102 : CenterHost{ @display("p=17.9120520004,223.513432114");  }
  
  hostR103 : CenterHost{ @display("p=138.293452642,149.426242732");  }
  
  hostR104 : CenterHost{ @display("p=116.744599708,209.713867921");  }
  
  hostR105 : CenterHost{ @display("p=96.1112575955,53.0639032106");  }
  
  hostR106 : CenterHost{ @display("p=0.614826061673,154.721174255");  }
  
  hostR107 : CenterHost{ @display("p=19.5826742767,172.533654731");  }
  
  hostR108 : CenterHost{ @display("p=192.210607728,68.6188753922");  }
  
  hostR109 : CenterHost{ @display("p=147.470152813,158.293974686");  }
  
  hostR110 : CenterHost{ @display("p=201.987710664,47.0464981236");  }
  
  hostR111 : CenterHost{ @display("p=21.3066979353,182.656253103");  }
  
  hostR112 : CenterHost{ @display("p=57.0500392381,210.794782892");  }
  
  hostR113 : CenterHost{ @display("p=89.1362095256,182.798756628");  }
  
  hostR114 : CenterHost{ @display("p=218.600359272,115.316307601");  }
  
  hostR115 : CenterHost{ @display("p=2.30855535162,219.166518562");  }
  
  hostR116 : CenterHost{ @display("p=55.9030041165,41.6494114193");  }
  
  hostR117 : CenterHost{ @display("p=66.587028945,104.708302979");  }
  
  hostR118 : CenterHost{ @display("p=110.598315583,205.476929717");  }
  
  hostR119 : CenterHost{ @display("p=193.891740728,62.5742918054");  }
  
  hostR120 : CenterHost{ @display("p=221.085797046,78.9659599729");  }
  
  hostR121 : CenterHost{ @display("p=192.684307802,123.180737744");  }
  
  hostR122 : CenterHost{ @display("p=168.871332156,101.170724271");  }
  
  hostR123 : CenterHost{ @display("p=143.071589629,119.216398894");  }
  
  hostR124 : CenterHost{ @display("p=64.5955578247,210.456455179");  }
  
  hostR125 : CenterHost{ @display("p=69.5654934745,103.689728259");  }
  
  hostR126 : CenterHost{ @display("p=92.6745446752,75.8675361438");  }
  
  hostR127 : CenterHost{ @display("p=96.0432086608,85.6987553426");  }
  
  hostR128 : CenterHost{ @display("p=8.53888278975,117.060714729");  }
  
  hostR129 : CenterHost{ @display("p=105.233222972,119.116196533");  }
  
  hostR130 : CenterHost{ @display("p=59.0688764136,25.4431512203");  }
  
  hostR131 : CenterHost{ @display("p=6.87617193951,198.113557078");  }
  
  hostR132 : CenterHost{ @display("p=30.4535918983,9.24346366578");  }
  
  hostR133 : CenterHost{ @display("p=24.0464312127,43.6346834458");  }
  
  hostR134 : CenterHost{ @display("p=29.7645479589,183.688893788");  }
  
  hostR135 : CenterHost{ @display("p=180.649468003,209.065613932");  }
  
  hostR136 : CenterHost{ @display("p=220.023743285,51.976507547");  }
  
  hostR137 : CenterHost{ @display("p=23.929094607,43.0695622352");  }
  
  hostR138 : CenterHost{ @display("p=163.79087813,48.9791742304");  }
  
  hostR139 : CenterHost{ @display("p=205.894570891,61.5644099033");  }
  
  hostR140 : CenterHost{ @display("p=37.7046078848,46.7870582471");  }
  
  hostR141 : CenterHost{ @display("p=130.550863201,75.1414415286");  }
  
  hostR142 : CenterHost{ @display("p=41.2996865335,175.649666357");  }
  
  hostR143 : CenterHost{ @display("p=61.829207908,211.867171248");  }
  
  hostR144 : CenterHost{ @display("p=92.0001500698,131.873321577");  }
  
  hostR145 : CenterHost{ @display("p=123.144794656,49.9447733938");  }
  
  hostR146 : CenterHost{ @display("p=88.9923165351,93.7106105986"); isCenter=true; }
  
  hostR147 : CenterHost{ @display("p=25.1356206723,129.190374524");  }
  
  hostR148 : CenterHost{ @display("p=203.743069142,201.116718441");  }
  
  hostR149 : CenterHost{ @display("p=148.51973151,167.625808382");  }
  
  hostR150 : CenterHost{ @display("p=19.7343827229,200.879802685");  }
  
  hostR151 : CenterHost{ @display("p=168.502449842,124.478538866");  }
  
  hostR152 : CenterHost{ @display("p=110.525748536,131.259617408");  }
  
  hostR153 : CenterHost{ @display("p=211.993981383,92.0777723366");  }
  
  hostR154 : CenterHost{ @display("p=174.374398236,61.7892505476");  }
  
  hostR155 : CenterHost{ @display("p=62.1113217779,222.163586529");  }
  
  hostR156 : CenterHost{ @display("p=16.2853016468,147.210670327");  }
  
  hostR157 : CenterHost{ @display("p=101.512752689,159.802659457");  }
  
  hostR158 : CenterHost{ @display("p=122.611385648,151.242143614");  }
  
  hostR159 : CenterHost{ @display("p=170.043511022,36.7059778278");  }
  
  hostR160 : CenterHost{ @display("p=133.13173379,10.4957300895");  }
  
  hostR161 : CenterHost{ @display("p=147.925593689,166.901175186");  }
  
  hostR162 : CenterHost{ @display("p=16.7491794031,179.594676279");  }
  
  hostR163 : CenterHost{ @display("p=174.825848637,41.8643326507");  }
  
  hostR164 : CenterHost{ @display("p=154.032724231,90.8881419116");  }
  
  hostR165 : CenterHost{ @display("p=45.4671946918,69.9919629391");  }
  
  hostR166 : CenterHost{ @display("p=102.18044801,15.7975711932");  }
  
  hostR167 : CenterHost{ @display("p=174.469906275,107.102615942");  }
  
  hostR168 : CenterHost{ @display("p=68.1357571172,69.8718910391");  }
  
  hostR169 : CenterHost{ @display("p=115.609628572,13.3960557117");  }
  
  hostR170 : CenterHost{ @display("p=133.585510402,194.62854272");  }
  
  hostR171 : CenterHost{ @display("p=166.267299651,204.470252589");  }
  
  hostR172 : CenterHost{ @display("p=99.3721206052,130.929031793");  }
  
  hostR173 : CenterHost{ @display("p=139.088999646,182.773261336");  }
  
  hostR174 : CenterHost{ @display("p=109.977837767,143.244647646");  }
  
  hostR175 : CenterHost{ @display("p=150.074848125,112.136849678");  }
  
  hostR176 : CenterHost{ @display("p=208.436943683,38.458255073");  }
  
  hostR177 : CenterHost{ @display("p=46.4381673234,24.0727400999");  }
  
  hostR178 : CenterHost{ @display("p=153.051405055,86.666082999");  }
  
  hostR179 : CenterHost{ @display("p=114.112624211,102.819193206");  }
  
  hostR180 : CenterHost{ @display("p=204.064586666,75.6849327367");  }
  
  hostR181 : CenterHost{ @display("p=107.598611821,141.479893049");  }
  
  hostR182 : CenterHost{ @display("p=6.5836460916,155.767658978");  }
  
  hostR183 : CenterHost{ @display("p=183.762106743,8.48681715738");  }
  
  hostR184 : CenterHost{ @display("p=178.507033345,80.8299253921");  }
  
  hostR185 : CenterHost{ @display("p=163.892310114,31.8768614893");  }
  
  hostR186 : CenterHost{ @display("p=105.317430999,206.880378304");  }
  
  hostR187 : CenterHost{ @display("p=125.087727827,218.733017555");  }
  
  hostR188 : CenterHost{ @display("p=64.0362901422,176.549535994");  }
  
  hostR189 : CenterHost{ @display("p=52.3208730466,186.266759828");  }
  
  hostR190 : CenterHost{ @display("p=144.694295948,106.069308601");  }
  
  hostR191 : CenterHost{ @display("p=212.464929547,18.0866708359");  }
  
  hostR192 : CenterHost{ @display("p=173.487803602,113.546185985");  }
  
  hostR193 : CenterHost{ @display("p=61.4414106107,178.781774098");  }
  
  hostR194 : CenterHost{ @display("p=139.685620992,125.416936998");  }
  
  hostR195 : CenterHost{ @display("p=19.0310014424,186.891682241");  }
  
  hostR196 : CenterHost{ @display("p=166.778941094,209.147228053");  }
  
  hostR197 : CenterHost{ @display("p=38.0381347789,181.098729911");  }
  
  hostR198 : CenterHost{ @display("p=130.594115203,123.750606478");  }
  
  hostR199 : CenterHost{ @display("p=132.670641153,152.073791639");  }
  
}