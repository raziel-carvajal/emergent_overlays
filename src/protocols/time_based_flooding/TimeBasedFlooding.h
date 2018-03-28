/*
 * TimeBasedFlooding.h
 *
 *  Created on: Sep 28, 2017
 *      Author: raziel
 */

#ifndef TIMEBASEDFLOODING_H_
#define TIMEBASEDFLOODING_H_

#include "broadcasting/BroadcastingAppBase.h"
#include "broadcasting/BroadcastingAppBase_m.h"
#include "broadcasting/IBroadcastProtocol.h"

namespace inet {
class INET_API TimeBasedFlooding: public BroadcastProtocolAdapter {
private:
	double max_waiting_time;
	int max_msg_rcv;
	std::map<std::string, cMessage*> timers;
	std::set<std::string> sentMsgs;
	std::map<std::string, int> rcvMsgNo;

	void process_payload(const broadcasting::Broadcast* m) override;
	void time_to_broadcast_payload(void* user_data) override;
	void initialize(const std::string& node_name, const std::shared_ptr<IBroadcastGateway> gateway) override;
};
}

#endif /* TIMEBASEDFLOODING_H_ */
