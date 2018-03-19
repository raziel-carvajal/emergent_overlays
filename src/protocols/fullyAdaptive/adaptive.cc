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
      case BUILD_STRUCT: {
          knownProtocols[current_protocol_name]->on_saying_hello();
          auto t = gateway->get_parameter<double>(current_protocol_name, "helloTime");
          gateway->delayed_event(BUILD_STRUCT, "", t);
          cancelAndDelete(msg);
      }
      break;
      case BOOTSTRAP_MSG:
      {
//         std::cout << simTime().str() << " " + gateway->get_name() << " BOOTSTRAP MSG, " << current_protocol_name << endl;
        auto p = build_hello_message();
        if (packet_to_piggybag) {
            p->encapsulate(packet_to_piggybag);
            packet_to_piggybag = nullptr;
        }
        gateway->send_package(p);
        cancelAndDelete(msg);
//        gateway->delayed_event(BUILD_STRUCT, "", 0.050);
      }
      break;
      case SAY_HELLO:
        {
          if (keep_sending_hello_msgs) {
            auto p = build_hello_message();
            if (packet_to_piggybag) {
              p->encapsulate(packet_to_piggybag);
              packet_to_piggybag = nullptr;
            }
//            std::cout << simTime().str() << " " + gateway->get_name() << " HELLO_MSG, " << current_protocol_name << endl;
            gateway->send_package(p);
            /* NOTE: once the timeout of sending control messages is set,
             *  two messages must be sent to build one-hop and two-hop
             *  neighbor
             */
//            gateway->delayed_event(BOOTSTRAP_MSG, "", 0.050);
            gateway->delayed_event(
                SAY_HELLO, "helloTime",
                gateway->get_parameter<double>(current_protocol_name, "helloTime")
            );

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
//            std::cout << simTime().str() << " " << gateway->get_name() <<
//              ": density approximation gets " << monitor->get_density_approx() << endl;
            gateway->emitNodePosition(p.x, p.y, monitor->get_density_approx());
//            std::cout << simTime().str() << " " + gateway->get_name()
//                << " next approx event in " << par("intervalBroadcastTime").doubleValue()
//                << endl;
            cancelAndDelete(msg);
            gateway->delayed_event(APPROXIMATE_DENSITY, "density approximation",
                                   par("intervalBroadcastTime").doubleValue());
          }
      break;
      default:
      	{
          auto initialProtocol = par("initialProtocol").stdstringValue();
          if (msg->getKind() == DO_ADAPTATION && initialProtocol != "middleware") {
              // std::cout << simTime().str() << " " + gateway->get_name()
              //     << " DO_ADAPTATION" << endl;
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
  gateway->delayed_event(DO_ADAPTATION, "adaptation self message", adapTimer);
  if (!withAdaptation) return;
  const string dense_region_protocol = gateway->get_parameter<string>("AdaptiveBase", "dense_region");
  const string sparse_region_protocol = gateway->get_parameter<string>("AdaptiveBase", "sparse_region");
  switch (policy) {
    case AdaptationPolicy::LOCAL:
    {
    //    std::cout << simTime().str() << " " + gateway->get_name() << " observed density " <<
    //          density << endl;
        if (density > density_threshold_lower && current_protocol_name != dense_region_protocol) {
           std::cout << simTime().str() << " " + gateway->get_name() << " node is in dense area " << endl;
          change_current_protocol(dense_region_protocol);
        }
        else if (density <= density_threshold_lower && current_protocol_name != sparse_region_protocol) {
            std::cout << simTime().str() << " " + gateway->get_name() << " node is in sparse " << endl;
            change_current_protocol(sparse_region_protocol);
        }

        break;
    }
    case AdaptationPolicy::SWSP:
    {
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
        break;
    }
    case AdaptationPolicy::DENSITY_AREA:
    {
        // This policy considers that within the area of communication there are 2 regions, dense and sparse
        // respectively. Those nodes positioned at the dense region execute dense_region_protocol and the
        // rest of nodes execute sparse_region_protocol
        Coord p = gateway->get_current_position();
        EV_DEBUG << simTime().str() << " " + gateway->get_name() << " running [" <<
                  current_protocol_name << "] position [" << p.x << ", " << p.y << "]" << endl;
        bool inDensAreaAbs = centerDensAx - (denseAreaWid/2) <= p.x && centerDensAx + (denseAreaWid/2) >= p.x;
        bool inDensAreaOrd = centerDensAy - (denseAreaWid/2) <= p.y && centerDensAy + (denseAreaWid/2) >= p.y;
        if (inDensAreaAbs && inDensAreaOrd) {
            EV_INFO << simTime().str() << " " + gateway->get_name() << " I am at dense zone!" << endl;
            if (current_protocol_name != dense_region_protocol){
                EV << simTime().str() << " " + gateway->get_name() << " switching to [" <<
                  dense_region_protocol << "]" << endl;
                change_current_protocol(dense_region_protocol);
            }
        } else {
            if (current_protocol_name != sparse_region_protocol){
                EV << simTime().str() << " " + gateway->get_name() << " switching to [" <<
                  sparse_region_protocol << "]" << endl;
                change_current_protocol(sparse_region_protocol);
            }
        }
        break;
    }
  }
}


void
FullyAdaptive::on_payload_received(const Broadcast* m) {
//  cout << simTime().str() + " " + myself + " :: " + "KEY_RECEPTION " + m->getId() + " FROM_PEER " + string(m->getSender()) << endl;
  knownProtocols[current_protocol_name]->process_payload(m);
}

void
FullyAdaptive::time_to_broadcast_payload(void* user_data)
{
  // cout << simTime().str() + " " + myself + " DOING BROADCAST" << endl;
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
//  std::cout << simTime().str() << " " + gateway->get_name() << " :: running algorithm " <<
//            current_protocol_name << endl;
  current_protocol_name = protocol;
  gateway->setProtocolId(current_protocol_name);

//  std::cout << simTime().str() << " " + gateway->get_name() << " :: switch to algo" <<
//          protocol << endl;
  emit(signal_protocol_change, current_protocol_name[0]);

  if (gateway->get_parameter<bool>(current_protocol_name, "nr_hello_messages")) {
      keep_sending_hello_msgs = true;
      auto t = gateway->get_parameter<double>(current_protocol_name, "helloTime") + delta;
      gateway->delayed_event(SAY_HELLO, "helloTime", t);
  } else {
      keep_sending_hello_msgs = false;
  }
}


void
FullyAdaptive::processStart()
{
  BroadcastingAppBase::processStart();

  signal_protocol_change = this->registerSignal("protocol_change");

  std::string monitoring_class("inet::BroadcastMsgBasedMonitor");
  monitor = std::unique_ptr<IMonitoringMechanism>(dynamic_cast<IMonitoringMechanism*>(createOne(monitoring_class.c_str())));
  monitor->initialise(gateway);

  auto initialProtocol = par("initialProtocol").stdstringValue();
  if (withAdaptation && initialProtocol != "middleware") {
    density_threshold_lower = par("density_threshold_lower").longValue();
    density_threshold_upper = par("density_threshold_upper").longValue();
    deltaApprox = par("deltaApprox").doubleValue();
    centerDensAx = par("centerDensAx").doubleValue();
    centerDensAy = par("centerDensAy").doubleValue();
    denseAreaWid = par("denseAreaWid").doubleValue();
    adapTimer = par("adapTimer").doubleValue();

    gateway->delayed_event(DO_ADAPTATION, "adaptation self message", adapTimer);

    switch ( (int) par("adaptation_policy").longValue() ) {
        case AdaptationPolicy::LOCAL:
            policy = AdaptationPolicy::LOCAL;
            break;
        case AdaptationPolicy::SWSP:
            policy = AdaptationPolicy::SWSP;
            break;
        case AdaptationPolicy::DENSITY_AREA:
            policy = AdaptationPolicy::DENSITY_AREA;
            break;
    }
  }

  auto protocols = { "Flooding2", "Mpr_t2", "Abba2", "TimeBasedFlooding" };
  for (const auto& p: protocols) {
    current_protocol_name = p;
    auto current_protocol = dynamic_cast<IBroadcastProtocol*>(createOne(std::string("inet::" + current_protocol_name).c_str()));
    if (!current_protocol) {
      throw std::runtime_error("Couldn't create instance of class inet::" + current_protocol_name);
    }
    current_protocol->set_protocol_name(current_protocol_name);
    // initialize protocol
    current_protocol->initialize(myself, gateway);
    //knownProtocols.emplace(current_protocol_name, std::unique_ptr<IBroadcastProtocol>(current_protocol));
    knownProtocols[current_protocol_name] = std::unique_ptr<IBroadcastProtocol>(current_protocol);
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

  current_protocol_name = initialProtocol;
  gateway->setProtocolId(current_protocol_name);
  emit(signal_protocol_change, current_protocol_name[0]);

  /** NOTE when a protocol requires to send control messages,
   * we need to give a grace period to start the first
   * broadcast session.
   * */
  if (gateway->get_parameter<bool>(current_protocol_name, "nr_hello_messages")) {
      keep_sending_hello_msgs = true;
      int i = 1;
      while(i <= (int) par("bootstrap_ctrl_msgs_no").longValue()){
          gateway->delayed_event(BOOTSTRAP_MSG, "helloTime", i * 1.0 + delta);
          i = i + 1;
      }
      gateway->delayed_event(BUILD_STRUCT, "",
          0.3 + par("bootstrap_ctrl_msgs_no").longValue() * 1.0
      );
      auto t = par("wakeUpTime").doubleValue() +
          gateway->get_parameter<double>(current_protocol_name, "helloTime");
      gateway->delayed_event(SAY_HELLO, "helloTime", t + delta);
  }

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
