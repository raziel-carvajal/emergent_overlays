import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.node.inet.INetworkNode;
import inet.physicallayer.contract.packetlevel.IRadioMedium;
import inet.node.inet.CenterHost;
network sparse70peers150txRange
{
@display("bgb=2000,2000");
string mediumType = default("IdealRadioMedium");
submodules:
configurator: IPv4NetworkConfigurator { @display("p=0,0"); }
radioMedium: <mediumType> like IRadioMedium { @display("p=0,0"); }
hostR1:CenterHost { @display("p=1292.11, 1794.73"); }
hostR2:CenterHost { @display("p=13.55, 1028.49"); }
hostR3:CenterHost { @display("p=365.56, 269.49"); }
hostR4:CenterHost { @display("p=168.35, 1007.33"); }
hostR5:CenterHost { @display("p=1803.31, 337.15"); }
hostR6:CenterHost { @display("p=873.26, 1009.54"); }
hostR7:CenterHost { @display("p=1320.21, 1670.51"); }
hostR8:CenterHost { @display("p=670.71, 1356.99"); }
hostR9:CenterHost { @display("p=1378.84, 1956.50"); }
hostR10:CenterHost { @display("p=398.24, 1561.49"); }
hostR11:CenterHost { @display("p=598.41, 469.65"); }
hostR12:CenterHost { @display("p=613.42, 1465.42"); }
hostR13:CenterHost { @display("p=1831.93, 1280.91"); }
hostR14:CenterHost { @display("p=255.23, 394.57"); }
hostR15:CenterHost { @display("p=932.50, 817.33"); }
hostR16:CenterHost { @display("p=217.87, 1074.79"); }
hostR17:CenterHost { @display("p=807.13, 1286.07"); }
hostR18:CenterHost { @display("p=499.70, 960.71"); }
hostR19:CenterHost { @display("p=1316.38, 1248.25"); }
hostR20:CenterHost { @display("p=1860.64, 1358.08"); }
hostR21:CenterHost { @display("p=1419.74, 1650.18"); }
hostR22:CenterHost { @display("p=976.45, 540.18"); }
hostR23:CenterHost { @display("p=367.74, 280.23"); }
hostR24:CenterHost { @display("p=717.14, 1858.02"); }
hostR25:CenterHost { @display("p=1621.79, 1342.39"); }
hostR26:CenterHost { @display("p=1151.93, 269.57"); }
hostR27:CenterHost { @display("p=1749.12, 1227.11"); }
hostR28:CenterHost { @display("p=982.70, 462.10"); }
hostR29:CenterHost { @display("p=1563.19, 1118.23"); }
hostR30:CenterHost { @display("p=1481.55, 1777.24"); }
hostR31:CenterHost { @display("p=1256.95, 147.35"); }
hostR32:CenterHost { @display("p=852.34, 523.54"); }
hostR33:CenterHost { @display("p=1687.60, 322.80"); }
hostR34:CenterHost { @display("p=239.37, 1117.15"); }
hostR35:CenterHost { @display("p=977.46, 531.54"); }
hostR36:CenterHost { @display("p=396.61, 1115.91"); }
hostR37:CenterHost { @display("p=1542.70, 1754.12"); }
hostR38:CenterHost { @display("p=1777.99, 714.10"); }
hostR39:CenterHost { @display("p=1114.93, 1234.92"); }
hostR40:CenterHost { @display("p=249.61, 1666.60"); }
hostR41:CenterHost { @display("p=343.32, 796.51"); }
hostR42:CenterHost { @display("p=362.26, 1032.56"); }
hostR43:CenterHost { @display("p=1331.08, 1154.45"); }
hostR44:CenterHost { @display("p=998.62, 194.71"); }
hostR45:CenterHost { @display("p=677.15, 763.59"); }
hostR46:CenterHost { @display("p=569.29, 1305.53"); }
hostR47:CenterHost { @display("p=1344.49, 1374.71"); }
hostR48:CenterHost { @display("p=1154.10, 1412.81"); }
hostR49:CenterHost { @display("p=1284.55, 918.34"); }
hostR50:CenterHost { @display("p=1280.91, 1867.39"); }
hostR51:CenterHost { @display("p=1246.65, 76.60"); }
hostR52:CenterHost { @display("p=656.15, 1091.96"); }
hostR53:CenterHost { @display("p=1261.57, 1696.35"); }
hostR54:CenterHost { @display("p=345.05, 1228.94"); }
hostR55:CenterHost { @display("p=1960.97, 1879.00"); }
hostR56:CenterHost { @display("p=36.24, 1262.09"); }
hostR57:CenterHost { @display("p=1979.51, 584.72"); }
hostR58:CenterHost { @display("p=678.11, 751.79"); }
hostR59:CenterHost { @display("p=1409.28, 956.11"); }
hostR60:CenterHost { @display("p=1032.08, 1659.78"); }
hostR61:CenterHost { @display("p=1706.52, 1842.59"); }
hostR62:CenterHost { @display("p=1972.53, 820.53"); }
hostR63:CenterHost { @display("p=1866.87, 1868.91"); }
hostR64:CenterHost { @display("p=1975.72, 1001.34"); }
hostR65:CenterHost { @display("p=176.12, 1254.51"); }
hostR66:CenterHost { @display("p=1614.24, 1254.54"); }
hostR67:CenterHost { @display("p=1154.04, 1773.08"); }
hostR68:CenterHost { @display("p=326.07, 219.26"); }
hostR69:CenterHost { @display("p=1993.42, 1550.31"); }
hostR70:CenterHost { @display("p=452.72, 652.64"); }
hostR71:CenterHost { @display("p=1000.00, 1000.00"); isCenter=true; }
}