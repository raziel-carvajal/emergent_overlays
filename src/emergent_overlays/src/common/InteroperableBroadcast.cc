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

#include <common/InteroperableBroadcast.h>

#include <inet/networklayer/common/L3AddressResolver.h>
//#include <inet/transportlayer/contract/udp/UDPControlInfo_m.h>
#include <inet/physicallayer/idealradio/IdealTransmitter.h>
#include <inet/common/geometry/common/Coord.h>
#include <inet/common/ModuleAccess.h>

Define_Module(InteroperableBroadcast);

simsignal_t InteroperableBroadcast::rcvdBroadcastMsg = registerSignal("rcvdBroadcastMsg");
simsignal_t InteroperableBroadcast::sentBroadcastMsg = registerSignal("sentBroadcastMsg");

simsignal_t InteroperableBroadcast::positionAtX = registerSignal("positionAtX");
simsignal_t InteroperableBroadcast::positionAtY = registerSignal("positionAtY");

simsignal_t InteroperableBroadcast::forward_type = registerSignal("forward_type");
//simsignal_t InteroperableBroadcast::density_approximation = registerSignal("density_approximation");

void InteroperableBroadcast::initialize(int stage) {
  EV << "DOING INITIALIZE" << endl;
  UDPBasicApp::initialize(stage);
  if (stage == inet::INITSTAGE_LOCAL) {
    ctrlMsgTimer = new cMessage("ctrlMsgTimer");
    haltSimTimer = new cMessage("haltSimTimer");
    broaMsgTimer = new cMessage("broaMsgTimer");
    motionTimer = new cMessage("motionTimer");
    fwdBMsgTimer = new cMessage("fwdBMsgTimer");
  }
}

void InteroperableBroadcast::processStart() {

  runningAlgorithm = getContainingNode(this)->getModuleByPath(".udpApp[0]")->getClassName();
  const char* id = getParentModule()->getFullName();
  nodeId = id;
  EV_DEBUG << "Running algorithm [" << runningAlgorithm << "] in node [" << nodeId << "]" << endl;
  // nodes identifiers start with an alphabetic character
  bool isNumeric = false;
  int i = 0;
  while (!isNumeric) {
    if (!isalpha(nodeId[i]))
      isNumeric = true;
    else
      i++;
  }
  // get numeric substring from node identifier
  std::string::size_type sz;
  int n = stoi(nodeId.substr(i, nodeId.size()), &sz);
  // unique value per node identifier (i.e. the value for this attribute isn't the same, for any pair of nodes)
  sentMsgDelay = (n % par("maxNodesNo").longValue()) * par("sentMsgFixedDelay").doubleValue();

  physicallayer::IdealTransmitter* transmitter = check_and_cast<physicallayer::IdealTransmitter*>(
      getContainingNode(this)->getModuleByPath(".wlan[0].radio.transmitter"));
  transRadious = transmitter->getMaxCommunicationRange().get();

  enableInterop = par("enableInterop").boolValue();

  mobilityModel = check_and_cast<IMobility*>(getContainingNode(this)->getSubmodule("mobility"));
  // store initial position in case an algorithm requires node's position
  currentPosition = mobilityModel->getCurrentPosition();
  emit(positionAtX, currentPosition.x);
  emit(positionAtY, currentPosition.y);

  localAddress = L3AddressResolver().resolve(id);

  socket.setOutputGate(gate("udpOut"));
  socket.bind(localAddress, localPort);
  setSocketOptions();

  L3AddressResolver().tryResolve(par("destAddresses"), broadcastAddress);
  if (broadcastAddress.isUnspecified())
    throw cRuntimeError("invalid broadcast address");

  // schedule first broadcast session
  scheduleEvent(Timer::BROADCAST_SESSION, par("sendInterval").doubleValue(), broaMsgTimer);

  // schedule ctrlMsg
  if (par("withCtrlMsg").boolValue())
    scheduleEvent(Timer::SEND_CTRL_MSG, par("ctrlMsgInterval").doubleValue(), ctrlMsgTimer);

  // schedule event to end the simulation in all peers
  scheduleEvent(Timer::HALT_APP, par("stopTime").doubleValue(), haltSimTimer);
  // timer to store nodes position and density, when nodes move
  scheduleEvent(Timer::MOTION, par("motionInterval").doubleValue(), motionTimer);
}

