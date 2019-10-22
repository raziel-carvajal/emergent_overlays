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
#include "inet/common/XMLUtils.h"

Define_Module(InteroperableBroadcast);

simsignal_t InteroperableBroadcast::rcvdBroadcastMsg = registerSignal("rcvdBroadcastMsg");
simsignal_t InteroperableBroadcast::sentBroadcastMsg = registerSignal("sentBroadcastMsg");

simsignal_t InteroperableBroadcast::sentCtrlFrames = registerSignal("sentCtrlFrames");
simsignal_t InteroperableBroadcast::recvCtrlFrames = registerSignal("recvCtrlFrames");

simsignal_t InteroperableBroadcast::positionAtX = registerSignal("positionAtX");
simsignal_t InteroperableBroadcast::positionAtY = registerSignal("positionAtY");

simsignal_t InteroperableBroadcast::densityObs = registerSignal("densityObs");
simsignal_t InteroperableBroadcast::mobilityObs = registerSignal("mobilityObs");

simsignal_t InteroperableBroadcast::forward_type = registerSignal("forward_type");
simsignal_t InteroperableBroadcast::runningAlgorithm = registerSignal("runningAlgorithm");

void InteroperableBroadcast::initialize(int stage) {
  UDPBasicApp::initialize(stage);
}

void InteroperableBroadcast::processStart() {
  // set unique node ID
  const char* id = getParentModule()->getFullName();
  nodeId = id;
  // load list of source nodes
  setSourceNodesList();
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
  // erase the content of previously known foreign algorithms
//  scheduleEvent(Timer::RESET_BORDER_STATUS, par("adaptationPolicy").doubleValue(), resetBorderTimer);

  // MAC layer initialization
  mac = new MacLayerWithCD();
  mac->setController(this);
  mac->initialize();
  // collector of observable: mobility and density
  collector = new Observables(this);
  switchingPolicy = new SwitchingCriteria(this, collector);
  // the dissemination of broadcast messages
  scheduleEvent(Timer::STORE_POSITION, par("broadcastInterval").doubleValue(), motionTimer);

  // initialize objects that implement broadcast protocols
  intializeCatalog();
  // initialize first running protocol
  runningProtocolId = par("runningProtocolId").longValue();
  runningProtocol = protocols[runningProtocolId];
  runningProtocol->initialize(true);
}

