
#include "IMonitoringMechanism.h"

#include "broadcasting/BroadcastingAppBase_m.h"

#include "inet/transportlayer/contract/udp/UDPControlInfo.h"

#include <map>
#include <vector>
#include <string>
#include <iostream>

namespace inet {


class SnifferBasedMonitoring: public IMonitoringMechanism {
public:

  int density_estimation() override {
    return knownNeighbors.size();
  }

  double mobility_estimation() override {
    return 0.0;
  }

  bool handle_messages(cMessage* m) override {
    if (!gateway) return false;

    if (m->isSelfMessage()) {
      if (m->getKind() == update_message) {
        // update and remove if necessary
        for(auto it = knownNeighbors.begin(), ite = knownNeighbors.end(); it != ite;) {
          it->second++;
          it = (it->second == 3)?(knownNeighbors.erase(it)): (std::next(it, 1));
        }
        gateway->delayed_event(update_message, "update in sniffer based monitor", 1.0);
        return true;
      }
      return false;
    }
    else if (m->getKind() == UDP_I_DATA) {
      auto pkt = PK(m);
      auto hello = dynamic_cast<const inet::broadcasting::Hello*>(pkt);
      if (hello) {
        knownNeighbors[hello->getSender()] = 0;
      }
      auto br = dynamic_cast<const inet::broadcasting::Broadcast*>(pkt);
      if (br) {
        knownNeighbors[br->getSender()] = 0;
      }
      return false;
    }
  }

  void initialise(std::shared_ptr<IBroadcastGateway> gateway) override {
      this->gateway = gateway;
      update_message = this->gateway->register_new_control_message();
      this->gateway->delayed_event(update_message, "update in sniffer based monitor", 1.0);
  }

private:
  int update_message;
  std::shared_ptr<IBroadcastGateway> gateway = nullptr;
  std::map<std::string, int> knownNeighbors;
};

Register_Class(SnifferBasedMonitoring);

}
