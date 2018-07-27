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

void FullyAdaptive::handleMessageWhenUp(cMessage *msg) {
// std::cout << simTime().str() << " " + gateway->get_name() <<
// " BOOTSTRAP MSG, " << current_protocol_name << endl;
// if (!use_topology_fix) throw std::logic_error("Shouldn't call this
//	if we are not fixing the issue with topology-based algorithms");
	if (msg->isSelfMessage()) {
		// detect if the message is handled by the protocols
		switch (msg->getKind()) {
		case START:
			BroadcastingAppBase::handleMessageWhenUp(msg);
			break;
		case BUILD_STRUCT: {
			if (keep_sending_hello_msgs) {
				knownProtocols[current_protocol_name]->on_saying_hello();
				double t = gateway->get_parameter<double>(current_protocol_name,
						"helloTime");
				gateway->delayed_event(BUILD_STRUCT, "BUILD_STRUCT", t);
			}
			cancelAndDelete(msg);
		}
			break;
		case BOOTSTRAP_MSG: {
			auto p = build_hello_message();
			if (packet_to_piggybag) {
				p->encapsulate(packet_to_piggybag);
				packet_to_piggybag = nullptr;
			}
			gateway->send_package(p);
			cancelAndDelete(msg);
		}
			break;
		case SAY_HELLO: {
			if (keep_sending_hello_msgs) {
				auto p = build_hello_message();
//				if (packet_to_piggybag) {
//					p->encapsulate(packet_to_piggybag);
//					packet_to_piggybag = nullptr;
//				}
				gateway->send_package(p);
				/* NOTE: once the timeout of sending control messages is set,
				 *  two consecutive messages must be sent to keep track of
				 *  one-hop and two-hop neighbors. Such behavior depends
				 *  on the implementation of the CDS-based algorithm
				 */
				auto t = gateway->get_parameter<double>(current_protocol_name, "helloTime");
				gateway->delayed_event(SAY_HELLO, "SAY_HELLO", t);
			}
			cancelAndDelete(msg);
		}
			break;
			/* INFO this event serves to keep track of nodes' surroundings.
			 *
			 */
		case APPROXIMATE_DENSITY: {
			Coord p = gateway->get_current_position();
			monitor->compute_density_approx();
			//gateway->emitDensityApproximation(monitor->get_density_approx());
			//TODO find a better way to call get_density_approx()
			gateway->emitNodePosition(p.x, p.y, monitor->get_density_approx());
			cancelAndDelete(msg);
		}
			break;
			default: {
				BroadcastingAppBase::handleMessageWhenUp(msg);
//			auto initialProtocol = par("initialProtocol").stdstringValue();
//			if (msg->getKind() == DO_ADAPTATION && initialProtocol != "middleware") {
//				adaptation();
//				cancelAndDelete(msg);
//			} else if (!knownProtocols[current_protocol_name]->handle(msg)) {
//				BroadcastingAppBase::handleMessageWhenUp(msg);
//			} else {
//				cancelAndDelete(msg);
//			}
			}
			break;
		}
	} else if (msg->getKind() == UDP_I_DATA) {
//		auto pkt = PK(msg);
//		auto initialProtocol = par("initialProtocol").stdstringValue();
		// XXX what the hell is this?
//		if (initialProtocol != "middleware") {
//			if (pkt->hasEncapsulatedPacket()) {
//				pkt = pkt->getEncapsulatedPacket();
//			}
//			/*
//			 * XXX this is a sort of collaborative decision to switch
//			 *   of dissemination protocol, but it is not clear how to
//			 *   tag those members who will execute the change
//			 */
//			auto willing = dynamic_cast<inet::WillingToChange*>(pkt);
//			if (willing) {
//				if (willingToChange
//						&& willing->getTargetProtocol() == willingToChangeToProtocol
//						&& willingToChangeToProtocol != current_protocol_name) {
//
//					change_current_protocol(willingToChangeToProtocol);
//					std::cerr << "CHANGING PROTOCOL TO\t\t\t" << willingToChangeToProtocol
//							<< '\n';
//
//					if (!packet_to_piggybag) {
//						packet_to_piggybag = new inet::WillingToChange("willing to change");
//						packet_to_piggybag->setSender(myself.c_str());
//						packet_to_piggybag->setTargetProtocol(
//								willingToChangeToProtocol.c_str());
//						if (!gateway->get_parameter<bool>(current_protocol_name,
//								"nr_hello_messages")) {
//							gateway->send_package(packet_to_piggybag);
//							packet_to_piggybag = nullptr;
//						}
//					}
//					willingToChangeToProtocol = "";
//					willingToChange = false;
//					willing = nullptr;
//				}
//			}
//		}
		// keep track of known neighbors
		monitor->handle_messages(msg);
		BroadcastingAppBase::handleMessageWhenUp(msg);
	}

}

