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
	if (!already_rcvd) {
		rcvMsgNo[key] = 1;
		double t = uniform(0.001, gateway->get_delta());
//		cout << simTime().str() << " " << myself << " scheduling broadcast after ["
//				<< t << "] seconds for key: " << key << endl;
		timers[key] = gateway->delayed_broadcast(key, t);
	} else {
		rcvMsgNo[key]++;
//		cout << simTime().str() << " " << myself << " counter of key [" << key
//				<< "] is: " << rcvMsgNo[key] << endl;
		bool not_sent = sentMsgs.find(key) == sentMsgs.end();
		if (not_sent && rcvMsgNo[key] >= max_msg_rcv) {
//			cout << simTime().str() << " " << myself << " cancel timer of key ["
//					<< key << endl;
			gateway->cancel_message(timers[key]);
			timers.erase(key);
		}
	}

}

void inet::TimeBasedFlooding::time_to_broadcast_payload(void* user_data) {
	string key;
	//node is the source of a broadcast session
	if (!user_data) {
		key = gateway->createUniqueBroadcastingSessionId();
		rcvMsgNo[key] = 1;
	} else
		key = string((char*) user_data);
	gateway->broadcast(key, new broadcasting::Broadcast("payload"));
	sentMsgs.insert(key);
}

void inet::TimeBasedFlooding::initialize(const std::string& node_name,
		const std::shared_ptr<IBroadcastGateway> gateway) {
	BroadcastProtocolAdapter::initialize(node_name, gateway);
	// INFO: this value is read from the configuration file [config.xml]
	max_waiting_time = gateway->get_parameter<double>(protocol_name,
			"max_waiting_time");
	max_msg_rcv = gateway->get_parameter<double>(protocol_name, "max_msg_rcv");
}
