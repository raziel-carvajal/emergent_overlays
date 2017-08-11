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

#include "adaptive.h"


#include "inet/mobility/contract/IMobility.h"

#include <algorithm>
#include <cmath>
#include <vector>

using namespace std;
using inet::broadcasting::Broadcast;

namespace inet {

Define_Module(FullyAdaptive);


void
FullyAdaptive::handleMessageWhenUp(cMessage *msg)
{
  if (msg->isSelfMessage()) {
    // detect if the message is handled by the protocols
    switch (msg->getKind()) {
      case START:
        BroadcastingAppBase::handleMessageWhenUp(msg);
      break;
      case SAY_HELLO:
        {
          if (gateway->get_parameter<bool>(current_protocol_name, "nr_hello_messages")) {
            auto p = build_hello_message();
            if (packet_to_piggybag) {
              p->encapsulate(packet_to_piggybag);
              packet_to_piggybag = nullptr;
            }
//            std::cout << simTime().str() << " " + gateway->get_name() << " :: Sending HelloMessage" << endl;
            gateway->send_package(p);
            gateway->delayed_event(SAY_HELLO, "helloTime", gateway->get_parameter<double>(current_protocol_name, "helloTime"));
            knownProtocols[current_protocol_name]->on_saying_hello();
          }
          cancelAndDelete(msg);
        }
      break;
      case HALT_SIMULATION_DELAY:
        emit(signal_protocol_change, 'E');
        BroadcastingAppBase::handleMessageWhenUp(msg);
      break;
      case APPROXIMATE_DENSITY:
          {
            Coord p = gateway->get_current_position();
            monitor->compute_density_approx();
            //gateway->emitDensityApproximation(monitor->get_density_approx());
            //TODO find a better way to call get_density_approx()
            gateway->emitNodePosition(p.x, p.y, monitor->get_density_approx());

            cancelAndDelete(msg);
            gateway->delayed_event(APPROXIMATE_DENSITY, "density approximation",
                                   par("intervalBroadcastTime").doubleValue());
          }
      break;
      default:
      	{
          auto initialProtocol = par("initialProtocol").stdstringValue();
          if (msg->getKind() == DO_ADAPTATION && initialProtocol != "middleware") {
            adaptation();
            cancelAndDelete(msg);
          }
      		else if (!knownProtocols[current_protocol_name]->handle(msg)) {
	          BroadcastingAppBase::handleMessageWhenUp(msg);
	        }
	        else {
	          cancelAndDelete(msg);
	        }
        }
      break;
    }
  }
  else if (msg->getKind() == UDP_I_DATA) {
    monitor->handle_messages(msg);
    auto pkt = PK(msg);
    auto initialProtocol = par("initialProtocol").stdstringValue();
  	if (initialProtocol != "middleware") {
	    if (pkt->hasEncapsulatedPacket()) {
	      pkt = pkt->getEncapsulatedPacket();
	    }
	    auto willing = dynamic_cast<inet::WillingToChange*>(pkt);
	    if (willing) {
	      if (willingToChange &&
	          willing->getTargetProtocol() == willingToChangeToProtocol &&
	          willingToChangeToProtocol != current_protocol_name) {

	        change_current_protocol(willingToChangeToProtocol);
	        std::cerr << "CHANGING PROTOCOL TO\t\t\t" << willingToChangeToProtocol << '\n';

	        if (!packet_to_piggybag) {
	          packet_to_piggybag = new inet::WillingToChange("willing to change");
	          packet_to_piggybag->setSender(myself.c_str());
	          packet_to_piggybag->setTargetProtocol(willingToChangeToProtocol.c_str());
	          if (!gateway->get_parameter<bool>(current_protocol_name, "nr_hello_messages")) {
	            gateway->send_package(packet_to_piggybag);
	            packet_to_piggybag = nullptr;
	          }
	        }
	        willingToChangeToProtocol = "";
	        willingToChange = false;
	        willing = nullptr;
	      }
	    }
    }
    BroadcastingAppBase::handleMessageWhenUp(msg);
  }

}


void
FullyAdaptive::adaptation()
{
  auto density = monitor->get_density_approx();
  gateway->delayed_event(DO_ADAPTATION, "adaptation self message", 0.1);
  if (!withAdaptation) return;
  return;
  const string dense_region_protocol = gateway->get_parameter<string>("AdaptiveBase", "dense_region");
  const string sparse_region_protocol = gateway->get_parameter<string>("AdaptiveBase", "sparse_region");
  if (policy == AdaptationPolicy::LOCAL) {
    if (density > density_threshold_upper && current_protocol_name != dense_region_protocol) {
      change_current_protocol(dense_region_protocol);
    }
    else if (density < density_threshold_lower && current_protocol_name != sparse_region_protocol) {
      change_current_protocol(sparse_region_protocol);
    }
  }
  else if (policy == AdaptationPolicy::SWSP) {
    bool change = false;
    if (density > density_threshold_upper && current_protocol_name != dense_region_protocol) {
      willingToChange = true;
      willingToChangeToProtocol = dense_region_protocol;
      change = true;
    }
    else if (density < density_threshold_lower && current_protocol_name != sparse_region_protocol) {
      willingToChange = true;
      willingToChangeToProtocol = sparse_region_protocol;
      change = true;
    }
    if (change && !packet_to_piggybag) {
      packet_to_piggybag = new inet::WillingToChange("willing to change");
      packet_to_piggybag->setSender(myself.c_str());
      packet_to_piggybag->setTargetProtocol(willingToChangeToProtocol.c_str());
      if (!gateway->get_parameter<bool>(current_protocol_name, "nr_hello_messages")) {
        gateway->send_package(packet_to_piggybag);
        packet_to_piggybag = nullptr;
      }
    }
  }
}


void
FullyAdaptive::on_payload_received(const Broadcast* m) {
  knownProtocols[current_protocol_name]->process_payload(m);
}

void
FullyAdaptive::time_to_broadcast_payload(void* user_data)
{
  knownProtocols[current_protocol_name]->time_to_broadcast_payload(user_data);
}


void
FullyAdaptive::on_hello_received(const broadcasting::Hello* msg)
{
  knownProtocols[current_protocol_name]->process_hello(msg);
}


void
FullyAdaptive::change_current_protocol(const std::string& protocol)
{
  current_protocol_name = protocol;
  gateway->setProtocolId(current_protocol_name);

  emit(signal_protocol_change, current_protocol_name[0]);

  if (gateway->get_parameter<bool>(current_protocol_name, "nr_hello_messages")) {
    int n = std::stoi (myself.substr(5, myself.size()));
    auto delta = (n % 50 == 0)? 0.003 : ((n % 50) * 0.002);
    auto t = gateway->get_parameter<double>(current_protocol_name, "helloTime") + delta;
    gateway->delayed_event(SAY_HELLO, "helloTime", t);
  }
}


void
FullyAdaptive::processStart()
{
  BroadcastingAppBase::processStart();

  signal_protocol_change = this->registerSignal("protocol_change");

  //DO_ADAPTATION = gateway->register_new_control_message();
//  std::string monitoring_class("inet::SnifferBasedMonitoring");
  std::string monitoring_class("inet::BroadcastMsgBasedMonitor");
  monitor = std::unique_ptr<IMonitoringMechanism>(dynamic_cast<IMonitoringMechanism*>(createOne(monitoring_class.c_str())));
  monitor->initialise(gateway);

  auto initialProtocol = par("initialProtocol").stdstringValue();
  if (withAdaptation && initialProtocol != "middleware") {
//    DO_ADAPTATION = gateway->register_new_control_message();
    gateway->delayed_event(DO_ADAPTATION, "adaptation self message", 0.1);


    density_threshold_lower = par("density_threshold_lower").longValue();
    density_threshold_upper = par("density_threshold_upper").longValue();
    deltaApprox = par("deltaApprox").doubleValue();

    policy = AdaptationPolicy::LOCAL;
    if (par("adaptation_policy").stdstringValue() == "swsp") {
      policy = AdaptationPolicy::SWSP;
    }
  }

  auto protocols = { "Flooding2", "Mpr_t2", "Abba2" };
  for (const auto& p: protocols) {
    current_protocol_name = p;
    auto current_protocol = dynamic_cast<IBroadcastProtocol*>(createOne(std::string("inet::" + current_protocol_name).c_str()));
    if (!current_protocol) {
      throw std::runtime_error("Couldn't create instance of class inet::" + current_protocol_name);
    }
    current_protocol->set_protocol_name(current_protocol_name);
    // initialize protocol
    current_protocol->initialize(myself, gateway);
    knownProtocols.emplace(current_protocol_name, std::unique_ptr<IBroadcastProtocol>(current_protocol));
  }

  if (initialProtocol == "middleware") {
  	auto pos = gateway->get_current_position();
    if (pos.x >= 81 && pos.x <= 169 && pos.y >= 81 && pos.y <= 169) {
      initialProtocol = "Mpr_t2";
    }
    else {
      initialProtocol = "Flooding2";
    }
  }

  change_current_protocol(initialProtocol);
}


inet::broadcasting::Hello*
FullyAdaptive::build_hello_message()
{
  auto m = knownProtocols[current_protocol_name]->build_hello_message();
  m->setX(gateway->get_current_position().x);
  m->setY(gateway->get_current_position().y);
  m->setProtocolId (current_protocol_name.c_str());
  return m;
}

} //namespace
