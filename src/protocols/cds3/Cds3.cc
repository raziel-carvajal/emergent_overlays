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
#include <cds3/Cds3.h>
namespace inet {

Define_Module(Cds_3);

void inet::Cds_3::on_payload_received(const broadcasting::Broadcast* m) {
    std::string key = string(m->getPayload());
    emitBroadcastMsgReceived(key);
    if (amIrelay && alreadyDispatched.find(key) == alreadyDispatched.end()) {
        broadcast(key, new broadcasting::Broadcast("payload"));
        alreadyDispatched[key] = key;
    }
}

void inet::Cds_3::time_to_broadcast_payload(void* user_data) {
    string key = is_source ? myself + "-" + to_string(get_next_id_for_msg()) : string((char*)user_data);
    if (is_source) {
        /* XXX why the source have to say "I received a broadcast message..." ?
        *      isn't just for non source nodes?
        */
        cerr << key + " this is the payload, initially sent from " + myself + "\n";
        emitBroadcastMsgReceived(key);
    }
    if (is_source || (amIrelay && alreadyDispatched.find(key) == alreadyDispatched.end())) {
        alreadyDispatched[key] = key;
        broadcast(key, new broadcasting::Broadcast("payload"));
        emitSent(key);
    }
}

void Cds_3::handleMessageWhenUp(cMessage* msg) {
    if (msg->isSelfMessage()) {
        if (msg->getKind() == SAY_HELLO) {
            cMessage* neighsMsg = new cMessage("controlMSG", ONE_HOP_NEIGHS);
            neighsMsg->setKind(ONE_HOP_NEIGHS);
            /*TODO depending how we will solve the problem of having any broadcast message to send
             * when there are still events in the events queue of Omnet++, the marking procedure
             * must be triggered in another way. For instance, in the number of hello messages
             * is computed according to the simulation time we can trigger the marking procedure
             * having ( (the number of hello messages) MOD 3 )== 1*/
            if (nr_hello_msg <= 1) { doMarkingProcedure(); }
            scheduleAt(simTime() + par("helloTime").doubleValue(), neighsMsg);
        } else if (msg->getKind() == ONE_HOP_NEIGHS) {
            Neigh emitter, tmp;
            emitter.addr = myAddress; emitter.pos = position; emitter.name = myself;
            NeighMap myNeigs;
            for (auto& n: neighbors) {
                tmp.addr = n.second.addr; tmp.pos = n.second.pos; tmp.name = n.second.name;
                myNeigs[n.first] = tmp;
            }
            cds3::Cds3* packet = new cds3::Cds3();
            packet->setEmitter(emitter);
            packet->setNeighbors(myNeigs);
            send_package(packet);
        }
    }
    BroadcastingAppBase::handleMessageWhenUp(msg);
}

bool Cds_3::on_network_message_received(cPacket* pkt) {
    return BroadcastingAppBase::on_network_message_received(pkt) ||
            processMessage<cds3::Cds3>(pkt, [&](const cds3::Cds3*m) { this->on_neighbors(m); });
}

void Cds_3::doMarkingProcedure() {
    cerr << getLogHeader() + "Doing marking procedure\n";
    for (auto& myNeig: neighbors) {
        for (auto& neigsMap: oneHopNeigs) {
            if (myNeig.first != neigsMap.first && neigsMap.second.find(myNeig.first) == neigsMap.second.end()) {
                amIrelay = true; cerr << getLogHeader() + "I am Relay\n";
                break;
            }
        }
        if (amIrelay) break;
    }
}

void Cds_3::on_neighbors(const cds3::Cds3* m) {
    std::string emitter = m->getEmitter().name;
    NeighMap emitterNeigs = m->getNeighbors();
    for (auto& n: emitterNeigs)
        if (n.first != myself) { oneHopNeigs[emitter][n.first] = n.second.name; }
}

}
