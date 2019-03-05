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

package emergent_overlays.utils;
import inet.applications.udpapp.UDPBasicApp;

simple DensityCoefficients extends UDPBasicApp
{
    @class(DensityCoefficients);

    localPort = default(11);
    destPort = default(11);
    destAddresses = default("255.255.255.255");
    receiveBroadcast = default(true);
    
    int maxNodesNo  = default(10);
    double minFixedDelay @unit(s) = default(0.005s);
    double sentMsgFixedDelay @unit(s) = default(0.001s);

    @signal[clusteringCoef](type=double);
    @signal[closureCoef](type=double);
    @signal[positionAtX](type=double);
    @signal[positionAtY](type=double);

    @statistic[clusteringCoef](source=clusteringCoef; record=vector; interpolationmode=none);
    @statistic[closureCoef](source=closureCoef; record=vector; interpolationmode=none);
    @statistic[positionAtX](source=positionAtX; record=vector; interpolationmode=none);
    @statistic[positionAtY](source=positionAtY; record=vector; interpolationmode=none);
}

