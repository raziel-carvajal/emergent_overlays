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
    borderMsgTimer = new cMessage("borderMsgTimer");
  }
}

void InteroperableBroadcast::processStart() {

  runningAlgorithm = getContainingNode(this)->getModuleByPath(".udpApp[0]")->getClassName();
  const char* id = getParentModule()->getFullName();
  nodeId = id;
  EV << "Running algorithm [" << runningAlgorithm << "] in node [" << nodeId << "]" << endl;
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
  int N = par("maxNodesNo").longValue();
  sentMsgDelay = ((n - 1) % N) * par("sentMsgFixedDelay").doubleValue();

  EV << simTime() << ", " << nodeId << " :: sentMsgDelay = " << sentMsgDelay << endl;

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
  scheduleEvent(Timer::SEND_BROADCAST_MSG, par("sendInterval").doubleValue(), broaMsgTimer);
  // first broadcast session starts with ID = 1
  UDPBasicApp::numSent = 1;

  // schedule ctrlMsg
  if (par("withCtrlMsg").boolValue())
    scheduleEvent(Timer::SEND_CTRL_MSG, par("startSendingCtrlMsgs").doubleValue() + sentMsgDelay, ctrlMsgTimer);

  // schedule event to end the simulation in all peers
  scheduleEvent(Timer::HALT_APP, par("stopTime").doubleValue(), haltSimTimer);
  // store nodes positions to get ground truth at roughly the same
  // interval broadcast messages are sent
  scheduleEvent(Timer::STORE_POSITION, par("sendInterval").doubleValue() - par("sentMsgFixedDelay").doubleValue(),
      motionTimer);
}

void InteroperableBroadcast::sendPacket() {
  // TODO implement multiple sources as follows:
  // - create a configuration file where source nodes were chosen randomly
  //   before an experiment starts; lines of this file: <SESSION_ID> <NODE_ID>
  if (par("isSource").boolValue()) {
    ostringstream pkName;
    pkName << this->packetName + to_string(numSent);
    EV_DEBUG << "new broadcast session, BroadcastMsgId=" << pkName.str() << endl;

    // setting up packet
    cPacket* payload = new cPacket(pkName.str().c_str());
    payload->setByteLength(par("messageLength").longValue());
    addPacketType(payload, UdpPacket::BROADCAST);
    addPacketHeaders(payload);

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
      case Timer::SEND_BROADCAST_MSG: {
        // call sendPacket() every par("sendInterval") seconds to perform one broadcast session; see event UDPBasicApp::SEND
        UDPBasicApp::processSend();
      }
        break;
      case Timer::SEND_FOREIGN_MSG: {
        socket.sendTo(makeForeignMessage(), broadcastAddress, destPort);
      }
        break;
      case Timer::SEND_CTRL_MSG: {
        knownForeignAlgos.clear();
        initializeState();
        sendCtrlMsg();
        cancelEvent(msg);
        if (par("withCtrlMsg").boolValue())
          scheduleEvent(Timer::SEND_CTRL_MSG, par("ctrlMsgInterval").doubleValue(), ctrlMsgTimer);
      }
        break;
      case Timer::FWD_BROADCAST_MSG: {
        socket.sendTo(latestPkToFwd, broadcastAddress, destPort);
        emit(sentBroadcastMsg, getMsgId(latestPkToFwd->getName()));
        emit(InteroperableBroadcast::forward_type, InteroperableBroadcast::ForwardType::SIMPLE);
      }
        break;
        // this event is useful to build the wireless topology (ground truth) that is
        // formed during the dissemination of every broadcast message
      case Timer::STORE_POSITION: {
        currentPosition = mobilityModel->getCurrentPosition();
        emit(positionAtX, currentPosition.x);
        emit(positionAtY, currentPosition.y);

        scheduleEvent(Timer::STORE_POSITION, par("sendInterval").doubleValue(), motionTimer);
      }
        break;
      case Timer::HALT_APP: {
        EV << "End of simulation from peer: " << nodeId << endl;
        if (broaMsgTimer)
          cancelAndDelete(broaMsgTimer);
        if (ctrlMsgTimer)
          cancelAndDelete(ctrlMsgTimer);
        if (borderMsgTimer)
          cancelAndDelete(borderMsgTimer);
        if (fwdBMsgTimer)
          cancelAndDelete(fwdBMsgTimer);
        if (motionTimer)
          cancelAndDelete(motionTimer);

        cancelAndDelete(haltSimTimer);
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
  // avoid when sender and receiver are the same peer
  if (getSrcAddress(pk) == localAddress) {
    delete pk;
    return;
  }
  string sender(removeQuotes(pk->par("Sender").str()));
  EV_DEBUG << "Message [" << pk->getName() << "] received from [" << sender << "]" << endl;
  switch (pk->par("PkType").longValue()) {
    case UdpPacket::BROADCAST: {
      // record all received broadcast messages
      emit(rcvdBroadcastMsg, getMsgId(pk->getName()));
      // count received broadcast messages
      UDPBasicApp::numReceived++;
      // each algorithm deal with the reception of [pk]
      onBroadcastMsg(pk, sender);
    }
      break;
    case UdpPacket::CTRL: {
      // all control messages must contain the parameter: SendersRunningAlgo
      string senderRunningAlgo(removeQuotes(pk->par("SendersRunningAlgo").str()));

      // control message received from a foreign algorithm, i. e., sender is a border node
      if (enableInterop && runningAlgorithm != senderRunningAlgo) {
        bool isKnown = knownForeignAlgos.find(senderRunningAlgo) != knownForeignAlgos.end();
        if (!isKnown) {
          knownForeignAlgos.insert(senderRunningAlgo);
          scheduleEvent(Timer::SEND_FOREIGN_MSG, par("sentMsgFixedDelay").doubleValue(), borderMsgTimer);
        }
      }
      // this method isn't implemented for those algorithms
      // that do not deal with exchange of control messages
      onControlMsg(pk, sender);
    }
      break;
    case UdpPacket::FOREIGN: {
      string senderRunningAlgo(removeQuotes(pk->par("SendersRunningAlgo").str()));
      if (runningAlgorithm != senderRunningAlgo) {
        knownForeignAlgos.insert(senderRunningAlgo);
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

void InteroperableBroadcast::addPacketHeaders(cPacket* c) {
  addSender(c);
  addSendersRunningAlgo(c);
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
  latestPkToFwd->getParList().remove("SendersRunningAlgo");
  addPacketHeaders(latestPkToFwd);

  scheduleEvent(Timer::FWD_BROADCAST_MSG, par("sentMsgFixedDelay").doubleValue(), fwdBMsgTimer);
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
      || borderMsgTimer == msg;
}

void InteroperableBroadcast::cancelSelfEvents() {
  throw cRuntimeError("Every subclass of InteroperableBroadcast should implement cancelSelfEvents()");
}

void InteroperableBroadcast::initializeState() {
  throw cRuntimeError(
      "Every subclass of InteroperableBroadcast, which exchange control messages, should implement initializeState()");
}

void InteroperableBroadcast::sendCtrlMsg() {
  throw cRuntimeError(
      "Every subclass of InteroperableBroadcast, which exchange control messages, should implement sendCtrlMsg()");
}

cPacket* InteroperableBroadcast::makeForeignMessage() {
  cPacket* fMsg = new cPacket("ForeignMsg");
  fMsg->setByteLength(par("ctrlMessageLength").longValue());

  addPacketType(fMsg, UdpPacket::FOREIGN);
  addPacketHeaders(fMsg);
  return fMsg;
}
