package builtTopologies;

import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import broadcasting.CenterHost;

network n_200_d_15_tr_20_a_129x129_idx_2_p_.ned {
  @display("bgb=129, 129");

  string mediumType = default("IdealRadioMedium");
  submodules:
  configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
  radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
  
  hostR0 : CenterHost{ @display("p=35.3860888103,85.5083257392");  }
  
  hostR1 : CenterHost{ @display("p=124.585587787,86.0447951134");  }
  
  hostR2 : CenterHost{ @display("p=78.3658270517,44.1328823447");  }
  
  hostR3 : CenterHost{ @display("p=73.2686608245,63.1738247862");  }
  
  hostR4 : CenterHost{ @display("p=69.3770873538,83.3016088174");  }
  
  hostR5 : CenterHost{ @display("p=8.73245552791,44.6083373663");  }
  
  hostR6 : CenterHost{ @display("p=115.94138597,85.993328053");  }
  
  hostR7 : CenterHost{ @display("p=35.7046312324,62.7028586735");  }
  
  hostR8 : CenterHost{ @display("p=56.9821250307,112.491990833");  }
  
  hostR9 : CenterHost{ @display("p=126.894587036,118.341590098");  }
  
  hostR10 : CenterHost{ @display("p=104.483428644,98.0100744679");  }
  
  hostR11 : CenterHost{ @display("p=11.9343864996,97.1721031096");  }
  
  hostR12 : CenterHost{ @display("p=5.99715027741,63.0821431682");  }
  
  hostR13 : CenterHost{ @display("p=101.502803799,63.7434196544");  }
  
  hostR14 : CenterHost{ @display("p=51.6597620557,109.813587585");  }
  
  hostR15 : CenterHost{ @display("p=61.5469027313,113.282598213");  }
  
  hostR16 : CenterHost{ @display("p=97.3318745226,106.689691811");  }
  
  hostR17 : CenterHost{ @display("p=115.058461397,24.9985205634");  }
  
  hostR18 : CenterHost{ @display("p=82.8940069343,79.0888007232");  }
  
  hostR19 : CenterHost{ @display("p=122.391324585,120.104799134");  }
  
  hostR20 : CenterHost{ @display("p=41.5254333915,76.3586698671");  }
  
  hostR21 : CenterHost{ @display("p=6.4366476834,0.385470100083");  }
  
  hostR22 : CenterHost{ @display("p=12.8042046669,100.043050311");  }
  
  hostR23 : CenterHost{ @display("p=23.9701819509,25.5578131073"); isCenter=true; }
  
  hostR24 : CenterHost{ @display("p=101.542748007,40.0084651364");  }
  
  hostR25 : CenterHost{ @display("p=128.617978564,27.7972920899");  }
  
  hostR26 : CenterHost{ @display("p=39.7895208382,64.3883874959");  }
  
  hostR27 : CenterHost{ @display("p=105.204136671,43.403191526");  }
  
  hostR28 : CenterHost{ @display("p=52.6791234005,126.011216862");  }
  
  hostR29 : CenterHost{ @display("p=77.5498489078,37.337917037");  }
  
  hostR30 : CenterHost{ @display("p=34.8701264585,34.1347781242");  }
  
  hostR31 : CenterHost{ @display("p=14.2638002354,27.3717874418");  }
  
  hostR32 : CenterHost{ @display("p=127.892209676,74.8162785475");  }
  
  hostR33 : CenterHost{ @display("p=60.0568611411,26.9369122865");  }
  
  hostR34 : CenterHost{ @display("p=41.8224316479,56.7854496616");  }
  
  hostR35 : CenterHost{ @display("p=121.217410796,97.0863207732");  }
  
  hostR36 : CenterHost{ @display("p=72.7265705926,126.513699639");  }
  
  hostR37 : CenterHost{ @display("p=98.5362183533,108.003815638");  }
  
  hostR38 : CenterHost{ @display("p=40.036099377,28.4724803559");  }
  
  hostR39 : CenterHost{ @display("p=74.0563581526,7.53307338169");  }
  
  hostR40 : CenterHost{ @display("p=104.036421039,61.970465707");  }
  
  hostR41 : CenterHost{ @display("p=123.689559305,100.674125159");  }
  
  hostR42 : CenterHost{ @display("p=52.361057241,122.302340229");  }
  
  hostR43 : CenterHost{ @display("p=1.25096941665,107.084033793");  }
  
  hostR44 : CenterHost{ @display("p=82.6062361589,112.381903703");  }
  
  hostR45 : CenterHost{ @display("p=97.2733600096,18.8079330066");  }
  
  hostR46 : CenterHost{ @display("p=68.7375480877,3.1785958095");  }
  
  hostR47 : CenterHost{ @display("p=10.4181536424,75.4504487087");  }
  
  hostR48 : CenterHost{ @display("p=105.602385677,9.21752695921");  }
  
  hostR49 : CenterHost{ @display("p=53.7750748851,72.6636036348");  }
  
  hostR50 : CenterHost{ @display("p=4.62348210211,35.0855648654");  }
  
  hostR51 : CenterHost{ @display("p=32.4496374156,124.15234628");  }
  
  hostR52 : CenterHost{ @display("p=2.15191663557,89.4697418932");  }
  
  hostR53 : CenterHost{ @display("p=92.1522658913,64.0297329373");  }
  
  hostR54 : CenterHost{ @display("p=65.1912614066,40.5674533708");  }
  
  hostR55 : CenterHost{ @display("p=13.3573045617,23.2450250042");  }
  
  hostR56 : CenterHost{ @display("p=52.7175859579,38.0203369959");  }
  
  hostR57 : CenterHost{ @display("p=98.4238490772,0.638101383114");  }
  
  hostR58 : CenterHost{ @display("p=62.3583421473,84.1659779836");  }
  
  hostR59 : CenterHost{ @display("p=56.3811445519,122.833761566");  }
  
  hostR60 : CenterHost{ @display("p=26.6519968662,125.74081936");  }
  
  hostR61 : CenterHost{ @display("p=30.2814548227,67.3731405522");  }
  
  hostR62 : CenterHost{ @display("p=95.0099994454,117.981451503");  }
  
  hostR63 : CenterHost{ @display("p=116.379315399,67.1943022562");  }
  
  hostR64 : CenterHost{ @display("p=26.5482066166,4.78629743021");  }
  
  hostR65 : CenterHost{ @display("p=120.706115895,56.3674339359");  }
  
  hostR66 : CenterHost{ @display("p=5.96604120859,31.377241551");  }
  
  hostR67 : CenterHost{ @display("p=121.800784812,17.735503092");  }
  
  hostR68 : CenterHost{ @display("p=64.8907406941,58.6121372013");  }
  
  hostR69 : CenterHost{ @display("p=69.6579052759,92.1107207074");  }
  
  hostR70 : CenterHost{ @display("p=122.980466586,112.205267802");  }
  
  hostR71 : CenterHost{ @display("p=103.053756929,91.5833612484");  }
  
  hostR72 : CenterHost{ @display("p=67.4353733331,34.0604748055");  }
  
  hostR73 : CenterHost{ @display("p=75.1745273432,66.4211055689");  }
  
  hostR74 : CenterHost{ @display("p=12.2306305104,52.3658295746");  }
  
  hostR75 : CenterHost{ @display("p=6.84846289559,113.90927989");  }
  
  hostR76 : CenterHost{ @display("p=100.499425124,77.7456161214");  }
  
  hostR77 : CenterHost{ @display("p=85.8535116296,18.2877904215");  }
  
  hostR78 : CenterHost{ @display("p=44.8963341233,40.3374664159");  }
  
  hostR79 : CenterHost{ @display("p=33.0981751624,40.2250741331");  }
  
  hostR80 : CenterHost{ @display("p=122.651577131,75.6309573513");  }
  
  hostR81 : CenterHost{ @display("p=122.561571029,93.4247471438");  }
  
  hostR82 : CenterHost{ @display("p=22.3821236552,111.523570272");  }
  
  hostR83 : CenterHost{ @display("p=118.262881931,74.0368663326");  }
  
  hostR84 : CenterHost{ @display("p=67.3374099372,70.949817301");  }
  
  hostR85 : CenterHost{ @display("p=13.153130333,8.63407246702");  }
  
  hostR86 : CenterHost{ @display("p=74.6799801144,57.0866170623");  }
  
  hostR87 : CenterHost{ @display("p=75.9741694162,60.3840722405");  }
  
  hostR88 : CenterHost{ @display("p=90.2644612384,72.78391803");  }
  
  hostR89 : CenterHost{ @display("p=74.5920954655,120.413220602");  }
  
  hostR90 : CenterHost{ @display("p=114.101162733,10.4507199004");  }
  
  hostR91 : CenterHost{ @display("p=77.5070670143,80.5279876785");  }
  
  hostR92 : CenterHost{ @display("p=99.7375508786,113.86638129");  }
  
  hostR93 : CenterHost{ @display("p=104.614086106,112.4727168");  }
  
  hostR94 : CenterHost{ @display("p=22.0095081908,72.3874561681");  }
  
  hostR95 : CenterHost{ @display("p=111.19060615,90.8652612441");  }
  
  hostR96 : CenterHost{ @display("p=95.9237066263,112.145386897");  }
  
  hostR97 : CenterHost{ @display("p=92.2498995671,27.5106907181");  }
  
  hostR98 : CenterHost{ @display("p=109.627818675,41.3163968737");  }
  
  hostR99 : CenterHost{ @display("p=83.2228090967,30.2572798933");  }
  
  hostR100 : CenterHost{ @display("p=109.170079676,117.373026115");  }
  
  hostR101 : CenterHost{ @display("p=120.341804957,11.9460157907");  }
  
  hostR102 : CenterHost{ @display("p=74.3757165577,74.6666748168");  }
  
  hostR103 : CenterHost{ @display("p=54.3643782452,55.2032707243");  }
  
  hostR104 : CenterHost{ @display("p=81.2478952511,90.9613677332");  }
  
  hostR105 : CenterHost{ @display("p=35.2451963264,57.9349350045");  }
  
  hostR106 : CenterHost{ @display("p=29.5733277843,97.2726824796");  }
  
  hostR107 : CenterHost{ @display("p=84.0818874792,3.98956099535");  }
  
  hostR108 : CenterHost{ @display("p=65.8600116719,55.3639041204");  }
  
  hostR109 : CenterHost{ @display("p=6.61350322804,94.2262827986");  }
  
  hostR110 : CenterHost{ @display("p=59.0219928725,107.393115746");  }
  
  hostR111 : CenterHost{ @display("p=68.21472881,88.149330091");  }
  
  hostR112 : CenterHost{ @display("p=27.1930526598,33.9063995609");  }
  
  hostR113 : CenterHost{ @display("p=77.4322865156,56.1547911208");  }
  
  hostR114 : CenterHost{ @display("p=42.2223811809,87.9166336073");  }
  
  hostR115 : CenterHost{ @display("p=86.8438256843,63.9192837691");  }
  
  hostR116 : CenterHost{ @display("p=108.660000644,68.6204889279");  }
  
  hostR117 : CenterHost{ @display("p=108.803290508,122.934804578");  }
  
  hostR118 : CenterHost{ @display("p=35.2535499508,95.0453453162");  }
  
  hostR119 : CenterHost{ @display("p=34.8220021289,2.30137693886");  }
  
  hostR120 : CenterHost{ @display("p=68.2763979905,32.7408897147");  }
  
  hostR121 : CenterHost{ @display("p=103.735222806,57.371729326");  }
  
  hostR122 : CenterHost{ @display("p=97.5858040603,53.3401465648");  }
  
  hostR123 : CenterHost{ @display("p=75.4236078216,5.44721575409");  }
  
  hostR124 : CenterHost{ @display("p=70.7723419639,100.993789457");  }
  
  hostR125 : CenterHost{ @display("p=70.4455768725,58.1408065018");  }
  
  hostR126 : CenterHost{ @display("p=87.9014493267,46.5225275257");  }
  
  hostR127 : CenterHost{ @display("p=29.2836346813,42.4814762268");  }
  
  hostR128 : CenterHost{ @display("p=67.1408636188,48.3866290747");  }
  
  hostR129 : CenterHost{ @display("p=113.582410311,72.6156635523");  }
  
  hostR130 : CenterHost{ @display("p=93.5398215539,55.0299140082");  }
  
  hostR131 : CenterHost{ @display("p=19.4096419405,70.652422657");  }
  
  hostR132 : CenterHost{ @display("p=111.994672475,1.26816161611");  }
  
  hostR133 : CenterHost{ @display("p=33.8384970253,8.90144352585");  }
  
  hostR134 : CenterHost{ @display("p=118.051320005,108.48992528");  }
  
  hostR135 : CenterHost{ @display("p=17.1736087838,114.795584031");  }
  
  hostR136 : CenterHost{ @display("p=83.3099433706,92.0368651935");  }
  
  hostR137 : CenterHost{ @display("p=82.9095878038,34.8085349838");  }
  
  hostR138 : CenterHost{ @display("p=13.9846527612,65.9603263192");  }
  
  hostR139 : CenterHost{ @display("p=13.6882387726,98.664422679");  }
  
  hostR140 : CenterHost{ @display("p=86.3428818575,48.458051828");  }
  
  hostR141 : CenterHost{ @display("p=94.3215962332,7.24717267449");  }
  
  hostR142 : CenterHost{ @display("p=50.3231480006,81.8897499064");  }
  
  hostR143 : CenterHost{ @display("p=101.061133933,61.5921284842");  }
  
  hostR144 : CenterHost{ @display("p=117.667242823,27.6303744221");  }
  
  hostR145 : CenterHost{ @display("p=64.8592586394,19.0539210617");  }
  
  hostR146 : CenterHost{ @display("p=74.3651026958,90.407339421");  }
  
  hostR147 : CenterHost{ @display("p=72.3444755884,72.7303520257");  }
  
  hostR148 : CenterHost{ @display("p=103.495003974,90.4495581303");  }
  
  hostR149 : CenterHost{ @display("p=24.2941364499,66.1974584123");  }
  
  hostR150 : CenterHost{ @display("p=69.5035488628,42.0530872792");  }
  
  hostR151 : CenterHost{ @display("p=128.92144437,44.7440174911");  }
  
  hostR152 : CenterHost{ @display("p=95.6418927487,77.2249149777");  }
  
  hostR153 : CenterHost{ @display("p=107.903625811,80.6821448051");  }
  
  hostR154 : CenterHost{ @display("p=64.2135176628,117.629315561");  }
  
  hostR155 : CenterHost{ @display("p=78.7606671518,39.5196105482");  }
  
  hostR156 : CenterHost{ @display("p=82.302794903,6.95013858487");  }
  
  hostR157 : CenterHost{ @display("p=87.4569449027,65.9154142753");  }
  
  hostR158 : CenterHost{ @display("p=87.1906628244,0.0123657428285");  }
  
  hostR159 : CenterHost{ @display("p=51.5442328298,102.182932089");  }
  
  hostR160 : CenterHost{ @display("p=32.438509059,90.1910560021");  }
  
  hostR161 : CenterHost{ @display("p=115.347839461,69.6533632567");  }
  
  hostR162 : CenterHost{ @display("p=64.6273769614,85.7521926689");  }
  
  hostR163 : CenterHost{ @display("p=93.3520563087,59.5315426212");  }
  
  hostR164 : CenterHost{ @display("p=41.6490237759,126.509241519");  }
  
  hostR165 : CenterHost{ @display("p=29.8648415043,90.7532370054");  }
  
  hostR166 : CenterHost{ @display("p=102.596169246,39.4692044214");  }
  
  hostR167 : CenterHost{ @display("p=119.120107664,117.737286526");  }
  
  hostR168 : CenterHost{ @display("p=68.1758277873,88.5184107863");  }
  
  hostR169 : CenterHost{ @display("p=106.319952395,27.3024943309");  }
  
  hostR170 : CenterHost{ @display("p=42.2955178963,15.8182397334");  }
  
  hostR171 : CenterHost{ @display("p=67.3337709534,83.9461010501");  }
  
  hostR172 : CenterHost{ @display("p=14.2087109025,95.3638372757");  }
  
  hostR173 : CenterHost{ @display("p=108.126972951,23.2709779074");  }
  
  hostR174 : CenterHost{ @display("p=67.9467255425,92.7592449473");  }
  
  hostR175 : CenterHost{ @display("p=68.0724217435,69.3429923231");  }
  
  hostR176 : CenterHost{ @display("p=70.5204902475,43.7275596132");  }
  
  hostR177 : CenterHost{ @display("p=7.16784450963,125.82065567");  }
  
  hostR178 : CenterHost{ @display("p=123.156227397,90.4759351394");  }
  
  hostR179 : CenterHost{ @display("p=95.4930254953,83.3340334032");  }
  
  hostR180 : CenterHost{ @display("p=34.7663109474,20.8573857122");  }
  
  hostR181 : CenterHost{ @display("p=1.64060086191,5.87152885118");  }
  
  hostR182 : CenterHost{ @display("p=6.8857037696,95.9855596394");  }
  
  hostR183 : CenterHost{ @display("p=117.843221983,122.533289694");  }
  
  hostR184 : CenterHost{ @display("p=19.0599168741,23.2793216711");  }
  
  hostR185 : CenterHost{ @display("p=19.5839229374,91.4981377506");  }
  
  hostR186 : CenterHost{ @display("p=82.658464191,127.312405339");  }
  
  hostR187 : CenterHost{ @display("p=17.3521262565,55.8980940722");  }
  
  hostR188 : CenterHost{ @display("p=23.1214127704,75.3207787877");  }
  
  hostR189 : CenterHost{ @display("p=121.623795191,102.359337655");  }
  
  hostR190 : CenterHost{ @display("p=18.9853143086,54.1472402139");  }
  
  hostR191 : CenterHost{ @display("p=96.0765034753,83.3179982819");  }
  
  hostR192 : CenterHost{ @display("p=59.983093179,83.8559496566");  }
  
  hostR193 : CenterHost{ @display("p=108.278398384,27.3690345173");  }
  
  hostR194 : CenterHost{ @display("p=39.990550667,84.174768343");  }
  
  hostR195 : CenterHost{ @display("p=53.529618299,27.2771596534");  }
  
  hostR196 : CenterHost{ @display("p=69.6691147369,83.3258910908");  }
  
  hostR197 : CenterHost{ @display("p=79.861426032,12.3511979602");  }
  
  hostR198 : CenterHost{ @display("p=92.8086964059,7.51472428494");  }
  
  hostR199 : CenterHost{ @display("p=89.5600957711,103.44103395");  }
  
}