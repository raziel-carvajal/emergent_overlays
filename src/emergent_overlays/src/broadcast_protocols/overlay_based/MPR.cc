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

#include <MPR.h>
#include <common/InteroperableBroadcast.h>
#include <msgs/Basic_m.h>
#include <algorithm>

void Mpr::onBroadcastMsg(cPacket* pk, const char* pkName) {
  MprBroadcastPacket* m = dynamic_cast<MprBroadcastPacket*>(pk);
  if (controller->receivedMsg.find(pkName) == controller->receivedMsg.end() && m != nullptr) {
    controller->log("1st reception, schedule FWD in " + to_string(controller->sentMsgFixedDelay));
    // tag packet as received
    controller->receivedMsg.insert(pkName);
    latestPayload.clear();
    OneHopNeigs senderNeigs = m->getNeighbors();
    for (OneHopNeigs::iterator it = senderNeigs.begin(); it != senderNeigs.end(); ++it) {
      latestPayload.insert(*it);
    }
    // schedule FWD decision
    fwdBrMsgTimer->getParList().remove("ReceivedMsgId");
    cMsgPar* p = new cMsgPar("ReceivedMsgId");
    p->setStringValue(pkName);
    fwdBrMsgTimer->addPar(p);
    controller->scheduleEvent(FWD_BROADCAST_MSG, controller->sentMsgFixedDelay, fwdBrMsgTimer);
  }

}

void Mpr::initialize() {
  controller->log("Running protocol: " + controller->getProtocolName(controller->MPR));

  cMsgPar* p = new cMsgPar("ReceivedMsgId");
  p->setStringValue("");
  fwdBrMsgTimer->addPar(p);

  double t = controller->sentMsgDelay + controller->sentMsgFixedDelay;
  // build first overlay before dissemination of broadcast messages
  controller->scheduleEvent(SCHEDULE_FIRST_CTRL_MSG, t, sCtrlMsgTimer);
  // build remaining overlays
  controller->scheduleEvent(SCHEDULE_CTRL_MSGS,
      controller->par("startSendingCtrlMsgs").doubleValue() + controller->sentMsgDelay, sRemainingCtrlMsgTimer);
}

cPacket* Mpr::createBroadcastMsg(const char* msgId) {

  MprBroadcastPacket* payload = new MprBroadcastPacket(msgId);
  payload->setRunningProtocol(controller->MPR);
  controller->addBroadcastHeaders(payload);

  OneHopNeigs myNeigs;
  for (set<string>::iterator it = currentMpr.begin(); it != currentMpr.end(); ++it)
    myNeigs.insert(*it);
  payload->setNeighbors(myNeigs);

  return payload;
}

