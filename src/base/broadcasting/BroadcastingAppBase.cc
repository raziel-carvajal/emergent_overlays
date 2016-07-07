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

using namespace std;
using inet::broadcasting::Broadcast;
using inet::broadcasting::FloodingMessage;
using inet::broadcasting::Hello;

namespace inet {

//Define_Module(BroadcastingAppBase);


BroadcastingAppBase::BroadcastingAppBase()
{
}

void
BroadcastingAppBase::initialize(int stage)
{
    ApplicationBase::initialize(stage);

    switch (stage) {
        case INITSTAGE_LOCAL:

            nr_hello_msg = par("nr_hello_messages").longValue();
            is_source = par("is_source").boolValue();
            nr_broadcast_msg = par("nr_broadcast_msg").longValue();

            remote_port = par("remotePort").longValue();
            local_port = par("localPort").longValue();

            ctrlMsg0 = new cMessage("controlMSG", IDLE);

            signal_received_id = this->registerSignal("msg_received");
            signal_sent_id = this->registerSignal("msg_sent");
            signal_power_level = this->registerSignal("power_level");
            signal_broadcast_msg_received = this->registerSignal("broadcast_msg_received");
            {
                cModule *hostModule = getParentModule();
                cerr << "host name : " << hostModule->getName() << endl;
                hostModule->subscribe(inet::power::IEnergyStorage::residualCapacityChangedSignal, this);
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
            }
            break;
        case INITSTAGE_LAST:

            if (is_source && nr_broadcast_msg > 0) {
                cMessage* ctrlWakeup = new cMessage("controlMSG", WAKEUP);
                ctrlWakeup->setKind( WAKEUP);
                double d = par("wakeUpTime").doubleValue();
                cerr << "Broadcasting sessions will star at " << (d) << endl;
                scheduleAt(d, ctrlWakeup);
            }

            break;
        default:
            break;
    }
}


void
BroadcastingAppBase::handleMessageWhenUp(cMessage *msg)
{

    if (msg->isSelfMessage()) {

        switch (msg->getKind()) {
            case START: {
                this->processStart();
                }
                break;
            case SAY_HELLO:
                {
                    L3AddressResolver resolver;
                    L3Address addr = resolver.resolve("255.255.255.255", L3AddressResolver::ADDR_IPv4);
                    {
                        Hello* pkt = new Hello("Hello");
                        pkt->setX(position.x);
                        pkt->setY(position.y);
                        pkt->setSender(myself.c_str());
                        socket.sendTo(pkt, addr, remote_port);
                    }
                }
                this->nr_hello_msg--;
                if (this->nr_hello_msg) {
                    ctrlMsg0->setKind(SAY_HELLO);
                    scheduleAt(simTime() + par("helloTime").doubleValue(),  ctrlMsg0);
                }
                break;
            case WAKEUP:
                configure_neighbors();
                cancelAndDelete(msg);
                if (is_source) {
                  this->time_to_broadcast_payload(nullptr);
                }
                if (is_source && nr_broadcast_msg > 0) {
                  nr_broadcast_msg--;
                  cMessage* ctrlWakeup = new cMessage("controlMSG", WAKEUP);
                  ctrlWakeup->setKind( WAKEUP);
                  scheduleAt(simTime() + par("intervalBroadcastTime").doubleValue(), ctrlWakeup);
                }
                break;
            case BROADCAST_DELAY:
                {
                    void* data = msg->getContextPointer();
                    this->time_to_broadcast_payload(data);
                    cancelAndDelete(msg);
                }
                break;
            case FLOODING_DELAY:
                {
                    L3AddressResolver resolver;
                    L3Address addr = resolver.resolve("255.255.255.255", L3AddressResolver::ADDR_IPv4);
                    FloodingMessage* m = new FloodingMessage("a flooding");
                    m->setSender(myself.c_str());
                    string key = string((char*)msg->getContextPointer());
                    m->setId(key.c_str());
                    m->setPayload(payload_in_flooding[key].c_str());
                    socket.sendTo(m, addr, remote_port);
                }
            case DISPLAY_TIME:
                {
                    cancelAndDelete(msg);
                }
                break;
//            case TEST_DELAY:
//                {
//                    cancelAndDelete(msg);
//                }
                break;
            default:
                break;
        }
    }
    else if (msg->getKind() == UDP_I_DATA) {
        bool done = on_network_message_received(PK(msg));
        delete msg;
    }

}


void
BroadcastingAppBase::receiveSignal(cComponent *source, simsignal_t signalID, double value)
{
    if (signalID == inet::power::IEnergyStorage::residualCapacityChangedSignal) {
        emitPowerLevel(value);
    }

}


bool
BroadcastingAppBase::on_network_message_received(cPacket* pkt)
{

    bool done = processMessage<Hello>(pkt, &BroadcastingAppBase::on_hello_received);

    if (!done) {
        done = processMessage<Broadcast>(pkt, &BroadcastingAppBase::on_payload_received) ||
               processMessage<FloodingMessage>(pkt, &BroadcastingAppBase::on_flooding_received);
    }

    return done;
}



void
BroadcastingAppBase::finish()
{
    if (ctrlMsg0)
        cancelAndDelete(ctrlMsg0);
    ctrlMsg0 = nullptr;
}

bool
BroadcastingAppBase::handleNodeStart(IDoneCallback *doneCallback)
{
    ctrlMsg0->setKind(START);
    scheduleAt(simTime() + 0.001, ctrlMsg0);
    return true;
}

bool
BroadcastingAppBase::handleNodeShutdown(IDoneCallback *doneCallback)
{
    if (ctrlMsg0)
        cancelAndDelete(ctrlMsg0);
    ctrlMsg0 = nullptr;

    return true;
}

void
BroadcastingAppBase::handleNodeCrash()
{
    if (ctrlMsg0)
        cancelAndDelete(ctrlMsg0);
    ctrlMsg0 = nullptr;
}

void
BroadcastingAppBase::processStart()
{
    myself = this->getParentModule()->getFullName();
    L3AddressResolver().tryResolve(myself.c_str(), myAddress);

    socket.setOutputGate(gate("udpOut"));
    socket.bind(local_port);
    socket.setBroadcast(true);

    if (nr_hello_msg > 0) {
        ctrlMsg0->setKind(SAY_HELLO);
        scheduleAt(simTime() + par("helloTime").doubleValue(),  ctrlMsg0);
    }
}


template <typename T> bool
BroadcastingAppBase::processMessage(cPacket* pkt, void (BroadcastingAppBase::*action)(const T* msg))
{
    T* t = check_and_cast_nullable<T*>(dynamic_cast<T*>(pkt));
    if (t != nullptr) {
        (this->*action)(t);
        return true;
    }
    else {
        return false;
    }
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
    if (it == neighbors.end()) {
        EV_TRACE << " A hello from " << msg->getSender() <<  " at (" << msg->getX() << ", " << msg->getY() << ")\n";

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
BroadcastingAppBase::on_flooding_received(const FloodingMessage* m)
{
    string key = m->getId();
    string p = m->getPayload();
    if (payload_in_flooding.find(key) == payload_in_flooding.end()) {
        payload_in_flooding[key] = p;
        delayed_event(ControlMessageTypes::FLOODING_DELAY, key, 0.05);
    }
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
    return ++last_id;
}


int
BroadcastingAppBase::get_last_id_for_msg()
{
    return last_id;
}


void BroadcastingAppBase::delayed_broadcast(const string& key, double delay) {
    cMessage* mm = new cMessage("broadcast delay");
    mm->setContextPointer(strdup(key.c_str()));
    mm->setKind(BROADCAST_DELAY);
    scheduleAt(simTime() + delay, mm);
}


void
BroadcastingAppBase::delayed_event(int type, const std::string& data, double delay)
{
    cMessage* mm = new cMessage("some delay");
    mm->setContextPointer(strdup(data.c_str()));
    mm->setKind(type);
    scheduleAt(simTime() + delay, mm);
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
  send_package(m, "255.255.255.255");
}



} //namespace