void FullyAdaptive::adaptation() {
	auto density = monitor->get_density_approx();
	gateway->delayed_event(DO_ADAPTATION, "adaptation self message", adapTimer);
	if (!withAdaptation)
		return;
	const string dense_region_protocol = gateway->get_parameter<string>(
			"AdaptiveBase", "dense_region");
	const string sparse_region_protocol = gateway->get_parameter<string>(
			"AdaptiveBase", "sparse_region");
	switch (policy) {
	case AdaptationPolicy::LOCAL: {
		//    std::cout << simTime().str() << " " + gateway->get_name() << " observed density " <<
		//          density << endl;
		if (density > density_threshold_lower
				&& current_protocol_name != dense_region_protocol) {
			std::cout << simTime().str() << " " + gateway->get_name()
					<< " node is in dense area " << endl;
			change_current_protocol(dense_region_protocol);
		} else if (density <= density_threshold_lower
				&& current_protocol_name != sparse_region_protocol) {
			std::cout << simTime().str() << " " + gateway->get_name()
					<< " node is in sparse " << endl;
			change_current_protocol(sparse_region_protocol);
		}

		break;
	}
	case AdaptationPolicy::SWSP: {
		bool change = false;
		if (density > density_threshold_upper
				&& current_protocol_name != dense_region_protocol) {
			willingToChange = true;
			willingToChangeToProtocol = dense_region_protocol;
			change = true;
		} else if (density < density_threshold_lower
				&& current_protocol_name != sparse_region_protocol) {
			willingToChange = true;
			willingToChangeToProtocol = sparse_region_protocol;
			change = true;
		}
		if (change && !packet_to_piggybag) {
			packet_to_piggybag = new inet::WillingToChange("willing to change");
			packet_to_piggybag->setSender(myself.c_str());
			packet_to_piggybag->setTargetProtocol(willingToChangeToProtocol.c_str());
			if (!gateway->get_parameter<bool>(current_protocol_name,
					"nr_hello_messages")) {
				gateway->send_package(packet_to_piggybag);
				packet_to_piggybag = nullptr;
			}
		}
		break;
	}
	case AdaptationPolicy::DENSITY_AREA: {
		// This policy considers that within the area of communication there are 2 regions, dense and sparse
		// respectively. Those nodes positioned at the dense region execute dense_region_protocol and the
		// rest of nodes execute sparse_region_protocol
		Coord p = gateway->get_current_position();
		EV_DEBUG << simTime().str() << " " + gateway->get_name() << " running ["
								<< current_protocol_name << "] position [" << p.x << ", " << p.y
								<< "]" << endl;
		bool inDensAreaAbs = centerDensAx - (denseAreaWid / 2) <= p.x
				&& centerDensAx + (denseAreaWid / 2) >= p.x;
		bool inDensAreaOrd = centerDensAy - (denseAreaWid / 2) <= p.y
				&& centerDensAy + (denseAreaWid / 2) >= p.y;
		if (inDensAreaAbs && inDensAreaOrd) {
			EV_INFO << simTime().str() << " " + gateway->get_name()
									<< " I am at dense zone!" << endl;
			if (current_protocol_name != dense_region_protocol) {
				EV << simTime().str() << " " + gateway->get_name() << " switching to ["
							<< dense_region_protocol << "]" << endl;
				change_current_protocol(dense_region_protocol);
			}
		} else {
			if (current_protocol_name != sparse_region_protocol) {
				EV << simTime().str() << " " + gateway->get_name() << " switching to ["
							<< sparse_region_protocol << "]" << endl;
				change_current_protocol(sparse_region_protocol);
			}
		}
		break;
	}
	}
}

