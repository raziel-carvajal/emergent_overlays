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

#include <algorithm>
#include <math.h>

using namespace std;
using inet::broadcasting::Broadcast;
using inet::broadcasting::Hello;

namespace inet {

string BroadcastingAppBase::getLogHeader() { return simTime().str() + " " + myself + " :: " ;}

void BroadcastingAppBase::printBroadcastingLog(std::string key) {
    string info = "";
    for (auto& n: neighbors)
        info += n.first + "_";
    cout << getLogHeader() << "BROADCASTING " << key << " TO_NEIGHBORS " << info << endl;
}

  double
  BroadcastingAppBase::computeAdaptTimeout ()
  {
    return uniform(0.1, adaptationMax);
  }

  bool
  BroadcastingAppBase::msgReceived (const broadcasting::Broadcast* m)
  {
    bool inMyMsgs = adaptMyProtoMsgs.find(m->getId()) != adaptMyProtoMsgs.end();
    bool inForMsgs = adaptForeigsMsgs.find(m->getId()) != adaptForeigsMsgs.end();
    return inMyMsgs || inForMsgs;
  }

  bool
  BroadcastingAppBase::applyMsgsTransformation (cMessage *msg, bool &fwdMsg)
  {
    bool done = withAdaptation && processMessage<Broadcast>(PK(msg), [&] (const Broadcast* m) {
    	  cerr << getLogHeader() <<  " enter 000 with Msg.protocolId: " << m->getProtocolId() << endl;
    	  if ( !msgReceived(m) ) {

    	    if (protocolId != m->getProtocolId()) {
        		double timeout = computeAdaptTimeout();
        		adaptForeigsMsgs[m->getId()] = m->getPayload();
        		cerr << getLogHeader() <<  "Setting event for: " << m->getId() << endl;
        		cerr << getLogHeader() << "Current protocol: " << protocolId << endl;
        		cerr << getLogHeader() << "Foreign protocol: " << m->getProtocolId() << endl;
        		timeoutMsgs[m->getId()] = delayed_event(
        		    ControlMessageTypes::TRANSFORMATION_TIMEOUT,
        		    m->getId(), timeout);
        	} else {
        		fwdMsg = true;
        		cerr << getLogHeader() <<  " enter 1111 with Msg.protocolId: " << m->getProtocolId() << endl;
        		adaptMyProtoMsgs[m->getId()] = m->getPayload();
    	    }
    	  } else {
    	    if (protocolId == m->getProtocolId()) {
        		if (timeoutMsgs.find(m->getId()) != timeoutMsgs.end() ){
        		    cerr << getLogHeader() <<  " enter 4444 with Msg.protocolId: " << m->getProtocolId() << endl;
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


  bool
  BroadcastingAppBase::borderDetector (cMessage* msg)
  {
    bool done = withAdaptation && processMessage<Hello>(PK(msg), [&] (const Hello* m) {
      if (m->getProtocolId() != protocolId) {
        // FIXME: doesn't work for mobility
        if (!contains(m->getProtocolId(), m->getSender())) {
          save_border_node(m->getProtocolId(), m->getSender());
          if (customOfficers[m->getProtocolId()].size() == 1) {
            timeoutBorderDet[m->getProtocolId()] =
              delayed_event(OFFICER_ELECTION_TIMEOUT,
                strdup(m->getProtocolId()),
                uniform(0.1, timeoutCustomOfficer)
              );
          }
        }
      }
    });
    return done;
  }

//Define_Module(BroadcastingAppBase);

bool
BroadcastingAppBase::contains(const std::string& protocolId, const std::string& nodeId)
{
  if (customOfficers.find(protocolId) == customOfficers.end() )
    return false;
  return customOfficers[protocolId].find(nodeId) != customOfficers[protocolId].end();
}


void
BroadcastingAppBase::save_border_node(const std::string& protocolId, const std::string& nodeId)
{
  customOfficers[protocolId].insert(nodeId);
}


BroadcastingAppBase::BroadcastingAppBase() {}

void
BroadcastingAppBase::initialize(int stage)
{
    ApplicationBase::initialize(stage);
    switch (stage) {
        case INITSTAGE_LOCAL: {

            myself = this->getParentModule()->getFullName();

            protocolId = par("protocolId").stdstringValue();

            nr_hello_msg = par("nr_hello_messages").longValue();
            is_source = par("is_source").boolValue();
            nr_broadcast_msg = par("nr_broadcast_msg").longValue();

            remote_port = par("remotePort").longValue();
            local_port = par("localPort").longValue();

            signal_received_id = this->registerSignal("msg_received");
            signal_sent_id = this->registerSignal("msg_sent");
            signal_broadcast_msg_received = this->registerSignal("broadcast_msg_received");

            //initialization of adaptation parameters
            adaptationMax = par("adaptationMax").doubleValue();
            nr_max_custom_officers = par("nr_max_custom_officers").longValue();
            timeoutCustomOfficer = par("timeoutCustomOfficer").doubleValue();
            withAdaptation = par("withAdaptation").boolValue();
        }
            break;
        case INITSTAGE_PHYSICAL_ENVIRONMENT_2:
            {

                cModule* host = getContainingNode(this);

                IMobility* mobility = check_and_cast<IMobility*>(host->getSubmodule("mobility"));
                physicallayer::IdealTransmitter* transmitter = check_and_cast<physicallayer::IdealTransmitter*>(host->getModuleByPath(".wlan[0].radio.transmitter"));

                this->position = mobility->getCurrentPosition();
                this->radious = transmitter->getMaxCommunicationRange().get();

                EV_TRACE << "My position is " << this->position  << "\n";

                //   cout << getLogHeader() << " " << atoi(tokenizer.nextToken()) << endl;

            }
            break;
        case INITSTAGE_LAST:{

            double d = par("wakeUpTime").doubleValue();
            // DON'T REMOVE THIS THREE LINES. IT IS IMPORTANT TO GUARANTEE A PROPER MEASUREMENT
            d += nr_broadcast_msg * par("intervalBroadcastTime").doubleValue();
            d += 3; // some extra seconds
            delayed_event_with_strict_time(LAST_POWER_REPORT, "last power report", d - 0.5);
            // ==========================================================================

            d = par("wakeUpTime").doubleValue();
            delayed_event(PRINT_POS_NEIGS, "PrintingPosition&Neighbors", d - 0.2);

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
              // delayed_event(WAKEUP, "intervalBroadcastTime", d);
              cout << getLogHeader() << "Broadcasting sessions will star at " << (d) << endl;
              for (int i = 0 ; i < nr_broadcast_msg; i++)
                msgs.insert(i);
            }

            if (msgs.size() > 0) {
              is_source = true;
              next_to_send = msgs.begin();
              int idx = *next_to_send;
              cout << getLogHeader() << "Scheduling broadcast at time: " << d + idx*par("intervalBroadcastTime").doubleValue() << endl;
              delayed_event_with_strict_time(WAKEUP, "intervalBroadcastTime", d + idx*par("intervalBroadcastTime").doubleValue());
            }

        }
        break;
        default:
            break;
    }
}


void
BroadcastingAppBase::handleMessageWhenUp(cMessage *msg)
{
    cout << getLogHeader() << "Message: " <<  msg->getKind() << endl;
    if (msg->isSelfMessage()) {
        switch (msg->getKind()) {
            case START: {
                  this->processStart();
                }
                cancelAndDelete(msg);
                break;
            case SAY_HELLO:{
                auto pkt = build_hello_message();
                updatePosition();
                pkt->setX(position.x);
                pkt->setY(position.y);
                pkt->setSender(myself.c_str());
                pkt->setProtocolId (protocolId.c_str());
                send_package(pkt);
                if (this->nr_hello_msg > 0)
                	delayed_event(SAY_HELLO, "helloTime", par("helloTime").doubleValue());
                // this->nr_hello_msg--;
                cancelAndDelete(msg);
                break;
                }
            case WAKEUP:
                //configure_neighbors();
                cout << getLogHeader() << "WAKEUP" << endl;
                cancelAndDelete(msg);
                cout << getLogHeader() << "broadcasting" << endl;
                this->time_to_broadcast_payload(nullptr);
                next_to_send++;
                if (next_to_send != msgs.end()) {
                  int idx = *next_to_send;
                  double d = par("wakeUpTime").doubleValue();
                  delayed_event_with_strict_time(WAKEUP, "intervalBroadcastTime", d + idx*par("intervalBroadcastTime").doubleValue());
                }

                break;
            case BROADCAST_DELAY:
                {
                    void* data = msg->getContextPointer();
                    this->time_to_broadcast_payload(data);
                    cancelAndDelete(msg);
                    break;
                }
            case DISPLAY_TIME:
                {
                    cancelAndDelete(msg);
                    break;
                }
            case LAST_POWER_REPORT:
                {
                  Hello* pkt = new Hello("Hello");
                  pkt->setX(position.x);
                  pkt->setY(position.y);
                  pkt->setSender(myself.c_str());
                  send_package(pkt);
	                cancelAndDelete(msg);

                  auto d =  par("wakeUpTime").doubleValue() + nr_broadcast_msg * par("intervalBroadcastTime").doubleValue() + 5;//some extra seconds

                  delayed_event_with_strict_time(HALT_SIMULATION_DELAY, "halt simulation", d);
                }
		            break;
            case HALT_SIMULATION_DELAY:
              cancelAndDelete(msg);
            	endSimulation();
            	break;
            case PRINT_POS_NEIGS:{
                // if (nr_broadcast_msg > 0) {
                //     cout << getLogHeader() + "TIC " + to_string((int)nr_broadcast_msg) + " POSITION " +
                //             to_string(position.x) + " " + to_string(position.y) << endl;
                //     auto p  = par("intervalBroadcastTime").doubleValue() / 5;
                //     delayed_event(PRINT_POS_NEIGS, "PrintingPosition&Neighbors",  par("intervalBroadcastTime").doubleValue() - p);
                // }

            }
            break;
            case TRANSFORMATION_TIMEOUT: {
              void* data = msg->getContextPointer();
              std::string key = string( (char*)data );
              cerr << getLogHeader()  << "Doing event for key: " << key << endl;
      	      this->time_to_broadcast_payload(data);
      	      timeoutMsgs.erase(key);
      	      cancelAndDelete(msg);
            }
            break;
            case OFFICER_ELECTION_TIMEOUT: {
              cout << getLogHeader() << "officer election timeout: " <<  endl;
              char* foreign_prot = (char*)msg->getContextPointer();
              if (customOfficers.find(foreign_prot) == customOfficers.end())
                  cout << getLogHeader() << "NOT IN MAP" << endl;
              broadcasting::TargetSet targets;
              cout << getLogHeader() << "foreing prot: " << foreign_prot <<  endl;
              for (const auto& e: customOfficers[foreign_prot]) {
                targets.insert(e);
                if (targets.size() == nr_max_custom_officers)
                  break;
              }
              cout << getLogHeader() << "AFTER LOOP " <<  endl;
//              if (!std::equal(customOfficers[foreign_prot].begin(),
//                              customOfficers[foreign_prot].end(),
//                              lastForeignHelloSenders.begin()
//                            )) {
//                cout << getLogHeader() << "IN CONDITION " <<  endl;
//                auto tmp = new broadcasting::Border();
//                tmp->setSourceProtocol(protocolId.c_str());
//                tmp->setForeignProtocol(foreign_prot);
//                tmp->setTargets(targets);
//                send_package(tmp);
//                timeoutBorderDet.erase(foreign_prot);
//                lastForeignHelloSenders = customOfficers[foreign_prot];
//                customOfficers[foreign_prot].clear();
//
//                cout << getLogHeader() << "BEFORE " <<  endl;
//                free(foreign_prot);
//                cancelAndDelete(msg);
//                cout << getLogHeader() << "AFTER" <<  endl;
//              }
              cout << getLogHeader() << "END OF OFFICIER ELECTION TIMEMOU" <<  endl;
            }
            break;
            default:
            break;
        }
    }
    else if (msg->getKind() == UDP_I_DATA) {
        cout << getLogHeader() << "officer election with UDP_I_DATA " <<  endl;
    	bool fwdMsg = false;
    	bool done = applyMsgsTransformation (msg, fwdMsg);
    	borderDetector(msg);
    	if (!done || fwdMsg) {
    	  on_network_message_received(PK(msg));
    	}
    	delete msg;
    }

}

inet::broadcasting::Hello*
BroadcastingAppBase::build_hello_message() {
  return new Hello("Hello");
}

bool
BroadcastingAppBase::on_network_message_received(cPacket* pkt)
{

  bool done = processMessage<Hello>(pkt, [&] (const Hello* m) {
		this-> on_hello_received(m);
	});

  done = done || processMessage<Broadcast>(pkt, [&] (const Broadcast* m) {
    this->on_payload_received(m);
  });

  done = done || processMessage<broadcasting::Border>(pkt, [&] (const broadcasting::Border* m) {
  	if (m->getSourceProtocol() != protocolId) {
      if (m->getTargets().find(myself) != m->getTargets().end()) {
        amIbridge = true;
      }
  	}
    else {
      // if I have a time out for the same foreign protocol
      string key(m->getForeignProtocol());
      if (timeoutBorderDet.find(key) != timeoutBorderDet.end()) {
        auto mm = timeoutBorderDet[key];
        cancelAndDelete(mm);
        timeoutBorderDet.erase(key);
      }
    }
  });

  return done;
}


bool
BroadcastingAppBase::handleNodeStart(IDoneCallback *doneCallback)
{
    delayed_event(START, "start",  0.001);
    return true;
}


void
BroadcastingAppBase::updatePosition()
{
  cModule* host = getContainingNode(this);
  IMobility* mobility = check_and_cast<IMobility*>(host->getSubmodule("mobility"));
  position = mobility->getCurrentPosition();
}

void
BroadcastingAppBase::processStart()
{

    std::string::size_type sz;
    //this delta is required to cope with collisions of control messages; even if
    //we are using CSMA it is not enough to cope with this issue
    int n = std::stoi (myself.substr(5, myself.size()), &sz);
    if (n % 50 == 0)
        delta = 0.003;
    else
        delta = (n % 50) * 0.002;
//    cerr << getLogHeader() + "Delta: " + to_string(delta) + "\n";
    L3AddressResolver().tryResolve(myself.c_str(), myAddress);

    cModule* host = getContainingNode(this);
    auto transmitter = check_and_cast<physicallayer::IdealTransmitter*>(host->getModuleByPath(".wlan[0].radio.transmitter"));

    updatePosition();
    this->radious = transmitter->getMaxCommunicationRange().get();

    EV_TRACE << "My position is " << this->position  << "\n";
    // cerr << " My position is " << this->position << " " << myself  << endl;

    socket.setOutputGate(gate("udpOut"));
    socket.bind(local_port);
    socket.setBroadcast(true);

    log_status_for_animation("STANDING");
    if (nr_hello_msg > 0)
        delayed_event(SAY_HELLO, "helloTime", par("helloTime").doubleValue() + delta);
}


void
BroadcastingAppBase::configure_neighbors()
{
    // print (debug)
    if (!already_configured && neighbors.size() > 0) {
        already_configured = true;
        EV_DEBUG << "Configure EDGES " << myself << " =>  \n";
        cerr << "Configure EDGES " << myself << "(" << simTime() << ")  => " << endl;
        for (auto& i : neighbors) {
            EV_DEBUG << "\t" << i.second.name  << " with cost " << i.second.w << "\n";
            cerr << "\t" << i.second.name  << " with cost " << i.second.w << "\n";
        }
    }
}


L3Address
BroadcastingAppBase::getAddr(string id)
{
    if (myself != id) {
        L3Address addr;
        L3AddressResolver().tryResolve(id.c_str(), addr);
        return addr;
    }
    else return myAddress;
}


void
BroadcastingAppBase::on_hello_received(const Hello* msg)
{

    // add coordinates
    auto it = neighbors.find(msg->getSender());
	  if (myself == msg->getSender())
			return;

//	cout << getLogHeader() + "HELLO MSG RECEPTION" << endl;
    if (it == neighbors.end()) {
        //EV_TRACE << " A hello from " << msg->getSender() <<  " at (" << msg->getX() << ", " << msg->getY() << ")\n";
        //cerr <<  getLogHeader() + "A hello from " << msg->getSender() <<  " at (" << msg->getX() << ", " << msg->getY() << ")\n";

        Neighbor node;
        node.name = msg->getSender();
        node.addr = getAddr(msg->getSender());
        node.pos.x = msg->getX();
        node.pos.y = msg->getY();

        node.w = (position.x - msg->getX())*(position.x - msg->getX())
                                + (position.y - msg->getY())*(position.y - msg->getY());

        neighbors[node.name] = node;
    }

}

void
BroadcastingAppBase::on_payload_received(const Broadcast* m)
{


    //EV_DEBUG << "Message received at " << simTime() << " from " << m->getSender() << "\n";
    //std::cout << myself << ": message received at " << simTime() << " from " << m->getSender() << "\n";

}


void
BroadcastingAppBase::time_to_broadcast_payload(void* user_data)
{
    //cout << "Time to broadcast called in " << myself << endl;
}


void
BroadcastingAppBase::emitSent(string value)
{
  auto idx = value.find("-");
  auto v = stoi(value.substr(idx+1).c_str());
  emit(signal_sent_id, v);
}


void
BroadcastingAppBase::emitReceived()
{
    emit(signal_received_id, 1);
}


void
BroadcastingAppBase::emitPowerLevel(double value)
{
    emit(signal_power_level, value);
}


void
BroadcastingAppBase::emitBroadcastMsgReceived(string value)
{
  auto idx = value.find("-");
  auto v = stoi(value.substr(idx+1).c_str());
  emit(signal_broadcast_msg_received, v);
}


void
BroadcastingAppBase::delay_broadcast(void* user_data) {
    cMessage* mm = new cMessage("broadcast delay");
    mm->setKind(BROADCAST_DELAY);
    mm->setContextPointer(user_data);
    scheduleAt(simTime() + par("delay_test").doubleValue(), mm);
}


int
BroadcastingAppBase::get_next_id_for_msg()
{
  static int last_id = 0;
  return ++last_id;
}


int
BroadcastingAppBase::get_last_id_for_msg()
{
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
BroadcastingAppBase::delayed_event(int type, const std::string& data, double delay)
{
    cMessage* mm = new cMessage("some delay");
    mm->setContextPointer(strdup(data.c_str()));
    mm->setKind(type);
    scheduleAt(simTime() + delay, mm);
    return mm;
}


void
BroadcastingAppBase::delayed_event_with_strict_time(int type, const std::string& data, double t)
{
    cMessage* mm = new cMessage("some delay");
    mm->setContextPointer(strdup(data.c_str()));
    mm->setKind(type);
    scheduleAt(SimTime(t), mm);
}




string
BroadcastingAppBase::createUniqueBroadcastingSessionId()
{
    return myself + "-" + to_string(get_next_id_for_msg());
}


void
BroadcastingAppBase::send_package(cPacket* m, std::string dst)
{
  auto addr = getAddr(dst);
  socket.sendTo(m, addr, remote_port);
}


void
BroadcastingAppBase::send_package(cPacket* m)
{
  //send_package(m, "255.255.255.255");
  L3AddressResolver resolver;
  L3Address addr = resolver.resolve("255.255.255.255", L3AddressResolver::ADDR_IPv4);
  socket.sendTo(m, addr, remote_port);
}

void
BroadcastingAppBase::broadcast(std::string key, broadcasting::Broadcast* msg)
{
    //printBroadcastingLog(key);
    L3AddressResolver resolver;
    L3Address addr = resolver.resolve("255.255.255.255", L3AddressResolver::ADDR_IPv4);
    msg->setPayload(key.c_str());
    msg->setId(key.c_str());
    msg->setSender(myself.c_str());
    if (withAdaptation) {
        msg->setProtocolId(protocolId.c_str());
    }
    cout << getLogHeader() << "broadcasting key: " << key << endl;
    socket.sendTo(msg, addr, remote_port);
    emitSent(key);
}


void
BroadcastingAppBase::log_status_for_animation(std::string status)
{
    // cerr << "<=====>," << myself << "," << simTime() << "," << position.x << "," << position.y << "," << status << endl;
}

} //namespace
