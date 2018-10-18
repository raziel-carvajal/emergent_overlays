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

cPacket* MPR::buildBroadcastMsg() {
  ostringstream pkName;
  pkName << InteroperableBroadcast::packetName + to_string(InteroperableBroadcast::numSent);
  EV_DEBUG << "[MPR] New broadcast session. MsgId=" << pkName.str() << endl;

  MprBroadcastPacket* payload = new MprBroadcastPacket(pkName.str().c_str());
  payload->setByteLength(par("messageLength").longValue());
  InteroperableBroadcast::addPacketType(payload, InteroperableBroadcast::UdpPacket::BROADCAST);
  InteroperableBroadcast::addSender(payload);

  MprNeighbors myNeigs;

  for (set<string>::iterator it = currentMpr.begin(); it != currentMpr.end(); ++it)
    myNeigs.insert(*it);

  payload->setNeighbors(myNeigs);

  return payload;
}

cPacket* MPR::buildBroadcastMsg(const char* header) {

  MprBroadcastPacket* payload = new MprBroadcastPacket(header);
  payload->setByteLength(par("messageLength").longValue());
  InteroperableBroadcast::addPacketType(payload, InteroperableBroadcast::UdpPacket::BROADCAST);
  InteroperableBroadcast::addSender(payload);

  MprNeighbors myNeigs;
  for (set<string>::iterator it = currentMpr.begin(); it != currentMpr.end(); ++it)
    myNeigs.insert(*it);
  payload->setNeighbors(myNeigs);

  return payload;
}

