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
    int latestApprox;
    std::map<std::string, int> knownNeighbors;
    std::shared_ptr<IBroadcastGateway> gateway = nullptr;

public:

  void compute_density_approx() override {
      int currentApprox = knownNeighbors.size();
      if (getLatestApprox() == -1) {
          latestApprox = currentApprox;
          appendApprox(currentApprox);
      } else {
          if (appendApprox(currentApprox)) {
              latestApprox = roundApprox();
          } else {
              latestApprox = currentApprox;
              initialiseAproxArray();
              appendApprox(currentApprox);
          }
      }
      knownNeighbors.clear();
  }

  int get_density_approx() override {
//      std::cout << simTime().str() << " " << gateway->get_name() <<
//          ": density approximation gets " << lastDensityApprox << endl;
      return latestApprox;
  }

  double mobility_estimation() override {
    return 0.0;
  }

  bool handle_messages(cMessage* m) override {
    auto pkt = PK(m);
    auto hello = dynamic_cast<const inet::broadcasting::Hello*>(pkt);
    if (hello && hello->getSender() != gateway->get_name()) {
//        std::cout << simTime().str() << " " << gateway->get_name() <<
//            ": hello msg received from " << hello->getSender() << endl;
        knownNeighbors[hello->getSender()] = 0;
    }
    auto br = dynamic_cast<const inet::broadcasting::Broadcast*>(pkt);
    if (br && br->getSender() != gateway->get_name()) {
//        std::cout << simTime().str() << " " << gateway->get_name() <<
//            ": broadcast msg received from " << br->getSender() << endl;
        knownNeighbors[br->getSender()] = 0;
    }
    return true;
  }

  void initialise(std::shared_ptr<IBroadcastGateway> gateway) override {
      initialiseAproxArray();
      this->gateway = gateway;
  }
};

Register_Class(BroadcastMsgBasedMonitor);

}
