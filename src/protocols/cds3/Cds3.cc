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

  bool Cds_3::handleNodeStart(IDoneCallback* doneCallback) {
      doRule2 = par("doRule2").boolValue();
      doOptiP = par("doOptiP").boolValue();
      return BroadcastingAppBase::handleNodeStart(doneCallback);
  }

  void inet::Cds_3::on_payload_received(const broadcasting::Broadcast* m) {
    std::string key = string(m->getPayload());
    if (string(m->getSender()) == myself) return;
    cout << getLogHeader() + "KEY_RECEPTION " + key + " FROM_PEER " + string(m->getSender()) << endl;
    emitBroadcastMsgReceived(key);
    if (amIrelay && alreadyDispatched.find(key) == alreadyDispatched.end()) {
        alreadyDispatched[key] = key;
        broadcast(key, new broadcasting::Broadcast("payload"));
        //having a delay between retransmissions will decrease the number of
        //collisions but the broadcasting sessions time will increase as well
        //delayed_broadcast(key, delta);
    }

  }

  void inet::Cds_3::time_to_broadcast_payload(void* user_data) {
    string key;
    if (!user_data)
        key = createUniqueBroadcastingSessionId();
    else
        key = string((char*) user_data);
    // In general, if method delayed_broadcast() is not called to retransmit messages
    // these two lines are performed just by the peer who initiate a broadast session
    broadcast(key, new broadcasting::Broadcast("payload"));
    alreadyDispatched[key] = key;
  }

  void Cds_3::handleMessageWhenUp(cMessage* msg) {
      if (msg->isSelfMessage()) {
          if (msg->getKind() == SAY_HELLO) {
              Neigh emitter;
              emitter.addr = myAddress; emitter.pos = position; emitter.name = myself;
              NeighMap myNeigs;
              for (auto& n: neighbors)
                  myNeigs[n.first] = n.second;
              cds3::Cds3* packet = new cds3::Cds3();
              packet->setEmitter(emitter);
              packet->setNeighbors(myNeigs);
              packet->setAmIrelay(amIrelay);
              send_package(packet);

              doMarkingProcedure();

              nr_hello_msg--;
              cancelAndDelete(msg);
              if (nr_hello_msg > 0) {
                  cMessage* neighsMsg = new cMessage("controlMSG", SAY_HELLO);
                  neighsMsg->setKind(SAY_HELLO);
                  scheduleAt(simTime() + par("helloTime").doubleValue(), neighsMsg);
              }
            } else
                BroadcastingAppBase::handleMessageWhenUp(msg);
      } else
          BroadcastingAppBase::handleMessageWhenUp(msg);
  }

  bool Cds_3::on_network_message_received(cPacket* pkt) {
    return BroadcastingAppBase::on_network_message_received(pkt) ||
	processMessage<cds3::Cds3>(pkt, [&](const cds3::Cds3*m) { on_neighbors_reception(m); });
  }

  /*
   * If peer's vicinity changes the marking procedure must be performed again,
   * additionally, the way relays inform others must be updated too.
   * These modifications are required to cope with mobility.
   * take into consideration that there are two phases while marking peers as
   * relays; firstly, to launch the marking procedure itself and secondly to
   * minimize the CDS with peers labeled as relays. In other words, the full
   * CDS protocol is finished in two SAY_HELLO messages.
   */