void InteroperableBroadcast::sendPacket() {
  // TODO implement multiple sources as follows:
  // - create a configuration file where source nodes were chosen randomly
  //   before an experiment starts; lines of this file: <SESSION_ID> <NODE_ID>
  if (par("isSource").boolValue()) {
    ostringstream pkName;
    pkName << this->packetName + to_string(numSent);
    EV << "new broadcast session, BroadcastMsgId=" << pkName.str() << endl;

    // setting up packet
    cPacket* payload = new cPacket(pkName.str().c_str());
    payload->setByteLength(par("messageLength").longValue());
    addPacketType(payload, UdpPacket::BROADCAST);
    addSender(payload);
    // send now
    socket.sendTo(payload, broadcastAddress, destPort);
    emit(sentBroadcastMsg, getMsgId(payload->getName()));

    // tag packet as received
    receivedMsg.insert(pkName.str());
  }
  // count sent broadcast messages in all nodes. This is useful in an experiment
  // where any node in the network act as source of a broadcast session
  UDPBasicApp::numSent++;
}

void InteroperableBroadcast::handleMessageWhenUp(cMessage* msg) {
  if (msg->isSelfMessage() && isSelfTimer(msg)) {
    switch (msg->getKind()) {
      // TODO add a procedure to chose in a random way the node that initiates a broadcast session
      // 			every time the SEND_BROADCAST timer reaches zero
      case Timer::BROADCAST_SESSION: {
        // call sendPacket() periodically, every par("sendInterval") seconds,
        // to perform one broadcast session; see event UDPBasicApp::SEND
        UDPBasicApp::processSend();

      }
        break;
      case Timer::FWD_BROADCAST_MSG: {
        socket.sendTo(latestPkToFwd, broadcastAddress, destPort);
        emit(sentBroadcastMsg, getMsgId(latestPkToFwd->getName()));
        emit(InteroperableBroadcast::forward_type, InteroperableBroadcast::ForwardType::SIMPLE);
      }
        break;
      case Timer::SEND_CTRL_MSG: {
        sendCtrlMsg();
        cancelEvent(msg);
        if (par("withCtrlMsg").boolValue())
          scheduleEvent(Timer::SEND_CTRL_MSG, par("ctrlMsgInterval").doubleValue(), ctrlMsgTimer);
      }
        break;
      case Timer::MOTION: {
        // TODO store density
        currentPosition = mobilityModel->getCurrentPosition();
        emit(positionAtX, currentPosition.x);
        emit(positionAtY, currentPosition.y);
        // emit(<density>, ?);
        scheduleEvent(Timer::MOTION, par("motionInterval").doubleValue(), motionTimer);
      }
        break;
      case Timer::BORDER_DETECTOR: {
        string tmp(msg->getName());
        // remove substring [bd-timer-] to get algorithm name
        string foreignAlgo(splitString("bd-timer-", tmp));
        EV_DEBUG << "border-detector timer expires for algorithm: " << foreignAlgo << endl;

        bool emptyCandidatesSet = knownForeignNodes.find(foreignAlgo) != knownForeignNodes.end()
            && knownForeignNodes[foreignAlgo].empty();
        if (emptyCandidatesSet) {
          EV_ERROR << "Any border node will be chosen!" << endl;
          cancelAndDelete(msg);
        } else {
          /* Policy to select a border node. Suggestions:
           * - piggyback stored energy of nodes to chose that node
           *   with the highest value as border node
           * Currently, choosing a border node follows a first-received-first-chosen rule
           * OPEN QUESTIONS
           *   - how to up date this set of potential border nodes?
           *   - mobility has an impact on this decision
           */
          set<string>::iterator it = knownForeignNodes[foreignAlgo].begin();
          string chosenNode(*it);
          EV_DEBUG << "Chosen border node [" << chosenNode << "]" << endl;

          cPacket* borderMsg = makeBorderMessage(foreignAlgo.c_str(), chosenNode.c_str(),
              par("hopsToLive").doubleValue());
          socket.sendTo(borderMsg, broadcastAddress, destPort);

          // delete local border-detector timer
          cancelAndDelete(borderNodeTimers[foreignAlgo]);
          borderNodeTimers.erase(borderNodeTimers.find(foreignAlgo));
          // mark as already received
          receivedBorderMsgs.insert(foreignAlgo);
        }

      }
        break;
      case Timer::HALT_APP: {
        EV << "End of simulation from peer: " << nodeId << endl;
        if (broaMsgTimer)
          cancelAndDelete(broaMsgTimer);
        if (ctrlMsgTimer)
          cancelAndDelete(ctrlMsgTimer);
        cancelAndDelete(haltSimTimer);
        cancelAndDelete(motionTimer);
        if (fwdBMsgTimer)
          cancelAndDelete (fwdBMsgTimer);
        // cancel events from sub-classes
        cancelSelfEvents();
        endSimulation();
      }
        break;
      default:
        throw cRuntimeError("Invalid kind %d in selfInteropMsg", (int) msg->getKind());
    }
  } else
    UDPBasicApp::handleMessageWhenUp(msg);

}

