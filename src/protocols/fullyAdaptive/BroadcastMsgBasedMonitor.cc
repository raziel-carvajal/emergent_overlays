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
  std::shared_ptr<IBroadcastGateway> gateway = nullptr;
  std::map<std::string, int> knownBroadcast;

public:
  int density_estimation() override {
    return -1;
  }

  double mobility_estimation() override {
    return 0.0;
  }

  bool handle_messages(cMessage* m) override {
    if (!gateway) return false;
    return true;
  }

  void initialise(std::shared_ptr<IBroadcastGateway> gateway) override {
      this->gateway = gateway;
//      update_message = this->gateway->register_new_control_message();
//      this->gateway->delayed_event(update_message, "update in sniffer based monitor", 1.0);
  }
};

Register_Class(BroadcastMsgBasedMonitor);

}
