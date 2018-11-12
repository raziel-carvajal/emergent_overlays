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

package emergent_overlays.common;
import inet.applications.udpapp.UDPBasicApp;

simple InteroperableBroadcast extends UDPBasicApp
{
    @class(InteroperableBroadcast);

    bool isSource = default(false);
    bool withCtrlMsg = default(false);

    double ctrlMsgInterval @unit(s) = uniform(9.901s, 10.0s);
    double monitorDelay @unit(s) = default(0.0001s);
    double borderDetectorDelay @unit(s) = uniform(0.001s, 0.099s);
    int hopsToLive = default(2);

    @signal[rcvdBroadcastMsg](type=int);
    @statistic[rcvdBroadcastMsg](source=rcvdBroadcastMsg; record=vector; interpolationmode=none);

    @signal[sentBroadcastMsg](type=int);
    @statistic[sentBroadcastMsg](source=sentBroadcastMsg; record=vector; interpolationmode=none);

    @signal[positionAtX](type=double);
    @statistic[positionAtX](source=positionAtX; record=vector; interpolationmode=none);

    @signal[positionAtY](type=double);
    @statistic[positionAtY](source=positionAtY; record=vector; interpolationmode=none);

    @signal[forward_type](type=int);
    @statistic[forward_type](source=forward_type; record=vector; interpolationmode=none);
//    
//    @signal[density_approximation](type=double);
//    @statistic[density_approximation](source=density_approximation; record=vector; interpolationmode=none);

    // set values of UDPBasicApp
    localPort = default(10);
    destPort = default(10);
    destAddresses = default("255.255.255.255");
    receiveBroadcast = default(true);

}

