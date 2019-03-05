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
  InteroperableBroadcast::addPacketHeaders(payload);

  MprNeighbors myNeigs;
  for (set<string>::iterator it = currentMpr.begin(); it != currentMpr.end(); ++it)
    myNeigs.insert(*it);
  payload->setNeighbors(myNeigs);

  return payload;
}

bool MPR::amIrelay(MprNeighbors senderNeigs) {
  bool relay = false;
  string temp(nodeId + "] deciding with neighbors = { ");
  for (MprNeighbors::iterator it = senderNeigs.begin(); !relay && it != senderNeigs.end(); ++it) {
    relay = (*it == InteroperableBroadcast::nodeId);
    temp += *it + ", ";
  }
  cout << "[" << simTime() << ", " << temp << "}" << endl;
//  if (neigsChanged())
//    previousDec = relay;
//  else
//    relay = previousDec;
  return relay;
}

void MPR::onBroadcastMsg(cPacket* pk, string sender) {
  InteroperableBroadcast::isPacket<MprBroadcastPacket>(pk,
      [&](const MprBroadcastPacket* mprPk) {
        if(alreadyDispatched.find(mprPk->getName()) != alreadyDispatched.end()) return true;

        string temp(nodeId + "]");
        if (InteroperableBroadcast::receivedMsg.find(mprPk->getName()) == InteroperableBroadcast::receivedMsg.end()) {
          cout << "[" << simTime() << ", " << temp << " 1st reception, schedule FWD in " << par("sentMsgFixedDelay").doubleValue() << endl;
          // tag packet as received
          receivedMsg.insert(mprPk->getName());
          // required to improve MPR algorithm
          currentReceptions = 1;
          latestPayload.clear();
          // schedule FWD decision
          fwdBrMsgTimer->par("ReceivedMsgId").setStringValue(mprPk->getName());
          InteroperableBroadcast::scheduleEvent(FWD_BROADCAST_MSG, par("sentMsgFixedDelay").doubleValue(), fwdBrMsgTimer);
        } else {
          currentReceptions++;
        }

        if(currentReceptions <= par("allowedReceptions").doubleValue()) {
          cout << "[" << simTime() << ", " << temp << " reception No = " << currentReceptions << endl;

          // keep payload from neighbors
          MprNeighbors senderNeigs = mprPk->getNeighbors();
          for (MprNeighbors::iterator it = senderNeigs.begin(); it != senderNeigs.end(); ++it) {
            latestPayload.insert(*it);
          }
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
    string msg(nodeId + "] neighbors received from [" + sender +"] ::");

    for (MprNeighbors::iterator it = senderNeigs.begin(); it != senderNeigs.end(); ++it) {
//      EV_DEBUG << "NEIG [" << *it << "]" << endl;
      if(*it != InteroperableBroadcast::nodeId) {
        msg += *it + ", ";
        neighbors[sender].insert(*it);
        neigsPositions[*it].x = neigsPosAtX[*it];
        neigsPositions[*it].y = neigsPosAtY[*it];
      }
    }
    cout << "[" << simTime() << ", " << msg << endl;
    return true;
  });
}

void MPR::initialize(int stage) {
  InteroperableBroadcast::initialize(stage);

  if (stage == inet::INITSTAGE_LOCAL) {
    buildCdsTimer = new cMessage("buildCdsTimer");
    sCtrlMsgTimer = new cMessage("sCtrlMsgTimer");
    fwdBrMsgTimer = new cMessage("fwdBrMsgTimer");
    cMsgPar* p = new cMsgPar("ReceivedMsgId");
    p->setStringValue("");
    fwdBrMsgTimer->addPar(p);
  }

}

void MPR::processStart() {
  similarity = par("similarity").doubleValue();
  viewSize = par("viewSize").doubleValue();
  InteroperableBroadcast::processStart();
  InteroperableBroadcast::scheduleEvent(SCHEDULE_CTRL_MSGS,
      InteroperableBroadcast::sentMsgDelay + par("sentMsgFixedDelay").doubleValue(), sCtrlMsgTimer);
}

void MPR::handleMessageWhenUp(cMessage* msg) {
  if (msg->isSelfMessage() && (buildCdsTimer == msg || sCtrlMsgTimer == msg || fwdBrMsgTimer == msg)) {
    //TODO define a case in reception of self-message HALT_APP
    switch (msg->getKind()) {
      // time required to approximate a CDS is ~0.5s
      case BUILD_CDS: {
        currentMpr = compute_mpr();
        string temp(nodeId + "] my CDS is = ");
        for (set<string>::iterator it = currentMpr.begin(); it != currentMpr.end(); ++it)
          temp += *it + ", ";
        cout << "[" << simTime() << ", " << temp << endl;
      }
        break;
      case FWD_BROADCAST_MSG: {
        alreadyDispatched.insert(msg->par("ReceivedMsgId").stringValue());
        string temp(nodeId + "] deciding to FWD message: " + msg->par("ReceivedMsgId").stringValue());

        bool fwdMsg = false;
        if (amIrelay(latestPayload)) {
          fwdMsg = true;
          emit(InteroperableBroadcast::forward_type, InteroperableBroadcast::ForwardType::CDS_RELAY);
        } else if (InteroperableBroadcast::amIborderNode()) {
          fwdMsg = true;
          emit(InteroperableBroadcast::forward_type, InteroperableBroadcast::ForwardType::BORDER_NODE);
        }

        if (fwdMsg) {
          cout << "[" << simTime() << ", " << temp << endl;
          cPacket* broadcastMsg = buildBroadcastMsg(msg->par("ReceivedMsgId").stringValue());
          socket.sendTo(broadcastMsg, InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
          emit(InteroperableBroadcast::sentBroadcastMsg, InteroperableBroadcast::getMsgId(broadcastMsg->getName()));
        }

        cancelEvent(msg);
      }
        break;
      case SEND_CTRL_MSG: {
        currentPosition = mobilityModel->getCurrentPosition();
        emit(positionAtX, currentPosition.x);
        emit(positionAtY, currentPosition.y);
        socket.sendTo(getCtrlMsg(), InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
      }
        break;
      case SCHEDULE_CTRL_MSGS: {
        sendCtrlMsg();
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

    // tag packet as received
    InteroperableBroadcast::receivedMsg.insert(pk->getName());
    alreadyDispatched.insert(pk->getName());

    socket.sendTo(pk, InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
    emit(InteroperableBroadcast::sentBroadcastMsg, InteroperableBroadcast::getMsgId(pk->getName()));
    emit(InteroperableBroadcast::forward_type, InteroperableBroadcast::ForwardType::CDS_RELAY);
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

  double t = par("sentMsgFixedDelay").doubleValue() * par("maxNodesNo").doubleValue();
  InteroperableBroadcast::scheduleEvent(SEND_CTRL_MSG, t, sCtrlMsgTimer);
  cout << "[" << simTime() << ", " << nodeId << "] next CtrlMsg at " << t << endl;

  InteroperableBroadcast::scheduleEvent(BUILD_CDS, 2 * t - InteroperableBroadcast::sentMsgDelay, buildCdsTimer);

  cout << "[" << simTime() << ", " << nodeId << "] next BuildCdsMsg at " << 2 * t - InteroperableBroadcast::sentMsgDelay
      << endl;
}

cPacket* MPR::getCtrlMsg() {
  MprPacket* ctrlMsg = new MprPacket("CtrlMsg");
  InteroperableBroadcast::addPacketType(ctrlMsg, UdpPacket::CTRL);
  InteroperableBroadcast::addPacketHeaders(ctrlMsg);

  ctrlMsg->setSenderPosAtX(InteroperableBroadcast::currentPosition.x);
  ctrlMsg->setSenderPosAtY(InteroperableBroadcast::currentPosition.y);

  MprNeighbors myNeigs;
  MprCoord positionsAtX;
  MprCoord positionsAtY;

  string temp(nodeId + "] Current neighbors : ");
  for (auto it = neighbors.begin(); it != neighbors.end(); ++it) {
    temp += it->first + ",";
    myNeigs.insert(it->first);
    positionsAtX[it->first] = neigsPositions[it->first].x;
    positionsAtY[it->first] = neigsPositions[it->first].y;
  }
  cout << "[" << simTime() << temp << endl;
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
