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
    // network layer options (from UDPBasicApp)
    localPort = default(10);
    destPort = default(10);
    destAddresses = default("255.255.255.255");
    receiveBroadcast = default(true);
    messageLength = default(200B);

    // options of our MAC layer
    int maxRetriesAtMac = default(2);
    bool withMac = default(false);
    double macWaitingTimeFactor = default(100);
    double macLowerWaitingTime @unit(s) = this.minSentDelay;
    double macUpperWaitingTime @unit(s) = this.minSentDelay * this.macWaitingTimeFactor;

    // options at application level
    bool withDebugging = default(false);
   	//		WARNING this value cannot be lower than 100 (min timer to schedule events in the simulator)
    int nodesNo = default(100);
    bool isSourceNode = default(false);
	// 		options for messages
    double minSentDelay @unit(s) = default(0.00001s);
    double broadcastInterval @unit(s) = default(1s);
    sendInterval = this.broadcastInterval;
    //		options for protocols that need control frames
    //			slot number at which a control message is sent
    int sentCtrlMsgFreq = default(1);
    double ctrlMsgInterval @unit(s) = this.broadcastInterval;
    //			time to send the first control message
    double startSendingCtrlMsgs @unit(s) = this.broadcastInterval - 2 * this.nodesNo * this.minSentDelay + this.minSentDelay;
    //		specify running protocol identifier (see enum Protocols at InteroperableBroadcast.h)
    int runningProtocolId;
    // 		options to measure observables
    double getObsInterval @unit(s) = this.broadcastInterval - 0.01s;// lag to be sure that the swiching policy use latests observables
    double startObsApprox @unit(s)= this.broadcastInterval + (this.broadcastInterval / 2);
    // 			TODO for windows bigger than 10, be sure that there is an implementation for FIX ME
	int windowSize = default(10);
  	// 			FIX ME: turn indexSequence into a string and reimplement initialize() at utils/Observable.cc
	int indexSequence = default(125);
	bool withLastMeasure = default(true);
	// 			when false, the weighted average is calculated instead
	bool withRateOfChange = default(true);

	//		options for adaptation
	bool withAdaptation = default(false);
	double applyAdapPolicy @unit(s) = 2 * this.windowSize * this.broadcastInterval + (this.broadcastInterval / 2);
	int adaptationPolicy = default(0);// single = 0, collective = 1
	double densityThreshold = default(20.0);
	double stabilityThreshold = default(1.0);

    // options for broadcast protocols
    // 		controlled flooding
    int counterCfcondition = default(3);
    //		scoped-hyper flooding
    double neigSimilarity = default(0.85);

	// statistics
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

    @signal[sentCtrlFrames](type=int);
    @statistic[sentCtrlFrames](source=sentCtrlFrames; record=vector; interpolationmode=none);

    @signal[recvCtrlFrames](type=int);
    @statistic[recvCtrlFrames](source=recvCtrlFrames; record=vector; interpolationmode=none);

    @signal[densityObs](type=double);
    @statistic[densityObs](source=densityObs; record=vector; interpolationmode=none);

    @signal[mobilityObs](type=double);
    @statistic[mobilityObs](source=mobilityObs; record=vector; interpolationmode=none);
    
    @signal[runningAlgorithm](type=int);
    @statistic[runningAlgorithm](source=runningAlgorithm; record=vector; interpolationmode=none);
}
