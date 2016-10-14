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
    if (string(m->getSender()) == myself) return;
    std::string key = string(m->getPayload());
    emitBroadcastMsgReceived(key);
    if (amIrelay && alreadyDispatched.find(key) == alreadyDispatched.end()) {
        broadcast(key, new broadcasting::Broadcast("payload"));
        alreadyDispatched[key] = key;
    }
  }

  void inet::Cds_3::time_to_broadcast_payload(void* user_data) {
    string key = is_source ? myself + "-" + to_string(get_next_id_for_msg()) : string((char*)user_data);
    //if (is_source) { emitBroadcastMsgReceived(key); }
    if (is_source || (amIrelay && alreadyDispatched.find(key) == alreadyDispatched.end())) {
        alreadyDispatched[key] = key;
        broadcast(key, new broadcasting::Broadcast("payload"));
        emitSent(key);
    }
  }

  void Cds_3::handleMessageWhenUp(cMessage* msg) {
    if (msg->isSelfMessage()) {
        if (msg->getKind() == SAY_HELLO) {
    //	    cerr << getLogHeader() + "Doing Hello\n";
            cMessage* neighsMsg = new cMessage("controlMSG", ONE_HOP_NEIGHS);
            neighsMsg->setKind(ONE_HOP_NEIGHS);
            /*TODO depending how we will solve the problem of having any broadcast message to send
             * when there are still events in the events queue of Omnet++, the marking procedure
             * must be triggered in another way. For instance, in the number of hello messages
             * is computed according to the simulation time we can trigger the marking procedure
             * having ( (the number of hello messages) MOD 3 )== 1*/
            if (nr_hello_msg % 2 == 1) { doMarkingProcedure(); }
            scheduleAt(simTime() + par("helloTime").doubleValue() + delta, neighsMsg);
        } else if (msg->getKind() == ONE_HOP_NEIGHS) {
//            cerr << getLogHeader() + "Sending ONE_HOP_NEIGS\n";
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
            packet->setAmIrelay(amIrelay);
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
//    std::string tmp;
//    for (auto& myNeig: neighbors) {tmp += myNeig.first + " "; }
//    cerr << getLogHeader() + "\t one-hop neighbors are: " + tmp + "\n";
//    cerr << getLogHeader() + "\t two-hop neighbors are:\n";
//    for (auto& neigsMap: oneHopNeigs) {
//        tmp = neigsMap.first + " >> ";
//        for (auto& m: oneHopNeigs[neigsMap.first]) { tmp += m.first + ", "; }
//        cerr << getLogHeader() + "\t" + tmp + '\n';
//    }
    /*
     * TODO if mobility is considered in the network scenario the marking procedure
     * must be performed if neighbors differ
     */
    if (!markingProcedureDone){
        for (auto& myNeig: neighbors) {
            for (auto& neigsMap: oneHopNeigs) {
                if (myNeig.first != neigsMap.first && neigsMap.second.find(myNeig.first) == neigsMap.second.end()) {
                    amIrelay = true; cerr << getLogHeader() + "I am Relay (marking procedure)\n";
                    markingProcedureDone = true;
                    return;
                }
            }
        }
    }
    if (amIrelay) applyRule2();
    if (amIrelay) applyRule2_1();
  }

  std::map<std::string, std::string> Cds_3::cloneNeighbors() {
    std::map<std::string, std::string> _union;
    for (auto& n: neighbors) { _union[n.first] = n.first; }
    return _union;
  }

  std::map<std::string, std::string> Cds_3::cloneMap(std::map<std::string, std::string> a) {
      std::map<std::string, std::string> _union;
      for (auto& n: a) { _union[n.first] = n.first; }
      return _union;
  }

  std::map<std::string, std::string> Cds_3::computeUnion(std::map<std::string, std::string> a, std::map<std::string, std::string> b) {
    std::map<std::string, std::string> _union;
    for (auto& n: a) { _union[n.first] = n.first; }
    for (auto& n: b) { _union[n.first] = n.first; }
    return _union;
  }

  bool Cds_3::isSubset(std::map<std::string, std::string> a, std::map<std::string, std::string> b) {
      for (auto& n: a) { if (b.find(n.first) == b.end()) return false; }
      return true;
  }

  bool Cds_3::equal(std::map<std::string, std::string> a,
      std::map<std::string, std::string> b) {
      if (a.size() != b.size()) return false;
      return isSubset(a, b);
  }

  void Cds_3::applyRule2() {
//    cerr << getLogHeader() + "Checking rule 2.0\n";
    if (relaysIcanSee.size() < 2) return;
    int i, j, k; std::string::size_type sz;
    std::map<std::string, int> str_int;
    for (auto& u: relaysIcanSee) {
        for (auto& w: relaysIcanSee) {
            if (u.first != w.first) {
//                cerr << getLogHeader() + "Pair of relays U: " + u.first + " and W: " + w.first + " from rule 2.0\n";
                if (isSubset(cloneNeighbors(), computeUnion(oneHopNeigs[u.first], oneHopNeigs[w.first]))) {
                    i = std::stoi (myself.substr(5, myself.size()), &sz);
                    j = std::stoi (u.first.substr(5, u.first.size()), &sz);
                    k = std::stoi (w.first.substr(5, w.first.size()), &sz);
                    str_int = { {myself, i}, {u.first, j}, {w.first, k} };
                    cerr << getLogHeader() + "my min [" + to_string(i) + "], Umin [" + to_string(j) + "], Wmin [" +
                            to_string(k) + "]\n";
                    int min = std::min( i, std::min(j, k) );
                    cerr << getLogHeader() + "MIN: " + to_string(min) + "\n";
                    if (str_int[myself] == min) {
                        cerr << getLogHeader() + "Not relay anymore<<<<<\n";
                        amIrelay = false;
                        return;
                    }
                }
            }
        }
    }
  }

void Cds_3::applyRule2_1() {
    if (relaysIcanSee.size() < 2) return;
    std::map<std::string, std::string> cpyNeigs = cloneNeighbors();
    std::map<std::string, std::string> uCloseSet, vCloseSet, wCloseSet;
    int idU, idV, idW, min; std::string::size_type sz;
    bool vATuUw, uATvUw, wATuUv;
    for (auto& u: relaysIcanSee) {
        for (auto& w: relaysIcanSee) {
            if (u.first != w.first) {
//                cerr << getLogHeader() + "Pair of relays U: " + u.first + " and W: " + w.first + " from rule 2.1\n";
                //Rule 2.1.1
//                cerr << getLogHeader() + "Checking rule 2.1.1\n";
                vATuUw = isSubset(cpyNeigs, computeUnion(oneHopNeigs[u.first], oneHopNeigs[w.first]));
                uATvUw = isSubset(oneHopNeigs[u.first], computeUnion(cpyNeigs, oneHopNeigs[w.first]));
                wATuUv = isSubset(oneHopNeigs[w.first], computeUnion(oneHopNeigs[u.first], cpyNeigs));
                if (vATuUw && !uATvUw && wATuUv) {
                    cerr << getLogHeader() + "Not relay anymore<<<<<\n";
                    amIrelay = false;
                    return;
                }
                uCloseSet = cloneMap(oneHopNeigs[u.first]);
                wCloseSet = cloneMap(oneHopNeigs[w.first]);
                //adding u, v and w to the corresponding set will make it a close set
                uCloseSet[u.first] = u.first;
                cpyNeigs[myself] = myself;
                wCloseSet[w.first] = w.first;

                idV = std::stoi (myself.substr(5, myself.size()), &sz);
                idU = std::stoi (u.first.substr(5, u.first.size()), &sz);
                idW = std::stoi (w.first.substr(5, w.first.size()), &sz);
                //Rule 2.1.2
//                cerr << getLogHeader() + "Checking rule 2.1.2\n";
                if (vATuUw && uATvUw && !wATuUv) {
                    cerr << getLogHeader() + "Is node 7 here??\n";
                    if (cpyNeigs.size() < uCloseSet.size() ||
                            (cpyNeigs.size() == uCloseSet.size() && idV < idU)) {
                        cerr << getLogHeader() + "Not relay anymore<<<<<\n";
                        amIrelay = false;
                        return;
                    }
                }
                //Rule 2.1.3
//                cerr << getLogHeader() + "Checking rule 2.1.3\n";

                min = std::min( idV, std::min(idU, idW) );
                if (vATuUw && uATvUw && wATuUv) {
                    if ((cpyNeigs.size() < uCloseSet.size() && cpyNeigs.size() < wCloseSet.size()) ||
                            (cpyNeigs.size() == uCloseSet.size() && cpyNeigs.size() < wCloseSet.size() && idV < idU) ||
                            (cpyNeigs.size() == uCloseSet.size() && cpyNeigs.size() == wCloseSet.size()&& idV == min)) {
                        cerr << getLogHeader() + "Not relay anymore<<<<<\n";
                        amIrelay = false;
                        return;
                    }
                }
            }
        }
    }
}

  void Cds_3::on_neighbors(const cds3::Cds3* m) {
    std::string emitter = m->getEmitter().name;
    //cerr << getLogHeader() + "Neighbors reception from peer " + emitter + "\n";
    /*
     * TODO apparently the emiter of a broadcast will receive
     *  the message as well. So, this case must be avoided for
     *  some protocols. Given that CDS cope with open sets to
     *  chose relays the fact of receiving a peer's own vicinity
     *  have an impact
     */
    if (emitter == myself) return;
    if (relaysIcanSee.find(emitter) == relaysIcanSee.end() && m->getAmIrelay())
        relaysIcanSee[emitter] = emitter;
    else if (!m->getAmIrelay())
        relaysIcanSee.erase(emitter);
    NeighMap emitterNeigs = m->getNeighbors();
    for (auto& n: emitterNeigs) { oneHopNeigs[emitter][n.first] = n.second.name; }
  }

}