void Cds_3::doMarkingProcedure() {
    if (changeAtVicinity()) {
//        cerr << getLogHeader() + "Change at vicinity\n";
        markingProcedureDone = false;
        optimizProcedureDone = false;
        amIrelay = false;
        neighbors.empty();
        relaysIcanSee.empty();
        neighboursChache.empty();
        return;
    }
    if (!markingProcedureDone){
        cout << getLogHeader() + "Doing marking procedure\n";
        for (auto& m: neighboursChache) {
            for (auto& n: neighboursChache) {
                if (m.first != n.first && n.second.find(m.first) == n.second.end()) {
                    amIrelay = true;
                    cout << getLogHeader() + "I am Relay (marking procedure)\n";
                    markingProcedureDone = true;
                    cout << getLogHeader() + "Marking procedure DONE\n";
                    neighbors.empty();
                    relaysIcanSee.empty();
                    return;
                }
            }
        }
        markingProcedureDone = true;
        cout << getLogHeader() + "Marking procedure DONE\n";
    } else if (!optimizProcedureDone){
        if (relaysIcanSee.size() < 2) return;
        cout << getLogHeader() + "Doing optimization procedure\n";
        if (!doRule2) { // Doing Rules 1 and/or 1a
            applyRule1();
            if (doOptiP)
                applyRule1_1();
        } else { // Doing Rules 2 and/or 2a
            if (amIrelay) {
                applyRule2();
                if (amIrelay && doOptiP)
                    applyRule2_1();
            }
        }
        optimizProcedureDone = true;
        cout << getLogHeader() + "Optimization procedure DONE\n";
    }
    neighbors.empty();
    relaysIcanSee.empty();
}

  std::map<std::string, std::string> Cds_3::cloneNeighbors() {
    std::map<std::string, std::string> _union;
    for (auto& n: neighbors) { _union[n.first] = n.first; }
    return _union;
  }

  std::map<std::string, std::string> Cds_3::cloneMap(NeighMap a) {
      std::map<std::string, std::string> _union;
      for (auto& n: a) { _union[n.first] = n.first; }
      return _union;
  }

  std::map<std::string, std::string> Cds_3::computeUnion(NeighMap a, NeighMap b) {
    std::map<std::string, std::string> _union;
    for (auto& n: a) { _union[n.first] = n.first; }
    for (auto& n: b) { _union[n.first] = n.first; }
    return _union;
  }

  bool Cds_3::isSubset(std::map<std::string, std::string> a, std::map<std::string, std::string> b) {
      for (auto& n: a) { if (b.find(n.first) == b.end()) return false; }
      return true;
  }

  void Cds_3::applyRule1() {
      int uId, vId; std::string::size_type sz;
      std::map<std::string, std::string> uCloseSet, vCloseSet;
      for (auto& v: relaysIcanSee) {
            for (auto& u: relaysIcanSee) {
                if (v.first != u.first) {
                    vCloseSet = cloneMap(neighboursChache[v.first]);
                    vCloseSet[v.first] = v.first;
                    uCloseSet = cloneMap(neighboursChache[u.first]);
                    uCloseSet[u.first] = u.first;
                    vId = std::stoi (v.first.substr(5, v.first.size()), &sz);
                    uId = std::stoi (u.first.substr(5, u.first.size()), &sz);
                    if (isSubset(vCloseSet, uCloseSet) && vId < uId) {
                        cout << getLogHeader() + "Not relay anymore<<<<<\n";
                        log_status_for_animation("UNMARKED4");
                        amIrelay = false;
                        return;
                    }
                }
            }
      }
  }

  void Cds_3::applyRule1_1() {
      int uId, vId; std::string::size_type sz;
      std::map<std::string, std::string> uCloseSet, vCloseSet;
      for (auto& v: relaysIcanSee) {
            for (auto& u: relaysIcanSee) {
                if (v.first != u.first) {
                    vCloseSet = cloneMap(neighboursChache[v.first]);
                    vCloseSet[v.first] = v.first;
                    uCloseSet = cloneMap(neighboursChache[u.first]);
                    uCloseSet[u.first] = u.first;
                    vId = std::stoi (v.first.substr(5, v.first.size()), &sz);
                    uId = std::stoi (u.first.substr(5, u.first.size()), &sz);
                    if (isSubset(vCloseSet, uCloseSet)) {
                        if (neighboursChache[v.first].size() < neighboursChache[v.first].size() ||
                                (neighboursChache[v.first].size() == neighboursChache[v.first].size() && vId < uId))
                        cout << getLogHeader() + "Not relay anymore<<<<<\n";
                        log_status_for_animation("UNMARKED4");
                        amIrelay = false;
                        return;
                    }
                }
            }
      }
  }

  void Cds_3::applyRule2() {
//    string info = getLogHeader() + "RELAYS: ";
//    for (auto & r: relaysIcanSee)
//        info += r.first + ", ";
//    cerr << info + "\n";
//    cerr << getLogHeader() + "Checking rule 2.0\n";
    int i, j, k; std::string::size_type sz;
    std::map<std::string, int> str_int;
    for (auto& u: relaysIcanSee) {
        for (auto& w: relaysIcanSee) {
            if (u.first != w.first) {
//                cerr << getLogHeader() + "Pair of relays U: " + u.first + " and W: " + w.first + " from rule 2.0\n";
                if (isSubset(cloneNeighbors(), computeUnion(neighboursChache[u.first], neighboursChache[w.first]))) {
                    i = std::stoi (myself.substr(5, myself.size()), &sz);
                    j = std::stoi (u.first.substr(5, u.first.size()), &sz);
                    k = std::stoi (w.first.substr(5, w.first.size()), &sz);
                    str_int = { {myself, i}, {u.first, j}, {w.first, k} };
//                    cerr << getLogHeader() + "my min [" + to_string(i) + "], Umin [" + to_string(j) + "], Wmin [" +
//                            to_string(k) + "]\n";
                    int min = std::min( i, std::min(j, k) );
//                    cerr << getLogHeader() + "MIN: " + to_string(min) + "\n";
                    if (str_int[myself] == min) {
                        log_status_for_animation("UNMARKED4");
                        cout << getLogHeader() + "Not relay anymore" << endl;
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
//    cerr << getLogHeader() + "Checking rule 2.1.1\n";
    std::map<std::string, std::string> cpyNeigs = cloneNeighbors();
    std::map<std::string, std::string> uCloseSet, vCloseSet, wCloseSet;
    int idU, idV, idW, min; std::string::size_type sz;
    bool vATuUw = false, uATvUw = false, wATuUv = false;
    for (auto& u: relaysIcanSee) {
        for (auto& w: relaysIcanSee) {
            if (u.first != w.first) {
//                cerr << getLogHeader() + "Pair of relays U: " + u.first + " and W: " + w.first + " from rule 2.1.1\n";
                //Rule 2.1.1
                vATuUw = isSubset(cpyNeigs, computeUnion(neighboursChache[u.first], neighboursChache[w.first]));
                uATvUw = isSubset(cloneMap(neighboursChache[u.first]), computeUnion(neighbors, neighboursChache[w.first]));
                wATuUv = isSubset(cloneMap(neighboursChache[w.first]), computeUnion(neighboursChache[u.first], neighbors));
                if (vATuUw && !uATvUw && !wATuUv) {
                    cout << getLogHeader() + "Not relay anymore<<<<<\n";
                    log_status_for_animation("UNMARKED2a1");
                    amIrelay = false;
                    return;
                }
                uCloseSet = cloneMap(neighboursChache[u.first]);
                wCloseSet = cloneMap(neighboursChache[w.first]);
                //adding u, v and w to the corresponding set will make it a close set
                uCloseSet[u.first] = u.first;
                wCloseSet[w.first] = w.first;

                idV = std::stoi (myself.substr(5, myself.size()), &sz);
                idU = std::stoi (u.first.substr(5, u.first.size()), &sz);
                idW = std::stoi (w.first.substr(5, w.first.size()), &sz);
                //Rule 2.1.2
                if (vATuUw && uATvUw && !wATuUv) {
                    if (cpyNeigs.size() < uCloseSet.size() ||
                            (cpyNeigs.size() == uCloseSet.size() && idV < idU)) {
                        cout << getLogHeader() + "Not relay anymore<<<<<\n";
                        log_status_for_animation("UNMARKED2a2");
                        amIrelay = false;
                        return;
                    }
                }
//                cerr << getLogHeader() + "my min [" + to_string(idV) + "], Umin [" + to_string(idU) + "], Wmin [" +
//                                            to_string(idW) + "] from rule 2.1.3\n";
                //Rule 2.1.3
                min = std::min( idV, std::min(idU, idW) );
//                cerr << getLogHeader() + "MIN: " + to_string(min) + "\n";
                if (vATuUw && uATvUw && wATuUv) {
                    if ((cpyNeigs.size() < uCloseSet.size() && cpyNeigs.size() < wCloseSet.size()) ||
                            (cpyNeigs.size() == uCloseSet.size() && cpyNeigs.size() < wCloseSet.size() && idV < idU) ||
                            (cpyNeigs.size() == uCloseSet.size() && cpyNeigs.size() == wCloseSet.size()&& idV == min)) {
                        cout << getLogHeader() + "Not relay anymore<<<<<\n";
                        log_status_for_animation("UNMARKED2a3");
                        amIrelay = false;
                        return;
                    }
                }
            }
        }
    }
}

  bool Cds_3::changeAtVicinity() {
    //first, check whether the number of neighbors is changed or not
    if (lastSize != (int) neighbors.size()) {
        lastSize = neighbors.size();
        return true;
    }
    if (neighbors.size() != neighboursChache.size()) return true;
    for (auto& n: neighbors) {
        if (neighboursChache.find(n.first) == neighboursChache.end()) return true;
    }
    age++;
    return false;
  }

  void Cds_3::on_neighbors_reception(const cds3::Cds3* m) {
     Neigh emitter = m->getEmitter();
    //Avoiding that peers receive their own neighbors
    if (emitter.name == myself) return;
    // One-hop neighbors
    neighbors[emitter.name] = emitter;
    // Two-hop neighbors
    neighboursChache[emitter.name] = m->getNeighbors();
    if (m->getAmIrelay())
        relaysIcanSee[emitter.name] = emitter.name;
  }
}