void InteroperableBroadcast::processPacket(cPacket* pk) {
  // avoid receiving broadcast/control messages from local node
  if (getSrcAddress(pk) == localAddress) {
    delete pk;
    return;
  }
  string sender(removeQuotes(pk->par("Sender").str()));
  EV_DEBUG << "Broadcast message [" << pk->getName() << "] received from [" << sender << "]" << endl;
  switch (pk->par("PkType").longValue()) {
    case UdpPacket::BROADCAST: {
      // record all received broadcast messages
      emit(rcvdBroadcastMsg, getMsgId(pk->getName()));
      // count received broadcast messages
      UDPBasicApp::numReceived++;
      if (receivedMsg.find(pk->getName()) == receivedMsg.end()) {
        // tag packet as received
        receivedMsg.insert(pk->getName());
        // each algorithm deal with the reception of [pk]
        onBroadcastMsg(pk, sender);
      } else
        EV_DEBUG << "Broadcast message [" << pk->getName() << "] ignored" << endl;
    }
      break;
    case UdpPacket::CTRL: {
      string senderRunningAlgo(removeQuotes(pk->par("SendersRunningAlgo").str()));
      if (enableInterop) {
        // all control messages must contain the parameter: SendersRunningAlgo
        detectBorderNode(sender, senderRunningAlgo);
      }
      // TODO deal with the situation when the received ctrl message
      // cames from a sender running a different algorithm than the local node
      // bool isMprPk =
      onControlMsg(pk, sender);

    }
      break;
    case UdpPacket::BORDER: {
      /* Here we distinguish between 2 cases:
       * TODO complete documentation
       */
      string senderForeignAlgo(removeQuotes(pk->par("foreignAlgoPar").str()));
      string senderRunningAlgo(removeQuotes(pk->par("SendersRunningAlgo").str()));
      string chosenBorderNode(removeQuotes(pk->par("borderNodeId").str()));
      double hopsToLive(pk->par("hopsToLive").doubleValue());
      EV_DEBUG << "Meta-data of Border message" << endl;
      EV_DEBUG << "senderForeignAlgo: [" << senderForeignAlgo << "]" << endl;
      EV_DEBUG << "senderRunningAlgo: [" << senderRunningAlgo << "]" << endl;
      EV_DEBUG << "chosenBorderNode: [" << chosenBorderNode << "]" << endl;
      EV_DEBUG << "hopsToLive: [" << hopsToLive << "]" << endl;

      if (receivedBorderMsgs.find(senderForeignAlgo) != receivedBorderMsgs.end()) {
        EV_DEBUG << "BorderMsg already received [" << senderForeignAlgo << "]" << endl;
        break;
      }
      receivedBorderMsgs.insert(senderForeignAlgo);

      if (!amIborderNode && runningAlgorithm == senderForeignAlgo && nodeId == chosenBorderNode) {
        EV_DEBUG << "Node [" << nodeId << "] is border node" << endl;
        amIborderNode = true;
      }

      bool ongoingTimer = borderNodeTimers.find(senderForeignAlgo) != borderNodeTimers.end();
      if (ongoingTimer && borderNodeTimers[senderForeignAlgo] != nullptr) {
        // delete ongoing border-detector timer
        cancelAndDelete(borderNodeTimers[senderForeignAlgo]);
        borderNodeTimers.erase(borderNodeTimers.find(senderForeignAlgo));
        /* INFO remove candidates of being border nodes.
         *   This measure is a little bit drastic because
         *   the set could be reuse later. On the other hand,
         *   this a way to deal with mobility.
         */
        knownForeignNodes[senderForeignAlgo].clear();
      }

      if (hopsToLive > 0) {
        EV_DEBUG << "HopsToLive > 0, forwarding border message" << endl;
        cPacket* borderMsg = makeBorderMessage(senderForeignAlgo.c_str(), chosenBorderNode.c_str(), hopsToLive - 1);
        socket.sendTo(borderMsg, broadcastAddress, destPort);
      }

    }
      break;
    default:
      throw cRuntimeError("Invalid kind of msg %d in self message", (int) pk->getKind());
  }
  delete pk;
}

L3Address InteroperableBroadcast::getSrcAddress(cPacket* msg) {
  return check_and_cast<UDPDataIndication *>(msg->getControlInfo())->getSrcAddr();
}

void InteroperableBroadcast::scheduleEvent(short kind, double delay, cMessage* selfMsgPtr) {
  simtime_t t = simTime() + delay;
  selfMsgPtr->setKind(kind);
  scheduleAt(t, selfMsgPtr);
}

void InteroperableBroadcast::onControlMsg(cPacket* pk, string sender) {
  /* TODO missing features:
   * -  senders of ctrl messages may run a protocol different than
   * 		the one running at the receiver; this is THE trigger to
   * 		start the selection of a border node
   */
}

int InteroperableBroadcast::getMsgId(const char* msgHeader) {
  string pkName(this->packetName);
  string msgHea(msgHeader);
  string::size_type st;
  return stoi(msgHea.substr(pkName.size(), msgHea.size()), &st);
}

