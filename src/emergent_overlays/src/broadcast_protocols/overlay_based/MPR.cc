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

#include <broadcast_protocols/overlay_based/MPR.h>
#include <algorithm>

Define_Module(MPR);

cPacket* MPR::buildBroadcastMsg(const char* header) {
  MprBroadcastPacket* payload;

  if (header == nullptr) {
    ostringstream pkName;
    pkName << InteroperableBroadcast::packetName + to_string(InteroperableBroadcast::numSent);
    EV_DEBUG << "New broadcast session [" << pkName.str() << "]" << endl;
    payload = new MprBroadcastPacket(pkName.str().c_str());
  } else {
    payload = new MprBroadcastPacket(header);
  }

  payload->setByteLength(par("messageLength").longValue());
  InteroperableBroadcast::addPacketType(payload, InteroperableBroadcast::UdpPacket::BROADCAST);
  InteroperableBroadcast::addSender(payload);

//  string msg(nodeId + " :: current MPR set = {");
  MprNeighbors myNeigs;
  for (set<string>::iterator it = currentMpr.begin(); it != currentMpr.end(); ++it) {
    EV_DEBUG << "[" << *it << "]" << endl;
    myNeigs.insert(*it);
//    msg += *it + ", ";
  }
//  cout << msg << " }" << endl;
  payload->setNeighbors(myNeigs);

  return payload;
}

