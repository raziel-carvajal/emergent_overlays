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
	app->cancelAndDelete(m);
}

bool BroadcastingAppBase::OmnetBroadcastGateway::bridge() {
	return app->amIbridge;
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

void BroadcastingAppBase::printBroadcastingLog(std::string key) {
	string info = "";
	for (auto& n : neighbors)
		info += n.first + "_";
	// cout << getLogHeader() << "BROADCASTING " << key << " TO_NEIGHBORS " << info << endl;
}

BroadcastingAppBase::BroadcastingAppBase() {
	gateway = std::make_shared<OmnetBroadcastGateway>(this);
}

double BroadcastingAppBase::computeAdaptTimeout() {
	return uniform(adaptationMin, adaptationMax);
}

bool BroadcastingAppBase::msgReceived(const broadcasting::Broadcast* m) {
	bool inMyMsgs = adaptMyProtoMsgs.find(m->getId()) != adaptMyProtoMsgs.end();
	bool inForMsgs = adaptForeigsMsgs.find(m->getId()) != adaptForeigsMsgs.end();
	return inMyMsgs || inForMsgs;
}

// XXX given that border nodes are labed thanks to control protocols, this method is useless!
bool BroadcastingAppBase::applyMsgsTransformation(cMessage *msg, bool &fwdMsg) {
	bool done =
			withAdaptation
					&& processMessage<Broadcast>(PK(msg), [&] (const Broadcast* m) {
//    	  cout << getLogHeader() << "Sender of broadcast [1]: " << m->getSender() << endl;
							if ( !msgReceived(m) ){
								fwdMsg = true;
								if (protocolId != m->getProtocolId())
								{
									double timeout = computeAdaptTimeout();
									adaptForeigsMsgs[m->getId()] = m->getPayload();
									timeoutMsgs[m->getId()] = delayed_event(TRANSFORMATION_TIMEOUT, m->getId(), timeout);
								}
								else
								{
									fwdMsg = true;
									adaptMyProtoMsgs[m->getId()] = m->getPayload();
								}
							}
							else
							{
								if (protocolId == m->getProtocolId())
								{
									if (timeoutMsgs.find(m->getId()) != timeoutMsgs.end() )
									{
										auto tmp = timeoutMsgs[m->getId()];
										cancelAndDelete(tmp);
										timeoutMsgs.erase(m->getId());
									}
									fwdMsg = true;
								}
							}
						});
	return done;
}

bool BroadcastingAppBase::borderDetector(cMessage* msg) {
	bool known_ctrl_msg = false;
	bool msg_trans_ok = withAdaptation &&
			processMessage<Hello>(PK(msg), [&] (const Hello* m) {
				if (m->getProtocolId() != protocolId) {
					if ( in_border_nodes(m->getProtocolId()) ){
						nodes_at_border[m->getProtocolId()].insert(m->getSender());
					} else {
						border_detector_timers[m->getProtocolId()] =
							delayed_event(
								BORDER_DETECTOR_TIMER,
								strdup(m->getProtocolId()),
								uniform(0.1, border_detector_max_timeout)
							);
					}
				} else {
					known_ctrl_msg = true;
				}
			});
	return msg_trans_ok && !known_ctrl_msg;
}

//Define_Module(BroadcastingAppBase);

bool BroadcastingAppBase::in_border_nodes(const std::string& protocolId) {
	if (nodes_at_border.size() == 0 || nodes_at_border.find(protocolId) == nodes_at_border.end())
		return false;
	return true;
}

void BroadcastingAppBase::initialize(int stage) {
	ApplicationBase::initialize(stage);
	switch (stage) {
	case INITSTAGE_LOCAL: {

		myself = this->getParentModule()->getFullName();

		// protocolId = par("protocolId").stdstringValue();

		with_hello_msgs = par("nr_hello_messages").boolValue();

		is_source = par("is_source").boolValue();

		nr_broadcast_msg = par("nr_broadcast_msg").longValue();

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

		//TODO parameters related to adaptation must be part of FullyAdaptive too
		//initialization of adaptation parameters
		adaptationMax = par("adaptationMax").doubleValue();
		adaptationMin = par("adaptationMin").doubleValue();
		nr_max_custom_officers = par("nr_max_custom_officers").longValue();
		border_detector_max_timeout = par("border_detector_max_timeout").doubleValue();
		withAdaptation = par("withAdaptation").boolValue();
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
		double d = par("wakeUpTime").doubleValue();
		// DON'T REMOVE THIS THREE LINES. IT IS IMPORTANT TO GUARANTEE A PROPER MEASUREMENT
		d += nr_broadcast_msg * par("intervalBroadcastTime").doubleValue();
		d += 3; // some extra seconds
		delayed_event_with_strict_time(LAST_POWER_REPORT, "last power report",
				d - 0.5);
		// ==========================================================================
		d = par("wakeUpTime").doubleValue();
		// not the best solution because this super class doesn't know anything about
		// adaptation parameters
		delayed_event(APPROXIMATE_DENSITY, "approximation of nodes density",
				d + par("deltaApprox").doubleValue());

		if (!par("single_source").boolValue()) {
			cModule* host = getContainingNode(this);
			const char* s = host->par("id_messages_to_send");
			cStringTokenizer tokenizer(s);
			while (tokenizer.hasMoreTokens()) {
				int idx = atoi(tokenizer.nextToken());
				if (idx <= nr_broadcast_msg) {
					idx = idx - 1;
					msgs.insert(idx);
				}
			}
		}

		if (is_source) {
			msgs.clear();
			cout << getLogHeader() << "Broadcasting sessions will star at " << (d)
					<< endl;
			for (int i = 0; i < nr_broadcast_msg; i++)
				msgs.insert(i);
		}

		if (msgs.size() > 0) {
			is_source = true;
			next_to_send = msgs.begin();
			int idx = *next_to_send;
			cout << getLogHeader() << "Scheduling broadcast at time: "
					<< d + idx * par("intervalBroadcastTime").doubleValue() << endl;
			delayed_event_with_strict_time(WAKEUP, "intervalBroadcastTime",
					d + idx * par("intervalBroadcastTime").doubleValue());
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
			throw std::logic_error("Unimplemented: Nobody should be calling this");
			cancelAndDelete(msg);
			break;
		case WAKEUP:
			/**
			 * the instance of <this> is a FullyAdaptive, this
			 * call will execute FullyAdaptive.time_to_broadcast_payload()
			 * instead of BroadcastingAppBase.time_to_broadcast_payload()
			 */
			this->time_to_broadcast_payload(nullptr);
			next_to_send++;
			if (next_to_send != msgs.end()) {
				int idx = *next_to_send;
				double d = par("wakeUpTime").doubleValue();
				delayed_event_with_strict_time(WAKEUP, "intervalBroadcastTime",
						d + idx * par("intervalBroadcastTime").doubleValue());
			}
			cancelAndDelete(msg);

			break;
		case BROADCAST_DELAY: {
			void* data = msg->getContextPointer();
			this->time_to_broadcast_payload(data);
			cancelAndDelete(msg);
		}
			break;
		case DISPLAY_TIME: {
			cancelAndDelete(msg);
			break;
		}
		case LAST_POWER_REPORT: {
			Hello* pkt = build_hello_message();
			send_package(pkt);

			auto d = par("wakeUpTime").doubleValue()
					+ nr_broadcast_msg * par("intervalBroadcastTime").doubleValue() + 5; //some extra seconds
			delayed_event_with_strict_time(HALT_SIMULATION_DELAY, "halt simulation",
					d);
			cancelAndDelete(msg);
		}
			break;
		case HALT_SIMULATION_DELAY:
			cancelAndDelete(msg);
			endSimulation();
			break;
		case TRANSFORMATION_TIMEOUT: {
			void* data = msg->getContextPointer();
			std::string key = string((char*) data);
			cerr << getLogHeader() << "Doing event for key: " << key << endl;
			this->time_to_broadcast_payload(data);
			timeoutMsgs.erase(key);
			cancelAndDelete(msg);
		}
			break;
		case BORDER_DETECTOR_TIMER: {
//              if (!use_topology_fix) throw std::logic_error("Shouldn't call this if we are not fixing the issue with topology-based algorithms");
			char* foreign_prot = (char*) msg->getContextPointer();
			// if (nodes_at_border.find(foreign_prot) == nodes_at_border.end())
			// cout << getLogHeader() << "NOT IN MAP" << endl;
			broadcasting::TargetSet targets;
			// cout << getLogHeader() << "foreing prot: " << foreign_prot <<  endl;
			for (const auto& e : nodes_at_border[foreign_prot]) {
				targets.insert(e);
				if (targets.size() == nr_max_custom_officers)
					break;
			}
			// cout << getLogHeader() << "AFTER LOOP " <<  endl;
//			if (nodes_at_border[foreign_prot].size() != lastForeignHelloSenders.size()
//					|| !std::equal(nodes_at_border[foreign_prot].begin(),
//							customOfficers[foreign_prot].end(),
//							lastForeignHelloSenders.begin())) {
//				//  cout << getLogHeader() << "IN CONDITION " <<  endl;
//				auto tmp = new broadcasting::Border();
//				tmp->setSourceProtocol(protocolId.c_str());
//				tmp->setForeignProtocol(foreign_prot);
//				tmp->setTargets(targets);
//				send_package(tmp);
//				border_detector_timers.erase(foreign_prot);
//				lastForeignHelloSenders = nodes_at_border[foreign_prot];
//				nodes_at_border[foreign_prot].clear();
//
//				//  cout << getLogHeader() << "BEFORE " <<  endl;
//				free(foreign_prot);
//				cancelAndDelete(msg);
//				//  cout << getLogHeader() << "AFTER" <<  endl;
//			}
			//  cout << getLogHeader() << "END OF OFFICIER ELECTION TIMEMOU" <<  endl;
		}
			break;
		default:
			break;
		}
	} else if (msg->getKind() == UDP_I_DATA) {
		// try to detect nodes at the border between two protocols
		if (!borderDetector(msg)){
			/* two situations when a border node wasn't detected:
			 *  (i) <msg> is a broadcast message
			 *    1.- from same protocol
			 *    2.- from a foreign one
			 * (ii) <msg> is a ctrl message from same protocol
			 *    In this case, <msg> must treat as any ctrl message
			 */
			on_network_message_received(PK(msg));
		}
		/* when a border node was detected, msg is a ctrl message
		 * from a foreign protocol that souldn't be computed
		 * by this local node (even if the foreign protocol
		 * exchanges control messages too)
		 */
//		done = applyMsgsTransformation(msg, fwdMsg);
		delete msg;
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

bool BroadcastingAppBase::on_network_message_received(cPacket* pkt) {
	/**
	 * NOTE entry point of application messages (control and broadcast)
	 */
	bool done = processMessage<Hello>(pkt, [&] (const Hello* m)
	{
		/**
		 * the instance of <this> is a FullyAdaptive object
		 * and not an object of type BroadcastingAppBase such
		 * that the protocol in question will execute
		 * FullyAdaptive.on_hello_received() instead of
		 * BroadcastingAppBase.on_hello_received()
		 */
		this-> on_hello_received(m);
	});

	done = done || processMessage<Broadcast>(pkt, [&] (const Broadcast* m)
	{
//    cout << getLogHeader() << "Handling message: " << m->getSender() << endl;
			this->on_payload_received(m);
		});

	done = done
			|| processMessage<broadcasting::Border>(pkt,
					[&] (const broadcasting::Border* m)
					{
						if (m->getSourceProtocol() != protocolId)
						{
							if (m->getTargets().find(myself) != m->getTargets().end())
							{
								amIbridge = true;
							}
						}
						else
						{
							// if I have a time out for the same foreign protocol
							string key(m->getForeignProtocol());
							if (border_detector_timers.find(key) != border_detector_timers.end())
							{
								auto mm = border_detector_timers[key];
								cancelAndDelete(mm);
								border_detector_timers.erase(key);
							}
						}
					});

	return done;
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
	// cout << getLogHeader() << "BROADCASTING " << key << endl;
	printBroadcastingLog(key);
	msg->addByteLength(128);
	// msg->setPayload(std::string(128, 'p').c_str());
	msg->setId(key.c_str());
	msg->setSender(myself.c_str());
	if (withAdaptation) {
		msg->setProtocolId(protocolId.c_str());
	}
	send_package(msg);
	emitSent(key);
}

} //namespace
