/*
 * BroadcastMsgBasedMonitor.cc
 *
 *  Created on: Jul 3, 2017
 *      Author: raziel
 */

#include "IMonitoringMechanism.h"

#include "broadcasting/BroadcastingAppBase_m.h"

#include "inet/transportlayer/contract/udp/UDPControlInfo.h"

#include <map>
#include <vector>
#include <string>
#include <iostream>

namespace inet {

class BroadcastMsgBasedMonitor: public IMonitoringMechanism {

private:
	int latestApprox = 0;
	std::set<std::string> knownNeighbors;
	std::shared_ptr<IBroadcastGateway> gateway = nullptr;

public:

	void compute_density_approx() override {
		int currentApprox = knownNeighbors.size();
		if ( currentApprox != 0 && latestApprox != currentApprox )
			latestApprox = currentApprox;
		knownNeighbors.clear();
	}

	int get_density_approx() override {
		return latestApprox;
	}

	double mobility_estimation() override {
		return 0.0;
	}

	bool handle_messages(cMessage* m) override {
		auto pkt = PK(m);
		auto isCtrlMsg = dynamic_cast<const inet::broadcasting::Hello*>(pkt);
//		auto isBroaMsg = dynamic_cast<const inet::broadcasting::Broadcast*>(pkt);
//		if (isBroaMsg && isBroaMsg->getSender() != gateway->get_name()) {
//			knownNeighbors.insert(isBroaMsg->getSender());
		if (isCtrlMsg && isCtrlMsg->getSender() != gateway->get_name())
			knownNeighbors.insert(isCtrlMsg->getSender());
		return true;
	}

	void initialise(std::shared_ptr<IBroadcastGateway> gateway) override {
//		std::cout << simTime().str() << " " << gateway->get_name() <<
//						"INIT() " << endl;
		this->gateway = gateway;
	}
};

Register_Class(BroadcastMsgBasedMonitor);

}