void InteroperableBroadcast::sendPacket() {
  int sourceNodeId = sourceNodes[broadcastMsgId];
  if (isnan(sourceNodeId) == 0 && turnNodeIdToInt() == sourceNodeId && sourceNodeId > 0) {
    // local node was tagged as source node
    cPacket* m = getBroadcastMsg();
    log("New broadcast session [" + string(m->getName()) + "]");
    // send now
    mac->send(m);
    emit(sentBroadcastMsg, getMsgId(m->getName(), this->packetName));
    emit(forward_type, runningProtocol->getFwdType());
    UDPBasicApp::numSent++;
    // tag packet as received
    receivedMsg.insert(m->getName());
  }
  broadcastMsgId++;
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
          mac->send(latestPkToFwd);
          emit(sentBroadcastMsg, getMsgId(latestPkToFwd->getName(), this->packetName));
          if (isBorderNode) {
            emit(forward_type, ForwardType::BORDER_NODE);
          } else {
            emit(forward_type, runningProtocol->getFwdType());
          }
          UDPBasicApp::numSent++;
        }
          break;
        case Timer::STORE_POSITION: {
          Coord pos = mobilityModel->getCurrentPosition();
          emit(positionAtX, pos.x);
          emit(positionAtY, pos.y);
          emit(runningAlgorithm, runningProtocolId);
          scheduleEvent(Timer::STORE_POSITION, par("broadcastInterval").doubleValue(), motionTimer);
        }
          break;
        case Timer::SEND_BORDER_REQ: {
          cMsgPar* h = dynamic_cast<cMsgPar*>(borderMsgTimer->getParList().get("hopsNo"));
          cMsgPar* fa = dynamic_cast<cMsgPar*>(borderMsgTimer->getParList().get("foreignAlgo"));
          cMsgPar* em = dynamic_cast<cMsgPar*>(borderMsgTimer->getParList().get("firstEmitter"));

          if (h->longValue() < 0) {
            log("first node to make a border request");
            // node discovers that is a border
            send(getBorderReqMsg(par("hopsToSharBorderMsg").longValue(), em->stringValue(), fa->longValue()));
            this->numSentCtrlMsgs++;
          } else {
            log("forward border message, with HTL: " + to_string(h->longValue() - 1));
            send(getBorderReqMsg(h->longValue() - 1, em->stringValue(), fa->longValue()));
            this->numSentCtrlMsgs++;
          }
          borderMsgTimer->getParList().clear();
        }
          break;
        case Timer::RESET_BORDER_STATUS: {
          isBorderNode = false;
          knownForeignAlgos.clear();
          double t = 2 * par("windowSize").doubleValue() * par("broadcastInterval").doubleValue();
          scheduleEvent(Timer::RESET_BORDER_STATUS, t, resetBorderTimer);
        }
          break;
        case Timer::HALT_APP: {
          recordScalar("numSentBroMsgs", UDPBasicApp::numSent);
          recordScalar("numRecvBroMsgs", UDPBasicApp::numReceived);
          recordScalar("numSentCtrMsgs", numSentCtrlMsgs);
          recordScalar("numRecvCtrMsgs", numRecvCtrlMsgs);

          log("End of simulation from peer: " + nodeId);
          if (broaMsgTimer)
            cancelAndDelete(broaMsgTimer);
          if (fwdBMsgTimer)
            cancelAndDelete(fwdBMsgTimer);
          if (motionTimer)
            cancelAndDelete(motionTimer);
          if (resetBorderTimer)
            cancelAndDelete(resetBorderTimer);
          if (haltSimTimer)
            cancelAndDelete(haltSimTimer);

          runningProtocol->cancelSelfEvents();
          collector->cancelSelfEvents();
          switchingPolicy->cancelSelfEvents();
          UDPBasicApp::finish();
//          endSimulation();
        }
          break;
        default:
          throw cRuntimeError("Invalid kind %d in selfInteropMsg 1", (int) msg->getKind());
      }
    } else if (runningProtocol->isProtocolEvent(msg)) {
      runningProtocol->handleEvent(msg);
    } else if (mac->isSelfEvent(msg)) {
      mac->handleEvent(msg);
    } else if (collector->isSelfEvent(msg)) {
      collector->handleEvent(msg);
    } else if (switchingPolicy->isSelfEvent(msg)) {
      if (par("withAdaptation").boolValue()) {
        switchingPolicy->handleEvent(msg);
      }
    } else {
      throw cRuntimeError("Invalid kind %s in selfInteropMsg 2", msg->getName());
    }
  }

}