set<string> Mpr::compute_mpr() {
  set<string> mpr;
  map<string, set<string>> latest = make_cpy(neighbors);
  hops[0].clear();
  hops[1].clear();
  // first fill the array hops
  for (const auto& p : latest) {
    string j(p.first);
    hops[0].insert(j);
    for (const auto& name : p.second) {
      controller->log("name [" + name + "] && nodeId [" + controller->nodeId + "]");
      if (name == controller->nodeId)
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

bool Mpr::amIrelay(set<string> senderNeigs) {
  bool relay = false;
  string temp("Deciding with neighbors = { ");
  for (set<string>::iterator it = senderNeigs.begin(); !relay && it != senderNeigs.end(); ++it) {
    relay = (*it == controller->nodeId);
    temp += *it + ", ";
  }
  controller->log(temp + " }");
  isOverlayRelay = relay;
  return relay;
}

bool Mpr::is_a_covered_by_b(string a, string b) {
  inet::Coord pA = neigsPositions[a];
  inet::Coord pB = neigsPositions[b];
  return sqrt((pA.x - pB.x) * (pA.x - pB.x) + (pA.y - pB.y) * (pA.y - pB.y)) <= controller->transRadious;
}

bool Mpr::isProtocolEvent(cMessage* msg) {
  return buildCdsTimer == msg || sCtrlMsgTimer == msg || fwdBrMsgTimer == msg || sRemainingCtrlMsgTimer == msg;
}

void Mpr::handleEvent(cMessage* msg) {
  switch (msg->getKind()) {
    // time required to approximate a CDS is ~0.5s
    case BUILD_CDS: {
      currentMpr = compute_mpr();
      string temp("My CDS is = ");
      for (set<string>::iterator it = currentMpr.begin(); it != currentMpr.end(); ++it)
        temp += *it + ", ";
      controller->log(temp);
    }
      break;
    case FWD_BROADCAST_MSG: {
      string msgId = msg->par("ReceivedMsgId").stringValue();
      string temp("FWD message: " + msgId);

      bool fwdMsg = false;
      if (amIrelay(latestPayload)) {
        fwdMsg = true;
        controller->isBorderNode = false;
        controller->emit(controller->forward_type, controller->OVERLAY_RELAY);
      } else if (controller->isBorderNode) {
        fwdMsg = true;
        controller->emit(controller->forward_type, controller->BORDER_NODE);
      }

      if (fwdMsg) {
        controller->log(temp);
        cPacket* broadcastMsg = createBroadcastMsg(msgId.c_str());
        controller->send(broadcastMsg);
        controller->emit(controller->sentBroadcastMsg, controller->getMsgId(msgId));
      }
    }
      break;
    case SEND_CTRL_MSG: {
      controller->send(getCtrlMsg(1));
    }
      break;
    case SCHEDULE_FIRST_CTRL_MSG: {
      sendCtrlMsg();
    }
      break;
    case SCHEDULE_CTRL_MSGS: {
      sendCtrlMsg();
      controller->scheduleEvent(SCHEDULE_CTRL_MSGS, controller->par("ctrlMsgInterval").doubleValue(),
          sRemainingCtrlMsgTimer);
    }
      break;
    default:
      throw cRuntimeError("Invalid kind %d in Mpr.buildCdsTimer", (int) msg->getKind());
  }
}

void Mpr::sendCtrlMsg() {
  neighbors.clear();
  neigsPositions.clear();
  controller->cancelEvent(sCtrlMsgTimer);
  controller->cancelEvent(buildCdsTimer);
  // use to get the list of one-hop neighbors
  controller->send(getCtrlMsg(0));
  double t = controller->sentMsgFixedDelay * controller->maxNodesNo;
  // use to get the list of two-hop neighbors
  controller->scheduleEvent(SEND_CTRL_MSG, t, sCtrlMsgTimer);
  controller->log("next CtrlMsg at " + to_string(t));
  // approximation of a CDS when nodes have the list of two-hop neighbors
  controller->scheduleEvent(BUILD_CDS, 2 * t - controller->sentMsgDelay, buildCdsTimer);
  controller->log("next BuildCdsMsg at " + to_string(2 * t - controller->sentMsgDelay));
}

cPacket* Mpr::getCtrlMsg(int withName) {
  MprCtrl* m = nullptr;
  if (withName == 1) {
    m = new MprCtrl(controller->foreignPkName.c_str());
  } else {
    m = new MprCtrl();
  }
  m->setRunningProtocol(controller->MPR);
  controller->addCtrlHeaders(m);

  inet::Coord pos = controller->mobilityModel->getCurrentPosition();
  m->setSenderPosAtX(pos.x);
  m->setSenderPosAtY(pos.y);

  OneHopNeigs myNeigs;
  Positions positionsAtX;
  Positions positionsAtY;

  string temp("Current neighbors: ");
  for (auto it = neighbors.begin(); it != neighbors.end(); ++it) {
    temp += it->first + ",";
    myNeigs.insert(it->first);
    positionsAtX[it->first] = neigsPositions[it->first].x;
    positionsAtY[it->first] = neigsPositions[it->first].y;
  }
  controller->log(temp);

  m->setNeighbors(myNeigs);
  m->setXs(positionsAtX);
  m->setYs(positionsAtY);

  return m;
}

void Mpr::onControlMsg(cPacket* pk, const char* sender) {
  MprCtrl* m = dynamic_cast<MprCtrl*>(pk);
  if (m != nullptr) {
    neighbors[sender].clear();
    neigsPositions[sender].x = m->getSenderPosAtX();
    neigsPositions[sender].y = m->getSenderPosAtY();

    OneHopNeigs senderNeigs = m->getNeighbors();
    Positions neigsPosAtX = m->getXs();
    Positions neigsPosAtY = m->getYs();
    string temp("neighbors received from [" + string(sender) + "] ");

    for (OneHopNeigs::iterator it = senderNeigs.begin(); it != senderNeigs.end(); ++it) {
      if (*it != controller->nodeId) {
        temp += *it + ", ";
        neighbors[sender].insert(*it);
        neigsPositions[*it].x = neigsPosAtX[*it];
        neigsPositions[*it].y = neigsPosAtY[*it];
      }
    }
    controller->log(temp);
  }
}

void Mpr::cancelSelfEvents() {
  controller->cancelAndDelete(buildCdsTimer);
  controller->cancelAndDelete(fwdBrMsgTimer);
  controller->cancelAndDelete(sCtrlMsgTimer);
}

int Mpr::getFwdType() {
  return controller->OVERLAY_RELAY;
}

bool Mpr::amIoverlayRelay() {
  return isOverlayRelay;
}