void MPR::onBroadcastMsg(cPacket* pk, string sender) {
  InteroperableBroadcast::isPacket<MprBroadcastPacket>(pk, [&](const MprBroadcastPacket* mprPk) {
    MprNeighbors senderNeigs = mprPk->getNeighbors();
    string m(nodeId + " :: payload from sender [" + sender + "] = { ");
    for (MprNeighbors::iterator it = senderNeigs.begin(); it != senderNeigs.end(); ++it) {
      m += *it +", ";
    }
//    cout << m << " } " << endl;
    /*
     * first time the MPR approximation takes place OR neighbors differ between two exchanges of control messages
     */
    bool from_selector = false;
    if(neighborsStatus == 2 || neighborsStatus == 1) {
//      cout << nodeId << " :: FWD decision was computed" << endl;
      for (MprNeighbors::iterator it = senderNeigs.begin(); !from_selector && it != senderNeigs.end(); ++it) {
        EV_DEBUG << "[" << *it << "] == " << InteroperableBroadcast::nodeId << endl;
        from_selector = (*it == InteroperableBroadcast::nodeId);
      }
      previousFwdDecision = from_selector;
    } else {
//      cout << nodeId << " :: previous FWD decision was taken into account" << endl;
      from_selector = previousFwdDecision;
    }
//    cout << nodeId << " :: FWD decision is " << from_selector << endl;
    if (from_selector || amIborderNode) {
      if(amIborderNode) {
        emit(InteroperableBroadcast::forward_type, InteroperableBroadcast::ForwardType::BORDER_NODE);
      }
      else {
        emit(InteroperableBroadcast::forward_type, InteroperableBroadcast::ForwardType::CDS_RELAY);
      }
      cPacket* broadcastMsg = buildBroadcastMsg(mprPk->getName());
      socket.sendTo(broadcastMsg, InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
      emit(InteroperableBroadcast::sentBroadcastMsg, InteroperableBroadcast::getMsgId(broadcastMsg->getName()));
//      fwdBrMsgTimer->setName(mprPk->getName());
//      // XXX found a situation where a FWD_BROADCAST event is scheduled twice
//      //     how is that possible ?
//      if(!fwdBrMsgTimer->isScheduled() ) {
//        InteroperableBroadcast::scheduleEvent(FWD_BROADCAST_MSG, par("sentMsgFixedDelay").doubleValue(),
//            fwdBrMsgTimer); // to avoid collisions/contentions, schedule retransmission of broadcast message
//      }
    }
    return true;
  });
}

void MPR::onControlMsg(cPacket* pk, string sender) {
  InteroperableBroadcast::isPacket<MprPacket>(pk, [&](const MprPacket* mprPk) {
    EV_DEBUG << "MPR.onControlMsg()" << endl;
    neighbors[sender].clear();
    neigsPositions[sender].x = mprPk->getSenderPosAtX();
    neigsPositions[sender].y = mprPk->getSenderPosAtY();

    MprNeighbors senderNeigs = mprPk->getNeighbors();
    MprCoord neigsPosAtX = mprPk->getPositionsAtX();
    MprCoord neigsPosAtY = mprPk->getPositionsAtY();
    string msg(nodeId + " :: neighbors of [" + sender +"] = {");

    for (MprNeighbors::iterator it = senderNeigs.begin(); it != senderNeigs.end(); ++it) {
//      EV_DEBUG << "NEIG [" << *it << "]" << endl;
      if(*it != InteroperableBroadcast::nodeId) {
        msg += *it + ", ";
        neighbors[sender].insert(*it);
        neigsPositions[*it].x = neigsPosAtX[*it];
        neigsPositions[*it].y = neigsPosAtY[*it];
      }
    }
//    cout << msg << " }" << endl;
    return true;
  });
}

void MPR::initialize(int stage) {
  InteroperableBroadcast::initialize(stage);

  if (stage == inet::INITSTAGE_LOCAL) {
    buildCdsTimer = new cMessage("buildCdsTimer");
    sCtrlMsgTimer = new cMessage("sCtrlMsgTimer");
    fwdBrMsgTimer = new cMessage("fwdBrMsgTimer");
  }

}

void MPR::processStart() {
  InteroperableBroadcast::processStart();
  InteroperableBroadcast::scheduleEvent(SEND_CTRL_MSG_TO_BOOT, InteroperableBroadcast::sentMsgDelay, buildCdsTimer);
}

void MPR::handleMessageWhenUp(cMessage* msg) {
  if (msg->isSelfMessage() && (buildCdsTimer == msg || sCtrlMsgTimer == msg || fwdBrMsgTimer == msg)) {
    //TODO define a case in reception of self-message HALT_APP
    switch (msg->getKind()) {
      case SEND_CTRL_MSG_TO_BOOT:
        socket.sendTo(getCtrlMsg(), InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);

        cancelEvent(msg);
        if (sentBootEvents < par("bootCtrlMsgsNo").longValue()) {
          EV_DEBUG << "scheduling BOOT_CTRL_MSG [" << sentBootEvents << "]" << endl;
          InteroperableBroadcast::scheduleEvent(SEND_CTRL_MSG_TO_BOOT,
              par("sentMsgFixedDelay").doubleValue() * par("maxNodesNo").longValue(), buildCdsTimer);
        } else {
          for (auto it = neighbors.begin(); it != neighbors.end(); ++it)
            previousNeigs.insert(it->first);
          EV_DEBUG << "schedule 1st approximation of a backbone" << endl;
          InteroperableBroadcast::scheduleEvent(BUILD_CDS,
              par("sentMsgFixedDelay").doubleValue() * par("maxNodesNo").longValue(), buildCdsTimer);
        }
        sentBootEvents++;
        break;
      case BUILD_CDS: {
        currentMpr = compute_mpr();
//        string m(nodeId + " :: cds = { ");
//        for (set<string>::iterator it = currentMpr.begin(); it != currentMpr.end(); ++it) {
//          m += *it + ", ";
//        }
//        cerr << m << " }" << endl;
        neighbors.clear();
        set<string> keys;
        for (auto it = neighbors.begin(); it != neighbors.end(); ++it) {
          keys.insert(it->first);
        }
        for (set<string>::iterator it = keys.begin(); it != keys.end(); ++it)
          neighbors.erase(*it);
        keys.clear();
        for (auto it = neigsPositions.begin(); it != neigsPositions.end(); ++it)
          keys.insert(it->first);
        for (set<string>::iterator it = keys.begin(); it != keys.end(); ++it)
          neigsPositions.erase(*it);
      }
        break;
      case FWD_BROADCAST_MSG: {
        EV_DEBUG << "FWD message [" << msg->getName() << "] now" << endl;
        cPacket* broadcastMsg = buildBroadcastMsg(msg->getName());
        socket.sendTo(broadcastMsg, InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
        emit(InteroperableBroadcast::sentBroadcastMsg, InteroperableBroadcast::getMsgId(broadcastMsg->getName()));
      }
        break;
      case SEND_CTRL_MSG: {
        socket.sendTo(getCtrlMsg(), InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
        // compare whether neighbors have differed between 2 exchanges of control messages
        if (previousNeigs.size() != neighbors.size()) {
          neighborsStatus = 1;
        } else {
          bool firstInc = true;
          for (auto it = neighbors.begin(); it != neighbors.end() && firstInc; ++it) {
            if (previousNeigs.find(it->first) == previousNeigs.end())
              firstInc = false;
          }
          bool seconInc = true;
          for (set<string>::iterator it = previousNeigs.begin(); it != previousNeigs.end() && seconInc; ++it) {
            if (neighbors.find(*it) == neighbors.end())
              seconInc = false;
          }
          neighborsStatus = firstInc && seconInc ? 0 : 1;
        }
        // update previous list of neighbors
        previousNeigs.clear();
        for (auto it = neighbors.begin(); it != neighbors.end(); ++it)
          previousNeigs.insert(it->first);
      }
        break;
      default:
        throw cRuntimeError("Invalid kind %d in Mpr.buildCdsTimer", (int) msg->getKind());
    }
  } else
    InteroperableBroadcast::handleMessageWhenUp(msg);
}

void MPR::sendPacket() {
  if (par("isSource").boolValue()) {

    cPacket* pk = buildBroadcastMsg(nullptr);
    socket.sendTo(pk, InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
    emit(InteroperableBroadcast::sentBroadcastMsg, InteroperableBroadcast::getMsgId(pk->getName()));
    emit(InteroperableBroadcast::forward_type, InteroperableBroadcast::ForwardType::CDS_RELAY);

    // tag packet as received
    InteroperableBroadcast::receivedMsg.insert(pk->getName());
  }
  // count sent broadcast messages in all nodes. This is useful in an experiment
  // where any node in the network act as source of a broadcast session
  InteroperableBroadcast::numSent++;
}

void MPR::sendCtrlMsg() {
  cancelEvent(sCtrlMsgTimer);
  cancelEvent(buildCdsTimer);
  // 2 exchanges of control messages are required to approximate a CDS
  // - 1st exchange: neighbors
  // - 2nd exchange: neighbors of neighbors
  socket.sendTo(getCtrlMsg(), InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
  InteroperableBroadcast::scheduleEvent(SEND_CTRL_MSG,
      par("sentMsgFixedDelay").doubleValue() * par("maxNodesNo").longValue(), sCtrlMsgTimer);
  // and then build the backbone; schedue event until the 2 exchange take place
  InteroperableBroadcast::scheduleEvent(BUILD_CDS,
      par("sentMsgFixedDelay").doubleValue() * par("maxNodesNo").longValue() * 2, buildCdsTimer);
}

cPacket* MPR::getCtrlMsg() {
  MprPacket* ctrlMsg = new MprPacket("CtrlMsg");

  InteroperableBroadcast::addPacketType(ctrlMsg, UdpPacket::CTRL);
  InteroperableBroadcast::addSender(ctrlMsg);
  InteroperableBroadcast::addSendersRunningAlgo(ctrlMsg);

  ctrlMsg->setSenderPosAtX(InteroperableBroadcast::currentPosition.x);
  ctrlMsg->setSenderPosAtY(InteroperableBroadcast::currentPosition.y);

  MprNeighbors myNeigs;
  MprCoord positionsAtX;
  MprCoord positionsAtY;

//  cout << nodeId << " :: neighbors.size = " << neighbors.size() << endl;
  EV_DEBUG << "Current neighbors:" << endl;
  for (auto it = neighbors.begin(); it != neighbors.end(); ++it) {
    EV_DEBUG << "\t " << it->first << endl;
    myNeigs.insert(it->first);
    positionsAtX[it->first] = neigsPositions[it->first].x;
    positionsAtY[it->first] = neigsPositions[it->first].y;
  }

  ctrlMsg->setNeighbors(myNeigs);
  ctrlMsg->setPositionsAtX(positionsAtX);
  ctrlMsg->setPositionsAtY(positionsAtY);
  return ctrlMsg;
}

set<string> MPR::compute_mpr() {
  set<string> mpr;
  map<string, set<string>> latest = make_cpy(neighbors);
  hops[0].clear();
  hops[1].clear();
  // first fill the array hops
  for (const auto& p : latest) {
    string j(p.first);
    hops[0].insert(j);
    for (const auto& name : p.second) {
      EV_DEBUG << "name [" << name << "] && nodeId [" << InteroperableBroadcast::nodeId << "]" << endl;
      if (name == InteroperableBroadcast::nodeId)
        continue;
      bool no_neighbor = hops[0].find(name) == hops[0].end();
      if (no_neighbor) {
        hops[1].insert(name);
      }
    }
  }

  /* base case (rule 2 in the paper)  */
  for (const auto& z : hops[1]) {
    int count = 0;
    string unique = "";

    for (const auto& y : hops[0]) {
      if (is_a_covered_by_b(z, y)) {
        unique = y;
        count++;
      }
    }

    if (count == 1) {
      mpr.insert(unique);
    }

  }

  /* rule 3 from the paper */
  auto is_not_covered_by_mpr = [&] (string z)
  {
    bool r = any_of(mpr.begin(), mpr.end(), [&] (string h)
        {
          return is_a_covered_by_b(z, h);
        });
    return !r;
  };

  bool still_uncovered = any_of(hops[1].begin(), hops[1].end(), is_not_covered_by_mpr);

  int iterations = 0;

  int MAX_ITERATION = 100; // FIXME: this is crap

  set<string> already_covered;
  for (const auto& z : hops[1]) {
    for (const auto& e : mpr) {
      if (is_a_covered_by_b(z, e)) {
        already_covered.insert(z);
      }
    }
  }

  while (still_uncovered && iterations < MAX_ITERATION) {
    //cerr << myself << ": building mpr, already with " << mpr.size() << " elements" << endl;
    string max_y = "";
    int max = -1;
    for (const auto& y : hops[0]) {
      if (mpr.find(y) == mpr.end()) {
        int c = 0;
        for (const auto& z : hops[1])
          if (already_covered.find(z) == already_covered.end() && is_a_covered_by_b(z, y))
            c++;

        if (c > max) {
          max_y = y;
          max = c;
        }
      }
    }

    if (max_y != "") {
      mpr.insert(max_y);
      for (const auto& z : hops[1]) {
        for (const auto& e : mpr) {
          if (is_a_covered_by_b(z, e)) {
            already_covered.insert(z);
          }
        }
      }
    }

    still_uncovered = any_of(hops[1].begin(), hops[1].end(), is_not_covered_by_mpr);
    iterations++;
  }
  return mpr;
}
