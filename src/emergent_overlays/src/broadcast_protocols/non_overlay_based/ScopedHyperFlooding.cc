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

#include <ScopedHyperFlooding.h>
#include <common/InteroperableBroadcast.h>
#include <msgs/Basic_m.h>

bool ScopedHyperFlooding::isProtocolEvent(cMessage* msg) {
  return msg == sendCtrlMsgTimer;
}

bool ScopedHyperFlooding::onBroadcastMsg(cPacket* pk, const char* pkName) {
  bool firstReception = false;
  MprBroadcastPacket* m = dynamic_cast<MprBroadcastPacket*>(pk);
  if (controller->receivedMsg.find(pkName) == controller->receivedMsg.end() && m != nullptr) {
    // tag packet as received
    firstReception = true;
    controller->receivedMsg.insert(pkName);
    set<string>::iterator it;
    string temp("my neighbors are: ");
    for (it = neighbors.begin(); it != neighbors.end(); ++it) {
      temp += *it + ", ";
    }
    controller->log(temp);
    OneHopNeigs senderNeigs = m->getNeighbors();
    temp = "sender neighbors: ";
    double atMyList = 0;
    for (it = senderNeigs.begin(); it != senderNeigs.end(); ++it) {
      temp += *it + ", ";
      if (neighbors.find(*it) != neighbors.end())
        atMyList += 1.0;
    }
    controller->log(temp);
    double similarity = atMyList / (neighbors.size() * 1.0);
    controller->log("Similarity:" + to_string(similarity));
    if (similarity < neigSimilarity) {
      controller->emit(controller->forward_type, controller->SIMPLE);
      cPacket* broadcastMsg = createBroadcastMsg(pkName);
      controller->fwdBroadcastMsg(broadcastMsg);
    }
    neighbors.clear();
  }
  return firstReception;
}

void ScopedHyperFlooding::handleEvent(cMessage* msg) {
  switch (msg->getKind()) {
    case SEND_CTRL_MSG: {
      controller->send(getCtrlMsg());
      controller->scheduleEvent(SEND_CTRL_MSG, controller->par("ctrlMsgInterval").doubleValue(), sendCtrlMsgTimer);
    }
      break;
    default:
      throw cRuntimeError("Invalid kind %d in ScopedHyperFlooding.handleEvent", (int) msg->getKind());
  }
}

void ScopedHyperFlooding::cancelSelfEvents() {
  controller->cancelEvent(sendCtrlMsgTimer);
}

void ScopedHyperFlooding::initialize(bool firstCall) {
  controller->log("Running protocol: " + controller->getProtocolName(controller->HYPER_SCOPED_FLOODING));

  int n = controller->turnNodeIdToInt();
  int nodesNo = controller->par("nodesNo").longValue();
  neigSimilarity = controller->par("neigSimilarity").doubleValue();
  // unique value per node to delay delivery of messages and avoid collisions
  minSentDelay = controller->par("minSentDelay").doubleValue();
  sentCtrlMsgDelay = ((n - 1) % nodesNo) * minSentDelay;
  controller->log("My delay is: " + to_string(sentCtrlMsgDelay));

  double t = controller->par("startSendingCtrlMsgs").doubleValue() + sentCtrlMsgDelay;
  controller->log("start sending ctrlMsgs at: " + to_string(t));
  // build first overlay before dissemination of broadcast messages
  controller->scheduleEvent(SEND_CTRL_MSG, t, sendCtrlMsgTimer);

}

void ScopedHyperFlooding::onControlMsg(cPacket* pk, const char* sender) {
  controller->log("ctrl message from:" + string(sender));
  neighbors.insert(sender);
}

cPacket* ScopedHyperFlooding::createBroadcastMsg(const char* msgId) {
  MprBroadcastPacket* payload = new MprBroadcastPacket(msgId);
  payload->setRunningProtocol(controller->HYPER_SCOPED_FLOODING);
  controller->addBroadcastHeaders(payload);

  OneHopNeigs myNeigs;
  for (set<string>::iterator it = neighbors.begin(); it != neighbors.end(); ++it)
    myNeigs.insert(*it);
  myNeigs.insert(controller->nodeId);
  payload->setNeighbors(myNeigs);

  return payload;
}

int ScopedHyperFlooding::getFwdType() {
  return controller->SIMPLE;
}

bool ScopedHyperFlooding::amIoverlayRelay() {
  return false;
}

cPacket* ScopedHyperFlooding::getCtrlMsg() {
  ctrlMsgId++;
  string name = controller->ctrlMsgName + to_string(ctrlMsgId);
  Basic* ctrlMsg = new Basic(name.c_str());
  ctrlMsg->setRunningProtocol(controller->HYPER_SCOPED_FLOODING);
  controller->addCtrlHeaders(ctrlMsg);
  return ctrlMsg;
}