void FullyAdaptive::on_payload_received(const Broadcast* m) {
//  cout << simTime().str() + " " + myself + " :: " + "KEY_RECEPTION " + m->getId() + " FROM_PEER " + string(m->getSender()) << endl;
	knownProtocols[current_protocol_name]->process_payload(m);
}

void FullyAdaptive::time_to_broadcast_payload(void* user_data) {
	cout << simTime().str() + " " + myself + " DOING BROADCAST" << endl;
	knownProtocols[current_protocol_name]->time_to_broadcast_payload(user_data);
}

void FullyAdaptive::on_hello_received(const broadcasting::Hello* msg) {
	knownProtocols[current_protocol_name]->process_hello(msg);
}

void FullyAdaptive::change_current_protocol(const std::string& protocol) {
//  std::cout << simTime().str() << " " + gateway->get_name() << " :: running algorithm " <<
//            current_protocol_name << endl;
	current_protocol_name = protocol;
	gateway->setProtocolId(current_protocol_name);

//  std::cout << simTime().str() << " " + gateway->get_name() << " :: switch to algo" <<
//          protocol << endl;
	emit(signal_protocol_change, current_protocol_name[0]);

	if (gateway->get_parameter<bool>(current_protocol_name,
			"nr_hello_messages")) {
		keep_sending_hello_msgs = true;
		auto t = gateway->get_parameter<double>(current_protocol_name, "helloTime")
				+ delta;
		gateway->delayed_event(SAY_HELLO, "helloTime", t);
	} else {
		keep_sending_hello_msgs = false;
	}
}

void FullyAdaptive::processStart() {
	BroadcastingAppBase::processStart();
	signal_protocol_change = this->registerSignal("protocol_change");

	std::string monitoring_class("inet::BroadcastMsgBasedMonitor");
	monitor = std::unique_ptr<IMonitoringMechanism>(
			dynamic_cast<IMonitoringMechanism*>(createOne(monitoring_class.c_str())));
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

		switch ((int) par("adaptation_policy").longValue()) {
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
	for (const auto& p : protocols) {
		current_protocol_name = p;
		auto current_protocol = dynamic_cast<IBroadcastProtocol*>(createOne(
				std::string("inet::" + current_protocol_name).c_str()));
		if (!current_protocol) {
			throw std::runtime_error(
					"Couldn't create instance of class inet::" + current_protocol_name);
		}
		current_protocol->set_protocol_name(current_protocol_name);
		// initialize protocol
		current_protocol->initialize(myself, gateway);
		//knownProtocols.emplace(current_protocol_name, std::unique_ptr<IBroadcastProtocol>(current_protocol));
		knownProtocols[current_protocol_name] = std::unique_ptr<IBroadcastProtocol>(
				current_protocol);
	}

	current_protocol_name = initialProtocol;
	gateway->setProtocolId(current_protocol_name);
	emit(signal_protocol_change, current_protocol_name[0]);

	if (gateway->get_parameter<bool>(current_protocol_name,
			"nr_hello_messages")) {
		keep_sending_hello_msgs = true;
		int i = 1;

		/**
		 * CDS-based algorithms require to exchange neighbors before
		 * the first broadcast session (bootstrap phase)
		 * */
		while (i <= (int) par("bootstrap_ctrl_msgs_no").longValue()) {
			gateway->delayed_event(BOOTSTRAP_MSG, "BOOTSTRAP_MSG",
					i * 1.0 + delta);
			i = i + 1;
		}
		gateway->delayed_event(BUILD_STRUCT, "BUILD_STRUCT",
				0.3 + par("bootstrap_ctrl_msgs_no").longValue() * 1.0);

		// schedule the first control message
		auto t = par("wakeUpTime").doubleValue()
				+ gateway->get_parameter<double>(current_protocol_name, "helloTime");
		gateway->delayed_event(SAY_HELLO, "SAY_HELLO", t + delta);
	}

}

inet::broadcasting::Hello*
FullyAdaptive::build_hello_message() {
	auto m = knownProtocols[current_protocol_name]->build_hello_message();
	m->setSession(gateway->set_and_get_ctrl_msg_no());
	m->setX(gateway->get_current_position().x);
	m->setY(gateway->get_current_position().y);
	m->setProtocolId(current_protocol_name.c_str());
	return m;
}

} //namespace
