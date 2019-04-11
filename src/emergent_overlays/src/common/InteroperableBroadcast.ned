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
    // set values of UDPBasicApp
    localPort = default(10);
    destPort = default(10);
    destAddresses = default("255.255.255.255");
    receiveBroadcast = default(true);
    messageLength = default(200B);
    sendInterval = this.broadcastInterval;

    bool isSourceNode = default(false);
    bool withDebugging = default(false);
    bool withMac = default(false);

	// WARNING this value cannot be lower than 100 (min timer to schedule events)
    int nodesNo = default(100);
    double minSentDelay @unit(s) = default(0.00001s);
    double broadcastInterval @unit(s) = default(1s);

    double ctrlMsgInterval @unit(s) = this.broadcastInterval;
    double startSendingCtrlMsgs @unit(s) = this.broadcastInterval - 2 * this.nodesNo * this.minSentDelay + this.minSentDelay;
    
    double macWaitingTimeFactor = default(100);
    double macLowerWaitingTime @unit(s) = this.minSentDelay;
//    double macUpperWaitingTime @unit(s) = this.minSentDelay * 90;
    double macUpperWaitingTime @unit(s) = this.minSentDelay * this.macWaitingTimeFactor;   
    //
    // specify running protocol identifier (see enum InteroperableBroadcast.Protocols)
    int runningProtocolId;
    int maxRetriesAtMac = default(2);

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
    
    @signal[sentDataFrames](type=int);
    @statistic[sentDataFrames](source=sentDataFrames; record=vector; interpolationmode=none);
    @signal[recvDataFrames](type=int);
    @statistic[recvDataFrames](source=recvDataFrames; record=vector; interpolationmode=none);
    
    @signal[sentCtrlFrames](type=int);
    @statistic[sentCtrlFrames](source=sentCtrlFrames; record=vector; interpolationmode=none);
    @signal[recvCtrlFrames](type=int);
    @statistic[recvCtrlFrames](source=recvCtrlFrames; record=vector; interpolationmode=none);
//    
//    @signal[density_approximation](type=double);
//    @statistic[density_approximation](source=density_approximation; record=vector; interpolationmode=none);

    

}

