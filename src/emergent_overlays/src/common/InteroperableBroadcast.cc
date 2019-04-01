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
  UDPBasicApp::initialize(stage);
  if (stage == inet::INITSTAGE_LOCAL) {
    cMsgPar* p = new cMsgPar("foreignAlgoId");
    p->setLongValue(0);
    borderMsgTimer->addPar(p);
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
  // store nodes positions to get an approximation of the wireless topology formed during
  // the dissemination of broadcast messages
  scheduleEvent(Timer::STORE_POSITION, par("broadcastInterval").doubleValue(), motionTimer);
  // erase the content of previously known foreign algorithms
  scheduleEvent(Timer::RESET_BORDER_STATUS, par("startSendingCtrlMsgs").doubleValue(), resetBorderTimer);

  // initialize objects that implement broadcast protocols
  intializeCatalog();
  // initialize first running protocol
  runningProtocolId = par("runningProtocolId").longValue();
  runningProtocol = protocols[runningProtocolId];
  runningProtocol->initialize();
}

void InteroperableBroadcast::sendPacket() {
  // TODO implement multiple sources as follows:
  // - create a configuration file where source nodes were chosen randomly
  //   before an experiment starts; lines of this file: <SESSION_ID> <NODE_ID>
  if (par("isSourceNode").boolValue()) {
    cPacket* m = getBroadcastMsg();
    log("New broadcast session [" + string(m->getName()) + "]");
    // send now
    send(m);
    emit(sentBroadcastMsg, getMsgId(m->getName()));
    emit(forward_type, runningProtocol->getFwdType());
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
        case Timer::FWD_BROADCAST_MSG: {
          send(latestPkToFwd);
          emit(sentBroadcastMsg, getMsgId(latestPkToFwd->getName()));
          if (isBorderNode) {
            emit(forward_type, ForwardType::BORDER_NODE);
          } else {
            emit(forward_type, runningProtocol->getFwdType());
          }
        }
          break;
        case Timer::STORE_POSITION: {
          Coord pos = mobilityModel->getCurrentPosition();
          emit(positionAtX, pos.x);
          emit(positionAtY, pos.y);
          scheduleEvent(Timer::STORE_POSITION, par("broadcastInterval").doubleValue(), motionTimer);
        }
          break;
        case Timer::SEND_BORDER_REQ: {
          log("Sending BorderReq packet");
          send(getBorderReqMsg());
        }
          break;
        case Timer::RESET_BORDER_STATUS: {
          isBorderNode = false;
          knownForeignAlgos.clear();
          scheduleEvent(Timer::RESET_BORDER_STATUS, par("ctrlMsgInterval").doubleValue(), resetBorderTimer);
        }
          break;
        case Timer::HALT_APP: {
          EV << "End of simulation from peer: " << nodeId << endl;
          if (broaMsgTimer)
            cancelAndDelete(broaMsgTimer);
          if (fwdBMsgTimer)
            cancelAndDelete(fwdBMsgTimer);
          if (motionTimer)
            cancelAndDelete(motionTimer);
          if (resetBorderTimer)
            cancelAndDelete(resetBorderTimer);

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

  switch (pk->par("PkType").longValue()) {
    case UdpPacket::BROADCAST: {
      string sender(removeQuotes(pk->par("Sender").str()));
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
      string sender(removeQuotes(pk->par("Sender").str()));
      Basic* basicPk = dynamic_cast<Basic*>(pk);
      // sender's running protocol ID differs from receiver's; send request to chose border node
      if (basicPk->getRunningProtocol() != runningProtocolId) {
        log(
            "Ctrl msg [" + string(pk->getName()) + "] received from node running ["
                + to_string(basicPk->getRunningProtocol()) + "]");
        if (knownForeignAlgos.find(basicPk->getRunningProtocol()) == knownForeignAlgos.end()) {

          if (basicPk->getName() == foreignPkName) {
            knownForeignAlgos.insert(basicPk->getRunningProtocol());
            log("I am Border node (UdpPacket::CTRL)");
            isBorderNode = true;
            scheduleEvent(Timer::SEND_BORDER_REQ, sentMsgFixedDelay, borderMsgTimer);
          } else {
            log("Ignoring foreign control message");
          }
        }
      } else {
        runningProtocol->onControlMsg(pk, sender.c_str());
      }
    }
      break;
    case UdpPacket::BORDER_REQ: {
      log("BorderReq packet received");
      BorderReq* br = dynamic_cast<BorderReq*>(pk);
      // BorderReq packets are accepted only from senders running a different algorithm AND
      // we haven't heard from another node running such foreign algorithm
      if (br->getRunningProtocol() != runningProtocolId
          && knownForeignAlgos.find(br->getRunningProtocol()) == knownForeignAlgos.end()) {
        // leaf node in a overlay-based approach
        knownForeignAlgos.insert(br->getRunningProtocol());

        if (!runningProtocol->amIoverlayRelay()) {
          log("I am Border node UdpPacket::BORDER_REQ");
          isBorderNode = true;
        }

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

//set<string> InteroperableBroadcast::choseBorderNodes() {
//  string temp("Chosen border nodes: ");
//  set<string> chosen;
//  set<string> neigs = runningProtocol->getNeighbors();
//  log("Neighbors number: " + to_string(neigs.size()));
//  set<string>::iterator it = neigs.begin();
//  if (neigs.size() == 1 || neigs.size() == 2) {
//    chosen.insert(*it);
//    log(temp + *it);
//    return chosen;
//  } else {
//    int lim = ceil(neigs.size() / 2.0);
//    while ((int) chosen.size() != lim) {
//      int i = 0;
//      int n = neigs.size();
//      string ids[n];
//      for (it = neigs.begin(); it != neigs.end(); ++it) {
//        ids[i] = *it;
//        i++;
//      }
//      double opts[n];
//      double f = 1 / (n * 1.0);
//      for (i = 0; i < n - 1; ++i) {
//        opts[i] = (i + 1) * f;
//      }
//      opts[i] = 1;
//      for (i = 0; i < n; ++i) {
//        if (uniform(0, 1) <= opts[i]) {
//          neigs.erase(ids[i]);
//          chosen.insert(ids[i]);
//          break;
//        }
//      }
//    }
//  }
//  for (it = chosen.begin(); it != chosen.end(); ++it) {
//    temp += *it + ", ";
//  }
//  log(temp);
//  return chosen;
//}

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
  // uniform(sentMsgFixedDelay, sentMsgFixedDelay * 10)
  scheduleEvent(Timer::FWD_BROADCAST_MSG, sentMsgFixedDelay, fwdBMsgTimer);
}

bool InteroperableBroadcast::isSelfTimer(cMessage* msg) {
  return haltSimTimer == msg || broaMsgTimer == msg || motionTimer == msg || fwdBMsgTimer == msg
      || borderMsgTimer == msg || resetBorderTimer == msg;
}

cPacket* InteroperableBroadcast::getBroadcastMsg() {
  UDPBasicApp::numSent++;
  string name(this->packetName);
  name += to_string(numSent);
// let each protocol create broadcast messages
  cPacket* pk = runningProtocol->createBroadcastMsg(name.c_str());
  addBroadcastHeaders(pk);

  return pk;
}

cPacket* InteroperableBroadcast::getBorderReqMsg() {
  BorderReq* r = new BorderReq();
  r->setRunningProtocol(runningProtocolId);
  addPacketType(r, UdpPacket::BORDER_REQ);
  return r;
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
