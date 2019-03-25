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
#include <msgs/Basic_m.h>

#include <inet/networklayer/common/L3AddressResolver.h>
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
  // set unique node ID
  const char* id = getParentModule()->getFullName();
  nodeId = id;
  bool isNumeric = false;
  int i = 0;
  while (!isNumeric) {
    if (!isalpha(nodeId[i]))
      isNumeric = true;
    else
      i++;
  }

  std::string::size_type sz;
  int n = stoi(nodeId.substr(i, nodeId.size()), &sz);
  maxNodesNo = par("maxNodesNo").longValue();
  // unique value per node to delay delivery of messages and avoid collisions
  sentMsgFixedDelay = par("sentMsgFixedDelay").doubleValue();
  sentMsgDelay = ((n - 1) % maxNodesNo) * sentMsgFixedDelay;
  log("My delay is: " + to_string(sentMsgDelay));
  // initialize mobility model and set transmission range
  physicallayer::IdealTransmitter* transmitter = check_and_cast<physicallayer::IdealTransmitter*>(
      getContainingNode(this)->getModuleByPath(".wlan[0].radio.transmitter"));
  transRadious = transmitter->getMaxCommunicationRange().get();
  mobilityModel = check_and_cast<IMobility*>(getContainingNode(this)->getSubmodule("mobility"));
  // set socket
  localAddress = L3AddressResolver().resolve(id);
  socket.setOutputGate(gate("udpOut"));
  socket.bind(localAddress, localPort);
  setSocketOptions();
  // set unique IP address
  L3AddressResolver().tryResolve(par("destAddresses"), broadcastAddress);
  if (broadcastAddress.isUnspecified())
    throw cRuntimeError("invalid broadcast address");

  // schedule a broadcast event
  scheduleEvent(Timer::SEND_BROADCAST_MSG, par("broadcastInterval").doubleValue(), broaMsgTimer);
  // schedule event to end the simulation in all peers
  scheduleEvent(Timer::HALT_APP, par("stopTime").doubleValue(), haltSimTimer);
  //
  enableInterop = par("enableInterop").boolValue();
  // initialize objects that implement broadcast protocols
  intializeCatalog();
  // initialize first running protocol
  runningProtocolId = par("runningProtocolId").longValue();
  runningProtocol = protocols[runningProtocolId];
  runningProtocol->initialize();

  // schedule ctrlMsg
//  scheduleEvent(Timer::SEND_CTRL_MSG, par("startSendingCtrlMsgs").doubleValue() + sentMsgDelay, ctrlMsgTimer);

// store nodes positions to get ground truth at roughly the same
// interval broadcast messages are sent
//  scheduleEvent(Timer::STORE_POSITION, par("sendInterval").doubleValue() - par("sentMsgFixedDelay").doubleValue(),
//      motionTimer);
}

void InteroperableBroadcast::sendPacket() {
  // TODO implement multiple sources as follows:
  // - create a configuration file where source nodes were chosen randomly
  //   before an experiment starts; lines of this file: <SESSION_ID> <NODE_ID>
  if (par("isSourceNode").boolValue()) {
    cPacket* m = setAndGetBroadcastMsg();
    log("New broadcast session [" + string(m->getName()) + "]");
    // send now
    send(m);
    emit(sentBroadcastMsg, getMsgId(m->getName()));
    // tag packet as received
    receivedMsg.insert(m->getName());
  }
}

void InteroperableBroadcast::handleMessageWhenUp(cMessage* msg) {
  try {
    UDPBasicApp::handleMessageWhenUp(msg);
  }
  catch (cException e) {
    if (isSelfTimer(msg)) {
      // event of InteroperableBroadcast object
      switch (msg->getKind()) {
        case Timer::SEND_BROADCAST_MSG: {
          // this function calls sendPacket() to send broadcast messages
          // every [par("sendInterval")] seconds
          UDPBasicApp::processSend();
        }
          break;
        case Timer::SEND_FOREIGN_MSG: {
          send(makeForeignMessage());
        }
          break;
        case Timer::SEND_CTRL_MSG: {
          knownForeignAlgos.clear();
          //          runningProtocol->initializeState();
          //          runningProtocol->sendCtrlMsg();
          cancelEvent(msg);
//          if (par("withCtrlMsg").boolValue())
//            scheduleEvent(Timer::SEND_CTRL_MSG, par("ctrlMsgInterval").doubleValue(), ctrlMsgTimer);
        }
          break;
        case Timer::FWD_BROADCAST_MSG: {
          send(latestPkToFwd);
          emit(sentBroadcastMsg, getMsgId(latestPkToFwd->getName()));
          emit(forward_type, runningProtocol->getFwdType());
        }
          break;
          // this event is useful to build the wireless topology (ground truth) that is
          // formed during the dissemination of every broadcast message
        case Timer::STORE_POSITION: {
          Coord pos = mobilityModel->getCurrentPosition();
          emit(positionAtX, pos.x);
          emit(positionAtY, pos.y);

          scheduleEvent(Timer::STORE_POSITION, par("broadcastInterval").doubleValue(), motionTimer);
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

          runningProtocol->cancelSelfEvents();
          endSimulation();
        }
          break;
        default:
          throw cRuntimeError("Invalid kind %d in selfInteropMsg 1", (int) msg->getKind());
      }
    } else if (runningProtocol->isProtocolEvent(msg)) {
      runningProtocol->handleEvent(msg);
//      cancelEvent(msg);
    } else {
      throw cRuntimeError("Invalid kind %d in selfInteropMsg 2", (int) msg->getKind());
    }
  }

}

