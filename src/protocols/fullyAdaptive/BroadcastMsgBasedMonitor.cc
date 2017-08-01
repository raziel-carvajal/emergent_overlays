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
    int lastDensityApprox = 0;
    std::map<std::string, int> knownNeighbors;
    std::shared_ptr<IBroadcastGateway> gateway = nullptr;

public:

  void compute_density_approx() override {
      if (knownNeighbors.size() != lastDensityApprox && knownNeighbors.size() != 0) {
          lastDensityApprox = knownNeighbors.size();
      }
      knownNeighbors.clear();
  }

  int get_density_approx() override { return lastDensityApprox; }

  double mobility_estimation() override {
    return 0.0;
  }

  bool handle_messages(cMessage* m) override {
    auto pkt = PK(m);
    auto br = dynamic_cast<const inet::broadcasting::Broadcast*>(pkt);
    if (!br || !br->getSender() || br->getSender() == gateway->get_name()) return false;
    std::string sender(br->getSender());
//    std::cout << simTime().str() << " " + gateway->get_name() << " :: " << "SenderId [" << sender << "]" << endl;
    if(knownNeighbors.find(sender) == knownNeighbors.end())
        knownNeighbors[sender] = 0;
    else
        knownNeighbors[sender]++;
    return true;
  }

  void initialise(std::shared_ptr<IBroadcastGateway> gateway) override {
      this->gateway = gateway;
  }
};

Register_Class(BroadcastMsgBasedMonitor);

}
