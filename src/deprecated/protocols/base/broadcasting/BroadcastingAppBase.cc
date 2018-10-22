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

#include "BroadcastingAppBase.h"
#include "BroadcastingAppBase_m.h"

#include "inet/networklayer/common/L3AddressResolver.h"
#include "inet/transportlayer/contract/udp/UDPControlInfo.h"
#include "inet/mobility/contract/IMobility.h"
#include "inet/power/contract/IEnergyStorage.h"
#include "inet/physicallayer/idealradio/IdealTransmitter.h"

#include "inet/common/PatternMatcher.h"
#include "inet/common/XMLUtils.h"

#include <algorithm>
#include <math.h>

using namespace std;
using inet::broadcasting::Broadcast;
using inet::broadcasting::Hello;
using inet::broadcasting::Border;

namespace inet {

// Define_Module(BroadcastingAppBase);

BroadcastingAppBase::OmnetBroadcastGateway::OmnetBroadcastGateway(
		BroadcastingAppBase* a) :
		app { a }, last_message_assigned { ControlMessageTypes::Last } {
}

Coord BroadcastingAppBase::OmnetBroadcastGateway::get_current_position() {
	return app->updatePosition();
}

double BroadcastingAppBase::OmnetBroadcastGateway::get_transmission_radius() {
	return app->get_radious();
}

L3Address BroadcastingAppBase::OmnetBroadcastGateway::getAddr(
		const std::string& id) {
	return app->getAddr(id);
} // so ugly

void BroadcastingAppBase::OmnetBroadcastGateway::send_package(cPacket* m) {
	app->send_package(m);
} // send a package to all nearby devices

void BroadcastingAppBase::OmnetBroadcastGateway::broadcast(std::string key,
		broadcasting::Broadcast* msg) {
	app->broadcast(key, msg);
}

std::string BroadcastingAppBase::OmnetBroadcastGateway::createUniqueBroadcastingSessionId() {
	return app->createUniqueBroadcastingSessionId();
}

void BroadcastingAppBase::OmnetBroadcastGateway::emitBroadcastMsgReceived(
		const std::string& value) {
	app->emitBroadcastMsgReceived(value);
} // important. you should use it. log data (statistics in vector)

void BroadcastingAppBase::OmnetBroadcastGateway::emitForwardTypeSignal(int s) {
	app->emitForwardTypeSignal(s);
}

void BroadcastingAppBase::OmnetBroadcastGateway::delayed_event(int type,
		const std::string& key, double delay) {
	app->delayed_event(type, key, delay);
}

cMessage*
BroadcastingAppBase::OmnetBroadcastGateway::delayed_broadcast(
		const std::string& key, double delay) {
	app->delayed_broadcast(key, delay);
}

double BroadcastingAppBase::OmnetBroadcastGateway::get_double_parameter(
		const std::string& protocol, const std::string& param) {
	auto it = params[protocol].find(param);
	if (it != params[protocol].end()) {
		return std::stod(it->second);
	}
	// if (param == "timeOut") return 0.02;
	// if (param == "k") return 4;
	// if (param == "sigma") return 1.0;
	// if (param == "probLi") return 0.5;
	// if (param == "alpha") return 1.0;
	// if (param == "miTreb") return 0.1;
	// if (param == "maTreb") return 0.3;
	// if (param == "A") return 0.0;
	return app->par(param.c_str()).doubleValue();
}

bool BroadcastingAppBase::OmnetBroadcastGateway::get_bool_parameter(
		const std::string& protocol, const std::string& param) {
	auto it = params[protocol].find(param);
	if (it != params[protocol].end()) {
		return it->second == "true";
	}
	// if (param == "doRule2") return false;
	// if (param == "doOptiP") return false;
	return app->par(param.c_str()).boolValue();
}

std::string BroadcastingAppBase::OmnetBroadcastGateway::get_string_parameter(
		const std::string& protocol, const std::string& param) {
	auto it = params[protocol].find(param);
	if (it != params[protocol].end()) {
		return it->second;
	}
	// if (param == "scheme") return "DENSITY_BORDER_AWARE";
	return app->par(param.c_str()).stdstringValue();
}

void BroadcastingAppBase::OmnetBroadcastGateway::cancel_message(cMessage* m) {
	if (m != nullptr)
		app->cancelAndDelete(m);
}

bool BroadcastingAppBase::OmnetBroadcastGateway::amIborderNode() {
	return app->am_i_border_node[app->latest_ctrl_session];
}

void BroadcastingAppBase::OmnetBroadcastGateway::emitDensityApproximation(
		int value) {
	app->emit(app->signal_density_approximation, value);
}

void BroadcastingAppBase::OmnetBroadcastGateway::emitNodePosition(float x,
		float y, float density) {
	app->emit(app->signal_density_approximation, density);
	app->emit(app->signal_node_position_x, x);
	app->emit(app->signal_node_position_y, y);
}

int BroadcastingAppBase::OmnetBroadcastGateway::register_new_control_message() {
	return ControlMessageTypes::Last + 1;
}

std::string BroadcastingAppBase::getLogHeader() {
	return simTime().str() + " " + myself + " :: ";
}

BroadcastingAppBase::BroadcastingAppBase() {
	gateway = std::make_shared<OmnetBroadcastGateway>(this);
}

bool BroadcastingAppBase::borderDetector(cMessage* msg) {
	bool known_ctrl_msg = false;
	bool msg_trans_ok =
			processMessage<Hello>(PK(msg),
					[&] (const Hello* m) {
						if (m->getProtocolId() != protocolId) {
							bool known_foreign_algo =
							(known_border_nodes.find(m->getSession()) != known_border_nodes.end() ) &&
							(
									known_border_nodes[m->getSession()].find(m->getProtocolId()) !=
									known_border_nodes[m->getSession()].end()
							);
							if(!known_foreign_algo) {
								latest_rcv_ctrl_session = m->getSession();
								double timer_dur = uniform(0.001, delta);
								cout << getLogHeader() << "scheduling border-detector event, duration [" <<
								timer_dur << "]" << endl;
								border_detector_timers[m->getProtocolId()] = delayed_event(
										BORDER_DETECTOR_TIMER,
										strdup(m->getProtocolId()),
										timer_dur
								);
							}
//							cout << getLogHeader() << "node [" << m->getSender() <<
//							"] is now a candidate for being border node" << endl;
							known_border_nodes[latest_rcv_ctrl_session][m->getProtocolId()].insert(m->getSender());
						} else {
							known_ctrl_msg = true;
						}
					});
	return msg_trans_ok && !known_ctrl_msg;
}

void BroadcastingAppBase::initialize(int stage) {
	ApplicationBase::initialize(stage);
	switch (stage) {
	case INITSTAGE_LOCAL: {

		myself = this->getParentModule()->getFullName();

		// protocolId = par("protocolId").stdstringValue();

		with_hello_msgs = par("nr_hello_messages").boolValue();

		is_source = par("is_source").boolValue();

		nr_broadcast_msg = (int) par("nr_broadcast_msg").longValue();

		remote_port = par("remotePort").longValue();
		local_port = par("localPort").longValue();

		//TODO vectors related to adaptation must be part of FullyAdaptive
		signal_received_id = this->registerSignal("msg_received");
		signal_sent_id = this->registerSignal("msg_sent");
		signal_broadcast_msg_received = this->registerSignal(
				"broadcast_msg_received");
		signal_density_approximation = this->registerSignal(
				"density_approximation");
		signal_node_position_x = this->registerSignal("node_position_x");
		signal_node_position_y = this->registerSignal("node_position_y");
		signal_forward_type = this->registerSignal("forward_type");

		//TODO parameters related to adaptation must be part of FullyAdaptive too
		//initialization of adaptation parameters
		withAdaptation = par("withAdaptation").boolValue();
		hop_to_live = par("hop_to_live").longValue();
//            cout << getLogHeader()  << "adaptation" << withAdaptation << endl;
	}
		break;
	case INITSTAGE_PHYSICAL_ENVIRONMENT_2: {

		cModule* host = getContainingNode(this);

		IMobility* mobility = check_and_cast<IMobility*>(
				host->getSubmodule("mobility"));
		physicallayer::IdealTransmitter* transmitter = check_and_cast<
				physicallayer::IdealTransmitter*>(
				host->getModuleByPath(".wlan[0].radio.transmitter"));

		this->position = mobility->getCurrentPosition();
		this->radious = transmitter->getMaxCommunicationRange().get();
	}
		break;
	case INITSTAGE_LAST: {
		double deltaApprox = par("deltaApprox").doubleValue();
		double broadcastMsgTo = par("wakeUpTime").doubleValue();
		double broadcastMsgFreq = par("intervalBroadcastTime").doubleValue();
		// not the best solution because this super class doesn't know anything about
		// adaptation parameters

		double broadcastMsgTj;
		for (int i = 0; i < nr_broadcast_msg; i++) {
			broadcastMsgTj = broadcastMsgTo + i * broadcastMsgFreq;
			if (is_source) {
				delayed_event_with_strict_time(BROADCAST, "BROADCAST", broadcastMsgTj);
			}
			delayed_event_with_strict_time(APPROXIMATE_DENSITY, "APPROXIMATE_DENSITY",
					broadcastMsgTj + deltaApprox);
		}
		if (is_source) {
			cout << getLogHeader() << "first broadcast session at " << broadcastMsgTo << endl;
			delayed_event_with_strict_time(END_SIMULATION, "END_SIMULATION", broadcastMsgTj + 3.0);
		}

	}
		break;
	default:
		break;
	}
}

void BroadcastingAppBase::handleMessageWhenUp(cMessage *msg) {
	if (msg->isSelfMessage()) {
		switch (msg->getKind()) {
		case START: {
			this->processStart();
		}
			cancelAndDelete(msg);
			break;
		case SAY_HELLO:
			cout << getLogHeader() << "ERROR" << endl;
			throw std::logic_error("Unimplemented: Nobody should be calling this");
			cancelAndDelete(msg);
			break;
		case BROADCAST:
			/**
			 * the instance of <this> is a FullyAdaptive, this
			 * call will execute FullyAdaptive.time_to_broadcast_payload()
			 * instead of BroadcastingAppBase.time_to_broadcast_payload()
			 */
			this->time_to_broadcast_payload(nullptr);
			cancelAndDelete(msg);
			break;
		case BROADCAST_DELAY: {
			if (msg != nullptr) {
				void* data = msg->getContextPointer();
				this->time_to_broadcast_payload(data);
			}
			cancelAndDelete(msg);
		}
			break;
		case DISPLAY_TIME: {
			cancelAndDelete(msg);
			break;
		}
		case BORDER_DETECTOR_TIMER: {
			/* Policy to select a border node. Suggestions:
			 * - piggyback stored energy of nodes to chose that node
			 *   with the highest value as border node
			 * Currently, choosing a border node follows a first-received-first-chosen rule
			 * OPEN QUESTIONS
			 *   - how to up date this set of potential border nodes?
			 *   - mobility has an impact on this decision
			 */
			cout << getLogHeader() << "border-detector event expires " << endl;
			char* foreign_prot = (char*) msg->getContextPointer();
			bool no_border_nodes = known_border_nodes[latest_rcv_ctrl_session].find(
					foreign_prot) == known_border_nodes[latest_rcv_ctrl_session].end();
			if (no_border_nodes) {
				cerr << getLogHeader()
						<< "ERROR: set of potential border nodes is empty!!!" << endl;
			} else {
				Border* border_msg = new Border();
				border_msg->setSender(myself.c_str());
				border_msg->setSrcProtocol(protocolId.c_str());
				border_msg->setForeignProtocol(foreign_prot);
				border_msg->setHopTL(hop_to_live);
				auto set_it =
						known_border_nodes[latest_rcv_ctrl_session][foreign_prot].begin();
				advance(set_it, 0);
				string chosen_node = *set_it;
//				cout << getLogHeader() << "chosen border node [" << chosen_node.c_str()
//						<< "] from foreign protocol [" << foreign_prot << "]" << endl;
				border_msg->setChosenNode(chosen_node.c_str());
				known_foreign_algos[latest_rcv_ctrl_session].insert(foreign_prot);
				send_package(border_msg);
			}
			cancelAndDelete(msg);
		}
			break;
		case FWD_DELAYED_MSG: {
//			cout << getLogHeader() << "FWD_DELAYED_MSG, msg in queue: "
//					<< scheduled_border_msgs.size() << endl;
			if (scheduled_border_msgs.size() != 0) {
				auto iter = scheduled_border_msgs.begin();
				advance(iter, 0);
				Border* scheduled_msg = *iter;
				if (scheduled_msg != nullptr) {
					send_package(scheduled_msg);
//					cout << getLogHeader() << "now messages in queue: "
//							<< scheduled_border_msgs.size() << endl;
					scheduled_border_msgs.erase(iter);
				}
			}
			cancelAndDelete(msg);
		}
			break;
		case END_SIMULATION: {
			cout << getLogHeader() << "END OF SIMULATION" << endl;
			endSimulation();
			break;
		}
		default:
			break;
		}
	} else if (msg->getKind() == UDP_I_DATA) {
		// try to detect nodes at the border between two protocols
		if (!borderDetector(msg)) {
			/* when a border node wasn't detected, two cases are posible:
			 *  (i) <msg> is a broadcast message
			 *    1.- from same protocol
			 *    2.- from a foreign one
			 * (ii) <msg> is a ctrl message from same protocol
			 *    In this case, <msg> is treated as any ctrl message
			 */
			on_network_message_received(PK(msg));
		}
		/* when a border node was detected, <msg> is a ctrl message
		 * from a foreign protocol that souldn't be computed
		 * by this local node (even if the foreign protocol
		 * exchanges control messages too)
		 * TODO is there a way to exploit a foreing ctrl message?
		 */
		cancelAndDelete(msg);
	}

}

inet::broadcasting::Hello*
BroadcastingAppBase::build_hello_message() {
	updatePosition();
	Hello* pkt = new Hello("Hello");
	pkt->setX(position.x);
	pkt->setY(position.y);
	pkt->setSender(myself.c_str());
	return pkt;
}

/**
 * NOTE entry point of application messages (control and broadcast)
 */
void BroadcastingAppBase::on_network_message_received(cPacket* pkt) {
	// INFO received message is of type: BORDER
	if (dynamic_cast<Border *>(pkt) != nullptr) {
		Border* border_msg = dynamic_cast<Border *>(pkt);
		if (border_msg->getSender() == myself)
			return;
		bool known_protocol;
//		cout << getLogHeader() << "Border msg received from sender ["
//				<< border_msg->getSender() << "]" << endl;
//	INFO Border node received from a foreign protocol
		if (border_msg->getForeignProtocol() == protocolId) {
			// avoid forwarding indefinitely
			known_protocol = known_foreign_algos.find(latest_ctrl_session)
					!= known_foreign_algos.end()
					&& known_foreign_algos[latest_ctrl_session].find(
							border_msg->getForeignProtocol())
							!= known_foreign_algos[latest_ctrl_session].end();
			if (!known_protocol) {
				known_foreign_algos[latest_ctrl_session].insert(
						border_msg->getForeignProtocol());
				if (border_msg->getChosenNode() == myself)
					am_i_border_node[latest_ctrl_session] = true;
				else
					am_i_border_node[latest_ctrl_session] = false;

			}
//						cout << getLogHeader() << "Am I a border node? ANSW [" << am_i_border_node[latest_ctrl_session]
//					<< "]" << endl;
		}

		if (border_msg->getSrcProtocol() == protocolId) {
			known_protocol = known_foreign_algos.find(latest_rcv_ctrl_session)
					!= known_foreign_algos.end()
					&& known_foreign_algos[latest_rcv_ctrl_session].find(
							border_msg->getForeignProtocol())
							!= known_foreign_algos[latest_rcv_ctrl_session].end();
			if (!known_protocol) {
				known_foreign_algos[latest_rcv_ctrl_session].insert(
						border_msg->getForeignProtocol());
//			INFO cancel ongoing timers, which aim to chose a different border node,
//			      of protocol border_msg->getForeignProtocol()
				cMessage* ongoing_border_detector =
						border_detector_timers[border_msg->getForeignProtocol()];
				if (ongoing_border_detector != nullptr) {
//					cout << getLogHeader() << "cancel border-detector event !" << endl;
					cancelAndDelete(ongoing_border_detector);
					/* INFO remove candidates of being border nodes.
					 *     This measure is a little bit drastic because
					 *     the set could be reuse later. On the other hand,
					 *     this a way to deal with mobility.
					 */
					known_border_nodes[latest_rcv_ctrl_session][border_msg->getForeignProtocol()].clear();
				}

			}

			Border* msg_cpy = new Border();
			msg_cpy->setSender(border_msg->getSender());
			msg_cpy->setSrcProtocol(border_msg->getSrcProtocol());
			msg_cpy->setForeignProtocol(border_msg->getForeignProtocol());
			msg_cpy->setHopTL(border_msg->getHopTL() - 1);

			if (msg_cpy->getHopTL() > 0) {
//				cout << getLogHeader() << "FWD message for foreign algorithm ["
//						<< msg_cpy->getForeignProtocol() << "] hop-to-live value ["
//						<< msg_cpy->getHopTL() << "]" << endl;
				scheduled_border_msgs.insert(msg_cpy);
//				cout << getLogHeader() << "keep forwarding border message" << endl;
				delayed_event(FWD_DELAYED_MSG, "FWD_DELAYED_MSG", delta);
			}
		}
		// INFO received message is of type: CONTROL
	} else if (dynamic_cast<Hello *>(pkt) != nullptr) {
		/**
		 * the instance of <this> is a FullyAdaptive object
		 * and not an object of type BroadcastingAppBase such
		 * that the protocol in question will execute
		 * FullyAdaptive.on_hello_received() instead of
		 * BroadcastingAppBase.on_hello_received()
		 */
		this->on_hello_received(dynamic_cast<Hello *>(pkt));
		// INFO received message is of type: BROADCAST
	} else if (dynamic_cast<Broadcast *>(pkt) != nullptr){
		/**
		 * the instance of <this> is a FullyAdaptive, this
		 * call will execute FullyAdaptive.on_payload_received()
		 * instead of BroadcastingAppBase.on_payload_received()
		 */
		this->on_payload_received(dynamic_cast<Broadcast *>(pkt));
	}
	else
		cerr << getLogHeader() << "unknown message received" << endl;
}

bool BroadcastingAppBase::handleNodeStart(IDoneCallback *doneCallback) {
	delayed_event(START, "start", 0.001);
	return true;
}

Coord BroadcastingAppBase::updatePosition() {
	cModule* host = getContainingNode(this);
	IMobility* mobility = check_and_cast<IMobility*>(
			host->getSubmodule("mobility"));
	position = mobility->getCurrentPosition();
	return position;
}

double BroadcastingAppBase::get_radious() {
	return radious;
}

void BroadcastingAppBase::processStart() {
	std::string::size_type sz;
	//this delta is required to cope with collisions of control messages; even if
	//we are using CSMA it is not enough to cope with this issue
	int n = std::stoi(myself.substr(5, myself.size()), &sz);
	if (n % 100 == 0)
		delta = 0.001;
	else
		delta = (n % 100) * 0.001;
//    cerr << getLogHeader() + "Delta: " + to_string(delta) + "\n";
	L3AddressResolver().tryResolve(myself.c_str(), myAddress);

	cModule* host = getContainingNode(this);
	auto transmitter = check_and_cast<physicallayer::IdealTransmitter*>(
			host->getModuleByPath(".wlan[0].radio.transmitter"));

	updatePosition();
	this->radious = transmitter->getMaxCommunicationRange().get();

	EV_TRACE << "My position is " << this->position << "\n";

	socket.setOutputGate(gate("udpOut"));
	socket.bind(local_port);
	socket.setBroadcast(true);

	{
		cXMLElement *configs = par("protocolsConfig").xmlValue();
		if (configs) {
			cXMLElementList protocols = configs->getElementsByTagName("Protocol");
			cXMLElement *routerNode = nullptr;
			for (const auto& p : protocols) {
				const char *protocolName = xmlutils::getRequiredAttribute(*p, "name");
				cXMLElementList params = p->getElementsByTagName("Parameter");
				for (const auto& param : params) {
					const char* param_name = xmlutils::getRequiredAttribute(*param,
							"name");
					const char* param_value = xmlutils::getRequiredAttribute(*param,
							"value");
					const char* param_type = xmlutils::getRequiredAttribute(*param,
							"type");
//              cout << "Protocol: " << protocolName << ", parameter: " << param_name << ", value: " << param_value << endl;
					gateway->add_param_value_pair(protocolName, param_name, param_value);
				}
			}
		}
	}
}

void BroadcastingAppBase::configure_neighbors() {
	// print (debug)
	if (!already_configured && neighbors.size() > 0) {
		already_configured = true;
		EV_DEBUG << "Configure EDGES " << myself << " =>  \n";
		cerr << "Configure EDGES " << myself << "(" << simTime() << ")  => "
				<< endl;
		for (auto& i : neighbors) {
			EV_DEBUG << "\t" << i.second.name << " with cost " << i.second.w << "\n";
			cerr << "\t" << i.second.name << " with cost " << i.second.w << "\n";
		}
	}
}

L3Address BroadcastingAppBase::getAddr(const string& id) {
	if (myself != id) {
		L3Address addr;
		L3AddressResolver().tryResolve(id.c_str(), addr);
		return addr;
	} else
		return myAddress;
}

void BroadcastingAppBase::on_hello_received(const Hello* msg) {

	// add coordinates
	if (myself == msg->getSender())
		return;

	auto it = neighbors.find(msg->getSender());
//	cout << getLogHeader() + "HELLO MSG RECEPTION" << endl;
	if (it == neighbors.end()) {
		//EV_TRACE << " A hello from " << msg->getSender() <<  " at (" << msg->getX() << ", " << msg->getY() << ")\n";
		//cerr <<  getLogHeader() + "A hello from " << msg->getSender() <<  " at (" << msg->getX() << ", " << msg->getY() << ")\n";

		Neighbor node;
		node.name = msg->getSender();
		node.addr = getAddr(msg->getSender());
		node.pos.x = msg->getX();
		node.pos.y = msg->getY();

		node.w = (position.x - msg->getX()) * (position.x - msg->getX())
				+ (position.y - msg->getY()) * (position.y - msg->getY());

		neighbors[node.name] = node;
	}

}

void BroadcastingAppBase::on_payload_received(const Broadcast* m) {

	//EV_DEBUG << "Message received at " << simTime() << " from " << m->getSender() << "\n";
	//std::cout << myself << ": message received at " << simTime() << " from " << m->getSender() << "\n";

}

void BroadcastingAppBase::time_to_broadcast_payload(void* user_data) {
	//cout << "Time to broadcast called in " << myself << endl;
}

void BroadcastingAppBase::emitSent(string value) {
	auto idx = value.find("-");
	auto v = stoi(value.substr(idx + 1).c_str());
	emit(signal_sent_id, v);
}

void BroadcastingAppBase::emitReceived() {
	emit(signal_received_id, 1);
}

void BroadcastingAppBase::emitPowerLevel(double value) {
	emit(signal_power_level, value);
}

void BroadcastingAppBase::emitForwardTypeSignal(int s) {
	emit(signal_forward_type, s);
}

void BroadcastingAppBase::emitBroadcastMsgReceived(const string& value) {
	auto idx = value.find("-");
	auto v = stoi(value.substr(idx + 1).c_str());
	emit(signal_broadcast_msg_received, v);
}

void BroadcastingAppBase::delay_broadcast(void* user_data) {
	cMessage* mm = new cMessage("broadcast delay");
	mm->setKind(BROADCAST_DELAY);
	mm->setContextPointer(user_data);
	scheduleAt(simTime() + par("delay_test").doubleValue(), mm);
}

int BroadcastingAppBase::get_next_id_for_msg() {
	static int last_id = 0;
	return ++last_id;
}

int BroadcastingAppBase::get_last_id_for_msg() {
	throw std::runtime_error("This has been deprecated");
	return -1;
}

cMessage*
BroadcastingAppBase::delayed_broadcast(const string& key, double delay) {
	cMessage* mm = new cMessage("broadcast delay");
	mm->setContextPointer(strdup(key.c_str()));
	mm->setKind(BROADCAST_DELAY);
	scheduleAt(simTime() + delay, mm);
	return mm;
}

cMessage*
BroadcastingAppBase::delayed_event(int type, const std::string& data,
		double delay) {
	cMessage* mm = new cMessage("some delay");
	mm->setContextPointer(strdup(data.c_str()));
	mm->setKind(type);
	auto t = simTime() + delay;
//    cout << getLogHeader() << "DOING EVENT [" << type << "] after [" << t << "]s" << endl;
	scheduleAt(t, mm);
	return mm;
}

void BroadcastingAppBase::delayed_event_with_strict_time(int type,
		const std::string& data, double t) {
	cMessage* mm = new cMessage("some delay");
	mm->setContextPointer(strdup(data.c_str()));
	mm->setKind(type);
//    cout << getLogHeader() << "DOING EVENT [" << type << "] after [" << t << "]s" << endl;
	scheduleAt(SimTime(t), mm);
}

string BroadcastingAppBase::createUniqueBroadcastingSessionId() {
	return myself + "-" + to_string(get_next_id_for_msg());
}

void BroadcastingAppBase::send_package(cPacket* m, std::string dst) {
	auto addr = getAddr(dst);
	socket.sendTo(m, addr, remote_port);
}

void BroadcastingAppBase::send_package(cPacket* m) {
	L3AddressResolver resolver;
	L3Address addr = resolver.resolve("255.255.255.255",
			L3AddressResolver::ADDR_IPv4);
	socket.sendTo(m, addr, remote_port);
}

void BroadcastingAppBase::broadcast(std::string key,
		broadcasting::Broadcast* msg) {
//	cout << getLogHeader() << "BROADCASTING " << key << endl;
	msg->addByteLength(128);
	// msg->setPayload(std::string(128, 'p').c_str());
	msg->setId(key.c_str());
	msg->setSender(myself.c_str());
	msg->setProtocolId(protocolId.c_str());
	send_package(msg);
	emitSent(key);
//	cout << getLogHeader() << "BROADCASTING DONE" << key << endl;
}

} //namespace