void MPR::onBroadcastMsg(cPacket* pk) {
  InteroperableBroadcast::isPacket<MprBroadcastPacket>(pk, [&](const MprBroadcastPacket* mprPk) {
    EV_DEBUG << "MPR.onBroadcastMsg()" << endl;
    if (InteroperableBroadcast::receivedMsg.find(mprPk->getName()) == InteroperableBroadcast::receivedMsg.end()) {
      InteroperableBroadcast::receivedMsg.insert(mprPk->getName());

      MprNeighbors senderNeigs = mprPk->getNeighbors();
      EV_DEBUG << "My ID:" << nodeId << endl;
      EV_DEBUG << "Nodes in MprBroadcast packet:" << endl;

      bool from_selector = false;
      for (MprNeighbors::iterator it = senderNeigs.begin(); !from_selector && it != senderNeigs.end(); ++it) {
        EV_DEBUG << "[" << *it << "] == " << '"' + InteroperableBroadcast::nodeId + '"' << endl;
        from_selector = (*it == '"' + InteroperableBroadcast::nodeId + '"');
      }
      if (from_selector) {
        EV_DEBUG << "FWD NOW !!" << endl;
        cPacket* msg = buildBroadcastMsg(mprPk->getName());
        socket.sendTo(msg, InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
        emit(InteroperableBroadcast::sentBroadcastMsg, InteroperableBroadcast::getMsgId(msg->getName()));
      }

    }
  });
}

void MPR::onControlMsg(cPacket* pk) {
  // TODO deal with the situation when received packet is not for MPR
  // bool isMprPk =
  InteroperableBroadcast::isPacket<MprPacket>(pk, [&](const MprPacket* mprPk) {
    EV_DEBUG << "MPR.onControlMsg()" << endl;

    string sender(pk->par("Sender").str());

    neighbors[sender].clear();
    neigsPositions[sender].x = mprPk->getSenderPosAtX();
    neigsPositions[sender].y = mprPk->getSenderPosAtY();

    MprNeighbors senderNeigs = mprPk->getNeighbors();
    MprCoord neigsPosAtX = mprPk->getPositionsAtX();
    MprCoord neigsPosAtY = mprPk->getPositionsAtY();
    EV_DEBUG << "Sender [" << sender << "] has the following neighbors:" << endl;

    for (MprNeighbors::iterator it = senderNeigs.begin(); it != senderNeigs.end(); ++it) {
      EV_DEBUG << "NEIG" << *it << endl;
      if(*it != '"' + InteroperableBroadcast::nodeId + '"') {
        EV_DEBUG << "\t [" << *it << "]" << endl;
        neighbors[sender].insert(*it);
        neigsPositions[*it].x = neigsPosAtX[*it];
        neigsPositions[*it].y = neigsPosAtY[*it];
      }
    }

  });
}

void MPR::initialize(int stage) {
  InteroperableBroadcast::initialize(stage);

  if (stage == inet::INITSTAGE_LOCAL) {
    buildCdsTimer = new cMessage("buildCdsTimer");
    sCtrlMsgTimer = new cMessage("sCtrlMsgTimer");
    InteroperableBroadcast::scheduleEvent(SEND_CTRL_MSG_TO_BOOT, par("bootCtrlMsgInterval").doubleValue(),
        buildCdsTimer);
  }

}

void MPR::handleMessageWhenUp(cMessage* msg) {
  if (msg->isSelfMessage() && (buildCdsTimer == msg || sCtrlMsgTimer == msg)) {
    switch (msg->getKind()) {
      //TODO define a case in reception of self-message HALT_APP
      case SEND_CTRL_MSG_TO_BOOT:

        socket.sendTo(getCtrlMsg(), InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);

        sentBootEvents++;
        if (sentBootEvents < par("bootCtrlMsgsNo").longValue()) {
          EV_DEBUG << "scheduling BOOT_CTRL_MSG [" << sentBootEvents << "]" << endl;
          InteroperableBroadcast::scheduleEvent(SEND_CTRL_MSG_TO_BOOT,
              sentBootEvents * par("bootCtrlMsgInterval").doubleValue(), buildCdsTimer);
        }
        else {
          EV_DEBUG << "1st BUILD_CDS" << endl;
          currentMpr = compute_mpr();
          InteroperableBroadcast::scheduleEvent(BUILD_CDS, par("ctrlMsgInterval").doubleValue(), buildCdsTimer);
          InteroperableBroadcast::scheduleEvent(SEND_CTRL_MSG, par("bootCtrlMsgInterval").doubleValue(), sCtrlMsgTimer);
        }
        break;
      case BUILD_CDS:
        EV_DEBUG << "Nth BUILD_CDS" << endl;
        currentMpr = compute_mpr();
        InteroperableBroadcast::scheduleEvent(BUILD_CDS, par("ctrlMsgInterval").doubleValue(), buildCdsTimer);
        InteroperableBroadcast::scheduleEvent(SEND_CTRL_MSG, par("bootCtrlMsgInterval").doubleValue(), sCtrlMsgTimer);
        break;
      case SEND_CTRL_MSG:
        socket.sendTo(getCtrlMsg(), InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
        break;
      default:
        throw cRuntimeError("Invalid kind %d in Mpr.buildCdsTimer", (int) msg->getKind());
    }
  }
  else
    InteroperableBroadcast::handleMessageWhenUp(msg);
}

void MPR::sendPacket() {
  if (par("isSource").boolValue()) {

    cPacket* pk = buildBroadcastMsg();
    socket.sendTo(pk, InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
    emit(InteroperableBroadcast::sentBroadcastMsg, InteroperableBroadcast::getMsgId(pk->getName()));

    // tag packet as received
    InteroperableBroadcast::receivedMsg.insert(pk->getName());
  }
  // count sent broadcast messages in all nodes. This is useful in an experiment
  // where any node in the network act as source of a broadcast session
  InteroperableBroadcast::numSent++;
  // timer to store nodes position and density
  scheduleEvent(Timer::MONITOR, par("monitorDelay").doubleValue(), monitorTimer);

}

cPacket* MPR::getCtrlMsg() {
  MprPacket* ctrlMsg = new MprPacket("CtrlMsg");

  InteroperableBroadcast::addPacketType(ctrlMsg, UdpPacket::CTRL);
  InteroperableBroadcast::addSender(ctrlMsg);

  Coord p = InteroperableBroadcast::mobilityModel->getCurrentPosition();
  ctrlMsg->setSenderPosAtX(p.x);
  ctrlMsg->setSenderPosAtY(p.y);

  MprNeighbors myNeigs;
  MprCoord positionsAtX;
  MprCoord positionsAtY;

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

void MPR::cancelSelfEvents() {
  cancelAndDelete(buildCdsTimer);
  cancelAndDelete(sCtrlMsgTimer);
}

set<string> MPR::compute_mpr() {
  set<string> mpr;
  if (first_exec) {
    first_exec = false;
    latest = neighbors;
  }
  else {
    bool changeOfNeigs = false;
    if (neighbors.size() != 0) {
      if (latest.size() != neighbors.size()) {
        changeOfNeigs = true;
      }
      else {
        for (const auto& p : neighbors) {
          string key = p.first;
//          EV_DEBUG <<
          if (latest.find(key) == latest.end()) {
            changeOfNeigs = true;
            break;
          }
        }
      }
    }
    if (changeOfNeigs) {
      latest.clear();
      latest = make_cpy(neighbors);
    }
  }
  hops[0].clear();
  hops[1].clear();
  // first fill the array hops
  for (const auto& p : latest) {
    string j(p.first);
    hops[0].insert(j);
    for (const auto& name : p.second) {
      EV_DEBUG << "name [" << name << "] && nodeId [" << '"' + InteroperableBroadcast::nodeId + '"' << "]" << endl;
      if (name == '"' + InteroperableBroadcast::nodeId + '"')
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

  int MAX_ITERATION = 1000; // FIXME: this is crap

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
  neighbors.clear();
  return mpr;
}