void InteroperableBroadcast::addPacketType(cPacket* msg, long l) {
  cMsgPar* p = new cMsgPar("PkType");
  p->setLongValue(l);
  msg->addPar(p);
}

void InteroperableBroadcast::addSendersRunningAlgo(cPacket* pk) {
  cMsgPar* p = new cMsgPar("SendersRunningAlgo");
  p->setStringValue(runningAlgorithm.c_str());
  pk->addPar(p);
}

void InteroperableBroadcast::addSender(cPacket* pk) {
  cMsgPar* p = new cMsgPar("Sender");
  p->setStringValue(getParentModule()->getFullName());
  pk->addPar(p);
}

void InteroperableBroadcast::onBroadcastMsg(cPacket* pk, string sender) {
  /* TODO missing features:
   * -  senders of broadcast messages may run a protocol different than
   * 		the one running at the receiver
   */
  throw cRuntimeError("Every subclass of InteroperableBroadcast should implement onBroadcastMsg()");
}

void InteroperableBroadcast::fwdBroadcastMsg(cPacket* pk) {
  latestPkToFwd = pk->dup();
// replace sender
  latestPkToFwd->getParList().remove("Sender");
  addSender (latestPkToFwd);
  scheduleEvent(Timer::FWD_BROADCAST_MSG, par("sentMsgRandDelay").doubleValue(), fwdBMsgTimer);
}

cPacket* InteroperableBroadcast::getCtrlMsg() {
  cPacket* ctrlMsg = new cPacket("CtrlMsg");
  addPacketType(ctrlMsg, UdpPacket::CTRL);
  addSender(ctrlMsg);
  addSendersRunningAlgo(ctrlMsg);
  return ctrlMsg;
}

bool InteroperableBroadcast::isSelfTimer(cMessage* msg) {
  return ctrlMsgTimer == msg || haltSimTimer == msg || broaMsgTimer == msg || motionTimer == msg || fwdBMsgTimer == msg
      || isBorderDetectorTimer(msg);
}

void InteroperableBroadcast::cancelSelfEvents() {
  throw cRuntimeError("Every subclass of InteroperableBroadcast should implement cancelSelfEvents()");
}

bool InteroperableBroadcast::isBorderDetectorTimer(cMessage* msg) {
  return msg->getKind() == Timer::BORDER_DETECTOR;
}

void InteroperableBroadcast::detectBorderNode(string sender, string sendersAlgo) {
  if (runningAlgorithm != sendersAlgo) {
    bool knownForeignSender = knownForeignNodes.find(sendersAlgo) != knownForeignNodes.end()
        && knownForeignNodes[sendersAlgo].find(sender) != knownForeignNodes[sendersAlgo].end();
    if (!knownForeignSender) {
      EV_DEBUG << "Schedule border-detector timer for foreign algorithm " << sendersAlgo << " that expires in "
          << par("borderDetectorDelay").doubleValue() << "s" << endl;
      knownForeignNodes[sendersAlgo].insert(sender);

      string timerName("bd-timer-" + sendersAlgo);
      cMessage* timer = new cMessage(timerName.c_str());
      borderNodeTimers[sendersAlgo] = timer;

      scheduleEvent(Timer::BORDER_DETECTOR, par("borderDetectorDelay").doubleValue(), timer);
    }
  }
}

cPacket* InteroperableBroadcast::makeBorderMessage(const char* foreignAlgo, const char* chosenNode, double htl) {
  cPacket* borderMsg = new cPacket("BorderMsg");
  addPacketType(borderMsg, UdpPacket::BORDER);
  addSender(borderMsg);
  addSendersRunningAlgo(borderMsg);

// parameters to deal with interoperability procedure
  cMsgPar* foreignAlgoPar = new cMsgPar("foreignAlgoPar");
  foreignAlgoPar->setStringValue(foreignAlgo);
  cMsgPar* hopsToLive = new cMsgPar("hopsToLive");
  hopsToLive->setDoubleValue(htl);
  cMsgPar* borderNodeId = new cMsgPar("borderNodeId");
  borderNodeId->setStringValue(chosenNode);

  borderMsg->addPar(foreignAlgoPar);
  borderMsg->addPar(hopsToLive);
  borderMsg->addPar(borderNodeId);

  return borderMsg;
}

void InteroperableBroadcast::sendCtrlMsg() {
  // send a control message
  // socket.sendTo(getCtrlMsg(), broadcastAddress, destPort);
  // and schedule next control message
  // scheduleEvent(Timer::SEND_CTRL_MSG, par("ctrlMsgInterval").doubleValue(), ctrlMsgTimer);
  throw cRuntimeError(
      "Every subclass of InteroperableBroadcast, which exchange control messages, should implement sendCtrlMsg()");
}