void InteroperableBroadcast::processPacket(cPacket* pk) {
  // avoid that senders listen own messages
  if (getSrcAddress(pk) == localAddress) {
    delete pk;
    return;
  }

  string sender(removeQuotes(pk->par("Sender").str()));
  collector->neighbors.insert(sender);
  switch (pk->par("PkType").longValue()) {
    case UdpPacket::BROADCAST: {
      // let MAC layer deal with reception
      mac->processMsg(pk->getName());

      log("Broadcast msg [" + string(pk->getName()) + "] received from [" + sender + "]");
      // record integer identifier of received message
      emit(rcvdBroadcastMsg, getMsgId(pk->getName(), this->packetName));
      // count received messages
      UDPBasicApp::numReceived++;
      // let the algorithm deal with the reception
      if (runningProtocol->onBroadcastMsg(pk, pk->getName())) {
        // package received for the first time
        if (pk->par("WillToChange").boolValue()) {
          switchingPolicy->onWillToChange();
        }
      }
    }
      break;
    case UdpPacket::CTRL: {
      numRecvCtrlMsgs++;
      emit(recvCtrlFrames, getMsgId(pk->getName(), ctrlMsgName));
      Basic* basicPk = dynamic_cast<Basic*>(pk);

      if (basicPk->getRunningProtocol() != runningProtocolId) {
        log("Ctrl message from node running DIFF algo");
        if (switchingPolicy->enableBorderProtocol) {
          // sender's running protocol ID differs from receiver's; send request to chose border node
          // process only if peer haven't heard about any other node running a foreign algorithm
          if (knownForeignAlgos.find(basicPk->getRunningProtocol()) == knownForeignAlgos.end()) {
            knownForeignAlgos.insert(basicPk->getRunningProtocol());
            log(
                "I am a Border node. Running (" + to_string(runningProtocolId) + ") and foreign ("
                    + to_string(basicPk->getRunningProtocol()) + ") protocols.");

            isBorderNode = true;
            addParamsToBorderTimer(-1, basicPk->getRunningProtocol(), sender.c_str());
            scheduleEvent(Timer::SEND_BORDER_REQ, getRandWaitingTime(), borderMsgTimer);
          }
        }
      } else {
        log("Ctrl message from node running SAME algo");
        runningProtocol->onControlMsg(pk, sender.c_str());
      }
    }
      break;
    case UdpPacket::BORDER_REQ: {
      numRecvCtrlMsgs++;
      log("BorderReq packet received");
      BorderReq* br = dynamic_cast<BorderReq*>(pk);
      if (receivedMsg.find(br->getName()) != receivedMsg.end()) {
        delete pk;
        return;
      }
      receivedMsg.insert(br->getName());

      if (br->getRunningProtocol() != runningProtocolId) {
        if (knownForeignAlgos.find(br->getRunningProtocol()) == knownForeignAlgos.end()) {
          knownForeignAlgos.insert(br->getRunningProtocol());

          if (nodeId == br->getFirstEmitter()) {
            log("I am a Border node (running: " + to_string(runningProtocolId) + ")");
            isBorderNode = true;
          }
        }
      } else {
        if (knownForeignAlgos.find(br->getFirstForeignProtocol()) == knownForeignAlgos.end()) {
          knownForeignAlgos.insert(br->getFirstForeignProtocol());
          // cancel (if any) ongoing timer to send a border messages
          cancelEvent(borderMsgTimer);
          log("I am not longer border node (running: " + to_string(runningProtocolId) + ")");
          isBorderNode = false;
        }
      }
      if (br->getHopsToLive() > 0) {
        addParamsToBorderTimer(br->getHopsToLive(), br->getFirstForeignProtocol(), br->getFirstEmitter());
        scheduleEvent(Timer::SEND_BORDER_REQ, getRandWaitingTime(), borderMsgTimer);
      }
    }
      break;
//    case UdpPacket::PING: {
//      Ping* ping = dynamic_cast<Ping*>(pk);
//      mac->processPingPk(ping);
//    }
//      break;
//    case UdpPacket::PONG: {
//      Pong* pong = dynamic_cast<Pong*>(pk);
//      mac->processPongPk(pong);
//    }
//      break;
//    case UdpPacket::ACK: {
//      Ack* a = dynamic_cast<Ack*>(pk);
//      mac->processAckPk(a);
//    }
//      break;
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

void InteroperableBroadcast::updateRunningAlgorithm(int newAlgo) {
  if (newAlgo == runningProtocolId)
    return;      // avoid switching when both algorithms do not differ
  int algoId;
  switch (newAlgo) {
    case FLOODING:
      algoId = 0;
      break;
    case MPR:
      algoId = 1;
      break;
    case CONTROLLED_FLOODING:
      algoId = 2;
      break;
    default:
      throw cRuntimeError("Invalid protocol ID [%d] in InteroperableBroadcast.updateRunningAlgorithm", newAlgo);
      break;
  }
  runningProtocol->cancelSelfEvents();
  log("switching from algo [" + to_string(runningProtocolId) + "] to [" + to_string(algoId) + "]");
  runningProtocolId = algoId;
  runningProtocol = protocols[runningProtocolId];
  runningProtocol->initialize(false);
}

int InteroperableBroadcast::getMsgId(string msgHeader, string substr) {
  string::size_type st;
  return stoi(msgHeader.substr(substr.size(), msgHeader.size()), &st);
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
  scheduleEvent(Timer::FWD_BROADCAST_MSG, getRandWaitingTime(), fwdBMsgTimer);
}

bool InteroperableBroadcast::isSelfTimer(cMessage* msg) {
  return haltSimTimer == msg || broaMsgTimer == msg || motionTimer == msg || fwdBMsgTimer == msg
      || borderMsgTimer == msg || resetBorderTimer == msg;
}

cPacket* InteroperableBroadcast::getBroadcastMsg() {
  string name(packetName);
  name += to_string(broadcastMsgId + 1);
// let each protocol create broadcast messages
  cPacket* pk = runningProtocol->createBroadcastMsg(name.c_str());
  addBroadcastHeaders(pk);

  return pk;
}

cPacket* InteroperableBroadcast::getBorderReqMsg(int hopsNo, const char* emitter, int foreignAlgo) {
  BorderReq* r = new BorderReq();
  r->setRunningProtocol(runningProtocolId);

  r->setFirstEmitter(emitter);
  r->setHopsToLive(hopsNo);
  r->setFirstForeignProtocol(foreignAlgo);
  addSender(r);
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
  // add header of adaptation when needed
  addWillToChange(pk, par("withAdaptation").boolValue() && switchingPolicy->addAdapHeader);
}

void InteroperableBroadcast::addCtrlHeaders(cPacket* pk) {
  addSender(pk);
  addPacketType(pk, UdpPacket::CTRL);
}

void InteroperableBroadcast::setSourceNodesList() {
  int n(par("stopTime").doubleValue() / par("broadcastInterval").doubleValue());
  sourceNodes = new int[n];
  string::size_type sz;
  cXMLElement *list = par("sourceNodes").xmlValue();
  cXMLElementList nodes = list->getElementsByTagName("SourceNode");
  int i = 0;
  for (const auto& m : nodes) {
    try {
      sourceNodes[i] = stoi(xmlutils::getRequiredAttribute(*m, "id"), &sz);
    }
    catch (exception e) {
      sourceNodes[i] = -1;
    }
    i++;
  }
}

void InteroperableBroadcast::addWillToChange(cPacket* msg, bool withInteropHeader) {
  cMsgPar* p = new cMsgPar("WillToChange");
  p->setBoolValue(withInteropHeader);
  msg->addPar(p);
  if (withInteropHeader)
    switchingPolicy->onWillToChange();

  switchingPolicy->addAdapHeader = false;
}

void InteroperableBroadcast::addParamsToBorderTimer(int hops, int foreignAlgo, const char* emitterId) {
  cancelEvent(borderMsgTimer);
  borderMsgTimer->getParList().clear();
  // hops to disseminate border message
  cMsgPar* p1 = new cMsgPar("hopsNo");
  p1->setLongValue(hops);
  // stores algorithm that lets to create a border message
  cMsgPar* p2 = new cMsgPar("foreignAlgo");
  p2->setLongValue(foreignAlgo);
  // node identifier that bootstraps discovery of border node
  cMsgPar* p3 = new cMsgPar("firstEmitter");
  p3->setStringValue(emitterId);

  borderMsgTimer->addPar(p1);
  borderMsgTimer->addPar(p2);
  borderMsgTimer->addPar(p3);
}

int InteroperableBroadcast::turnNodeIdToInt() {
  bool isNumeric = false;
  int i = 0;
  while (!isNumeric) {
    if (!isalpha(nodeId[i]))
      isNumeric = true;
    else
      i++;
  }
  string::size_type sz;
  return stoi(nodeId.substr(i, nodeId.size()), &sz);
}
