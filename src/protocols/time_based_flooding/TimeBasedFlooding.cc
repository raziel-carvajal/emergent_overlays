/*
 * TimeBasedFlooding.cc
 *
 *  Created on: Sep 28, 2017
 *      Author: raziel
 */

#include "TimeBasedFlooding.h"

using namespace std;
using inet::broadcasting::Broadcast;

Register_Class(inet::TimeBasedFlooding);

void inet::TimeBasedFlooding::process_payload(
		const broadcasting::Broadcast* m) {
	string key = string(m->getId());
	gateway->emitBroadcastMsgReceived(key);
	if (myself == m->getSender())
		return;

	bool already_rcvd = rcvMsgNo.find(key) != rcvMsgNo.end();
//	bool wasntDispatched = dispatchedMsgs.find(key) == dispatchedMsgs.end();
//	if (wasntDispatched) {
//		bool wasntReceived = timers.find(key) == timers.end();
//		double maxTimer = gateway->get_parameter<double>(protocol_name, "max_waiting_time");
//		double t = uniform(0, maxTimer);
//		timers[key] = gateway->delayed_broadcast(key, t);
//	}
//        cout << " its broadcast will be delayed " << t << " seconds" << endl;
	if (!already_rcvd) {
		rcvMsgNo[key] = 1;
		double t = uniform(0.001, max_waiting_time);
		cout << simTime().str() << " " << myself << " scheduling broadcast after ["
				<< t << "] seconds for key: " << key << endl;
		timers[key] = gateway->delayed_broadcast(key, t);
	} else {
		rcvMsgNo[key]++;
		cout << simTime().str() << " " << myself << " counter of key [" << key
				<< "] is: " << rcvMsgNo[key] << endl;
		if (rcvMsgNo[key] == max_msg_rcv && sentMsgs.find(key) == sentMsgs.end()) {
			cout << simTime().str() << " " << myself << " cancel timer of key ["
					<< key << endl;
			gateway->cancel_message(timers[key]);
//			timers.erase(key);
		}
	}

}

void inet::TimeBasedFlooding::time_to_broadcast_payload(void* user_data) {
	string key;
	if (!user_data) { //node is the source of a broadcast session
		key = gateway->createUniqueBroadcastingSessionId();
		rcvMsgNo[key] = 1;
	} else { //a msg containing user_data was delayed and now is time to forward it
		key = string((char*) user_data);
	}
	gateway->broadcast(key, new broadcasting::Broadcast("payload"));
	sentMsgs.insert(key);
}

void inet::TimeBasedFlooding::initialize(const std::string& node_name,
		const std::shared_ptr<IBroadcastGateway> gateway) {
	BroadcastProtocolAdapter::initialize(node_name, gateway);
	// INFO this value is read from the configuration file [config.xml]
	max_waiting_time = gateway->get_parameter<double>(protocol_name,
			"max_waiting_time");
	max_msg_rcv = gateway->get_parameter<double>(protocol_name, "max_msg_rcv");
}