void InteroperableBroadcast::processPacket(cPacket* pk) {
  // avoid when sender and receiver are the same peer
  if (getSrcAddress(pk) == localAddress) {
    delete pk;
    return;
  }

  string sender(removeQuotes(pk->par("Sender").str()));
  switch (pk->par("PkType").longValue()) {
    case UdpPacket::BROADCAST: {
      log("Broadcast msg [" + string(pk->getName()) + "] received from [" + sender + "]");
      // record integer identifier of received message
      emit(rcvdBroadcastMsg, getMsgId(pk->getName()));
      // count received messages
      UDPBasicApp::numReceived++;
      // let the algorithm deal with the reception
      runningProtocol->onBroadcastMsg(pk, pk->getName());
    }
      break;
    case UdpPacket::CTRL: {
      // all control messages must contain the parameter: SendersRunningAlgo
      log("Ctrl msg [" + string(pk->getName()) + "] received from [" + sender + "]");
      runningProtocol->onControlMsg(pk, sender.c_str());
//      string senderRunningAlgo(removeQuotes(pk->par("SendersRunningAlgo").str()));
//      log(senderRunningAlgo);
      // control message received from a foreign algorithm, i. e., sender is a border node
//      if (enableInterop && runningAlgorithm != senderRunningAlgo) {
//        bool isKnown = knownForeignAlgos.find(senderRunningAlgo) != knownForeignAlgos.end();
//        if (!isKnown) {
//          knownForeignAlgos.insert(senderRunningAlgo);
//          scheduleEvent(Timer::SEND_FOREIGN_MSG, par("sentMsgFixedDelay").doubleValue(), borderMsgTimer);
//        }
//      }
      // this method isn't implemented for those algorithms
      // that do not deal with exchange of control messages
    }
      break;
    case UdpPacket::FOREIGN: {
//      string senderRunningAlgo(removeQuotes(pk->par("SendersRunningAlgo").str()));
//      if (runningAlgorithm != senderRunningAlgo) {
//        knownForeignAlgos.insert(senderRunningAlgo);
//      }
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

int InteroperableBroadcast::getMsgId(string msgHeader) {
  string pkName(this->packetName);
  string::size_type st;
  return stoi(msgHeader.substr(pkName.size(), msgHeader.size()), &st);
}

void InteroperableBroadcast::addPacketType(cPacket* msg, long l) {
  cMsgPar* p = new cMsgPar("PkType");
  p->setLongValue(l);
  msg->addPar(p);
}

void InteroperableBroadcast::addSender(cPacket* pk) {
  cMsgPar* p = new cMsgPar("Sender");
  p->setStringValue(nodeId.c_str());
  pk->addPar(p);
}

void InteroperableBroadcast::fwdBroadcastMsg(cPacket* pk) {
  latestPkToFwd = pk->dup();
  // update interoperable headers
  latestPkToFwd->getParList().remove("Sender");
  addSender(latestPkToFwd);
  // update headers of running protocol
  runningProtocol->updateProtocolHeaders(latestPkToFwd);

  scheduleEvent(Timer::FWD_BROADCAST_MSG, sentMsgFixedDelay, fwdBMsgTimer);
}

//cPacket* InteroperableBroadcast::getCtrlMsg() {
//  cPacket* ctrlMsg = new cPacket("CtrlMsg");
//  addPacketType(ctrlMsg, UdpPacket::CTRL);
//  addSender(ctrlMsg);
////  addSendersRunningAlgo(ctrlMsg);
//  return ctrlMsg;
//}

bool InteroperableBroadcast::isSelfTimer(cMessage* msg) {
  return ctrlMsgTimer == msg || haltSimTimer == msg || broaMsgTimer == msg || motionTimer == msg || fwdBMsgTimer == msg
      || borderMsgTimer == msg;
}

cPacket* InteroperableBroadcast::makeForeignMessage() {
  cPacket* fMsg = new cPacket("ForeignMsg");
  fMsg->setByteLength(par("ctrlMessageLength").longValue());

  addPacketType(fMsg, UdpPacket::FOREIGN);
//  addInteroperableHeaders(fMsg);
  return fMsg;
}

cPacket* InteroperableBroadcast::setAndGetBroadcastMsg() {
  UDPBasicApp::numSent++;
  string name(this->packetName);
  name += to_string(numSent);
  // let each protocol create broadcast messages
  cPacket* pk = runningProtocol->createBroadcastMsg(name.c_str());
  addBroadcastHeaders(pk);

  return pk;
}

void InteroperableBroadcast::send(cPacket* pk) {
  UDPBasicApp::socket.sendTo(pk, broadcastAddress, UDPBasicApp::destPort);
}

void InteroperableBroadcast::addBroadcastHeaders(cPacket* pk) {
  pk->setByteLength(par("messageLength").longValue());
  addSender(pk);
  addPacketType(pk, UdpPacket::BROADCAST);

}

void InteroperableBroadcast::addCtrlHeaders(cPacket* pk) {
  addSender(pk);
  addPacketType(pk, UdpPacket::CTRL);
}
