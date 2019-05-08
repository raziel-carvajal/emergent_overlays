////
//// This program is free software: you can redistribute it and/or modify
//// it under the terms of the GNU Lesser General Public License as published by
//// the Free Software Foundation, either version 3 of the License, or
//// (at your option) any later version.
////
//// This program is distributed in the hope that it will be useful,
//// but WITHOUT ANY WARRANTY; without even the implied warranty of
//// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//// GNU Lesser General Public License for more details.
////
//// You should have received a copy of the GNU Lesser General Public License
//// along with this program.  If not, see http://www.gnu.org/licenses/.
////
//
//#include <broadcast_protocols/overlay_based/MPR_1.h>
//
//Define_Module(MPR_1);
//
//void MPR_1::initialize(int stage) {
//  InteroperableBroadcast::initialize(stage);
//
//  if (stage == inet::INITSTAGE_LOCAL) {
//    initNeigTimer = new cMessage("initNeigTimer");
//    sCtrlMsgTimer = new cMessage("sCtrlMsgTimer");
//    fwdBrMsgTimer = new cMessage("fwdBrMsgTimer");
//    rCtrlMsgTimer = new cMessage("rCtrlMsgTimer");
//    cMsgPar* p1 = new cMsgPar("fwdType");
//    p1->setBoolValue(false);
//    cMsgPar* p2 = new cMsgPar("sender");
//    p2->setStringValue("");
//    fwdBrMsgTimer->addPar(p1);
//    fwdBrMsgTimer->addPar(p2);
//  }
//}
//
//void MPR_1::processStart() {
//  InteroperableBroadcast::processStart();
//  InteroperableBroadcast::scheduleEvent(SEND_CTRL_MSG_TO_BOOT, InteroperableBroadcast::sentMsgDelay, initNeigTimer);
//}
//
//void MPR_1::handleMessageWhenUp(cMessage* msg) {
//  if (msg->isSelfMessage()
//      && (initNeigTimer == msg || sCtrlMsgTimer == msg || fwdBrMsgTimer == msg || rCtrlMsgTimer == msg)) {
//    switch (msg->getKind()) {
//      case SEND_CTRL_MSG_TO_BOOT:
//        EV_DEBUG << nodeId << "Case: SEND_CTRL_MSG_TO_BOOT" << endl;
//        socket.sendTo(getCtrlMsg(), InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
//        if (sentBootEvents < par("bootCtrlMsgsNo").longValue()) {
//          EV_DEBUG << "scheduling BOOT_CTRL_MSG [" << sentBootEvents << "]" << endl;
//          cancelEvent(msg);
//          InteroperableBroadcast::scheduleEvent(SEND_CTRL_MSG_TO_BOOT,
//              par("sentMsgFixedDelay").doubleValue() * par("maxNodesNo").longValue(), initNeigTimer);
//        } else {
//          // this message will reach the nearest two-hop neighbor
//          // that is why the delay is multiplied by 2
//          InteroperableBroadcast::scheduleEvent(WAIT_CTRL_MSG_DISS,
//              par("sentMsgFixedDelay").doubleValue() * par("maxNodesNo").longValue(), sCtrlMsgTimer);
//        }
//        sentBootEvents++;
//        break;
//      case FWD_BROADCAST_MSG: {
//        EV_DEBUG << "Case: FWD_BROADCAST_MSG" << endl;
////        if (InteroperableBroadcast::amIborderNode) {
////          // INFO: this action do NOT build a MPR set
////          socket.sendTo(buildBroadcastMsg(msg->getName(), ""), InteroperableBroadcast::broadcastAddress,
////              InteroperableBroadcast::destPort);
////          emit(InteroperableBroadcast::forward_type, InteroperableBroadcast::ForwardType::BORDER_NODE);
////        } else if (msg->par("fwdType").boolValue()) {
////          // INFO: this action do NOT build a MPR set
////          socket.sendTo(buildBroadcastMsg(msg->getName(), ""), InteroperableBroadcast::broadcastAddress,
////              InteroperableBroadcast::destPort);
////          emit(InteroperableBroadcast::sentBroadcastMsg, InteroperableBroadcast::getMsgId(msg->getName()));
////          emit(InteroperableBroadcast::forward_type, InteroperableBroadcast::ForwardType::CDS_RELAY);
////        } else {
////          string ignoredSender(msg->par("sender").stringValue());
////          EV_DEBUG << "fwdType == FALSE, sender = " << ignoredSender << endl;
////          cPacket* broadcastPk = buildBroadcastMsg(msg->getName(), ignoredSender);
////          bool fwdMsg = InteroperableBroadcast::isPacket<MprBroadcast>(broadcastPk,
////              [&](const MprBroadcast* broadcastMsg) {
////                return !broadcastMsg->getMprSet().empty();
////              });
////          if (fwdMsg) {
////            socket.sendTo(broadcastPk, InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
////            emit(InteroperableBroadcast::sentBroadcastMsg, InteroperableBroadcast::getMsgId(broadcastPk->getName()));
////            emit(InteroperableBroadcast::forward_type, InteroperableBroadcast::ForwardType::CDS_RELAY);
////          }
////        }
//      }
//        break;
//      case SEND_CTRL_MSG:
//        cancelEvent(msg);
//        socket.sendTo(getCtrlMsg(), InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
//        InteroperableBroadcast::scheduleEvent(WAIT_CTRL_MSG_DISS, par("sentMsgFixedDelay").doubleValue() * 2,
//            sCtrlMsgTimer);
//        break;
//      case WAIT_CTRL_MSG_DISS:
//        // let 2 hop neighbors know when the the size of my neighborhood is equal to 1
//        if (_1hopNeigs.size() == 1) {
//          EV_DEBUG << "Sending SEND_CTRL_MSG_C1" << endl;
//          socket.sendTo(getCtrlMsgC1(), InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
//        }
//        break;
//      case FWD_CTRL_MSG:
//        EV_DEBUG << "Case: FWD_CTRL_MSG, for message [" << msg->getName() << "]" << endl;
//        socket.sendTo(getCtrlMsgC1(msg->getName(), msg->par("emitter").stringValue(), msg->par("hops").longValue()),
//            InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
//        break;
//      default:
//        throw cRuntimeError("Timer [%d] is not at Mpr_1_Timers (list of timers)", (int) msg->getKind());
//    }
//  } else
//    InteroperableBroadcast::handleMessageWhenUp(msg);
//}
//
//cPacket* MPR_1::getCtrlMsg() {
//  MprCtrl* ctrlMsg = new MprCtrl("CtrlMsg");
//
//  InteroperableBroadcast::addPacketType(ctrlMsg, UdpPacket::CTRL);
//  InteroperableBroadcast::addPacketHeaders(ctrlMsg);
//
//  MprNeighbours myNeigs;
//  EV_DEBUG << "Current neighbors:" << endl;
//  for (MprNeighbours::iterator it = _1hopNeigs.begin(); it != _1hopNeigs.end(); ++it) {
//    EV_DEBUG << "\t " << *it << endl;
//    myNeigs.insert(*it);
//  }
//
//  ctrlMsg->setNeighbors(myNeigs);
//  return ctrlMsg;
//}
//
//cPacket* MPR_1::getCtrlMsgC1() {
//  string id("CtrlMsg-" + to_string(ctrlMsgC1id));
//  MprCtrl_1_Neig* ctrlMsg = new MprCtrl_1_Neig(id.c_str());
//  recvCtrlMsgs.insert(id);
//
//  InteroperableBroadcast::addPacketType(ctrlMsg, UdpPacket::CTRL);
//  InteroperableBroadcast::addPacketHeaders(ctrlMsg);
//
//  ctrlMsg->setEmitter(InteroperableBroadcast::nodeId.c_str());
//  ctrlMsg->setHops(2);
//
//  return ctrlMsg;
//}
//
//cPacket* MPR_1::getCtrlMsgC1(string header, string emitter, int hops) {
//  MprCtrl_1_Neig* ctrlMsg = new MprCtrl_1_Neig(header.c_str());
//
//  InteroperableBroadcast::addPacketType(ctrlMsg, UdpPacket::CTRL);
//  InteroperableBroadcast::addPacketHeaders(ctrlMsg);
//
//  ctrlMsg->setEmitter(emitter.c_str());
//  ctrlMsg->setHops(hops);
//
//  return ctrlMsg;
//}
//
//void MPR_1::sendPacket() {
//  if (par("isSource").boolValue()) {
//    cPacket* pk = buildBroadcastMsg(nullptr, "");
//
//    socket.sendTo(pk, InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
//    emit(InteroperableBroadcast::sentBroadcastMsg, InteroperableBroadcast::getMsgId(pk->getName()));
//    emit(InteroperableBroadcast::forward_type, InteroperableBroadcast::ForwardType::CDS_RELAY);
//
//    // tag packet as received
//    InteroperableBroadcast::receivedMsg.insert(pk->getName());
//  }
//  // count sent broadcast messages in all nodes. This is useful in an experiment
//  // where any node in the network act as source of a broadcast session
//  InteroperableBroadcast::numSent++;
//}
//
//void MPR_1::sendCtrlMsg() {
//  eraseLocalState();
//  // 2 exchanges of control messages are required to approximate a CDS
//  // - 1st exchange: neighbors
//  // - 2nd exchange: neighbors of neighbors
//  socket.sendTo(getCtrlMsg(), InteroperableBroadcast::broadcastAddress, InteroperableBroadcast::destPort);
//  InteroperableBroadcast::scheduleEvent(SEND_CTRL_MSG,
//      par("sentMsgFixedDelay").doubleValue() * par("maxNodesNo").longValue(), sCtrlMsgTimer);
//}
//
//void MPR_1::eraseLocalState() {
//  _1hopNeigs.clear();
//  recvCtrlMsgs.clear();
//  _2hopNodesWithOneNeig.clear();
//  set<string> toDelete;
//  for (auto i = _2hopNeigs.begin(); i != _2hopNeigs.end(); ++i)
//    toDelete.insert(i->first);
//  for (set<string>::iterator j = toDelete.begin(); j != toDelete.end(); ++j)
//    _2hopNeigs.erase(*j);
////  EV_DEBUG << "Current two-hop neighbors" << endl;
////  for (auto i = _2hopNeigs.begin(); i != _2hopNeigs.end(); ++i)
////    EV_DEBUG << "[" << i->first << "]" << endl;
//}
//
//set<string> MPR_1::getMprSet(string ignoredNode) {
//  set<string> nonCoveredNodes;
//  set<string>::iterator it1;
//  // every two-hop neighbor is considered as non-covered node
//  for (auto it = _2hopNeigs.begin(); it != _2hopNeigs.end(); ++it) {
//    for (it1 = it->second.begin(); it1 != it->second.end(); ++it1) {
//      // avoid covering local peer
//      if (*it1 != InteroperableBroadcast::nodeId) {
//        nonCoveredNodes.insert(*it1);
//      }
//    }
//  }
//  // Rules i & ii from MPR heuristic (section 2.1 in paper)
//  set<string> mprSet;
//  for (it1 = _2hopNodesWithOneNeig.begin(); it1 != _2hopNodesWithOneNeig.end(); ++it1) {
//    for (auto it = _2hopNeigs.begin(); it != _2hopNeigs.end(); ++it) {
//      if (it->second.find(*it1) != it->second.end()) {
//        mprSet.insert(it->first);
//        for (set<string>::iterator it2 = it->second.begin(); it2 != it->second.begin(); ++it2) {
//          if (nonCoveredNodes.find(*it2) != nonCoveredNodes.end())
//            nonCoveredNodes.erase(*it2);
//        }
//      }
//    }
//  }
//  string biggestSubset;
//  int biggestCard = -1;
//  int setCard;
//  // before applying rule iii, find the biggest 2-hop subset that isn't already at mprSet
//  for (auto it = _2hopNeigs.begin(); it != _2hopNeigs.end(); ++it) {
//    setCard = it->second.size();
//    EV_DEBUG << "|| " << it->first << " || = " << setCard << endl;
//    if (setCard >= biggestCard && mprSet.find(it->first) == mprSet.end()) {
//      biggestCard = setCard;
//      biggestSubset = it->first;
//    }
//  }
//  // Rule iii from MPR heuristic (section 2.1 in paper)
//  if (!nonCoveredNodes.empty() && biggestCard != -1)
//    mprSet.insert(biggestSubset);
//  if (mprSet.find(ignoredNode) != mprSet.end()) {
//    EV_DEBUG << "delete " << ignoredNode << " from mprSet" << endl;
//    mprSet.erase(ignoredNode);
//    // XXX
////    int _1hopNeigsCard = _1hopNeigs.size();
////    if (mprSet.empty() && _1hopNeigsCard != 1)
////      mprSet.insert(InteroperableBroadcast::nodeId);
//  }
//  EV_DEBUG << nodeId << " :: My MPR set" << endl;
//  for (it1 = mprSet.begin(); it1 != mprSet.end(); ++it1)
//    EV_DEBUG << "[" << *it1 << "]" << endl;
//  return mprSet;
//}
//
//cPacket* MPR_1::buildBroadcastMsg(const char* header, string discartedNode) {
//  MprBroadcast* payload;
//
//  if (header == nullptr) {
//    ostringstream pkName;
//    pkName << InteroperableBroadcast::packetName + to_string(InteroperableBroadcast::numSent);
//    EV_DEBUG << "[MPR] New broadcast session. MsgId=" << pkName.str() << endl;
//    payload = new MprBroadcast(pkName.str().c_str());
//    // when a node initiates a broadcast session, compute MPR set and piggyback it
//    payload->setMprSet(getMprSet(""));
//  } else {
//    payload = new MprBroadcast(header);
//    if (discartedNode != "")
//      payload->setMprSet(getMprSet(discartedNode));
//  }
//
//  payload->setByteLength(par("messageLength").longValue());
//  InteroperableBroadcast::addPacketType(payload, InteroperableBroadcast::UdpPacket::BROADCAST);
//  InteroperableBroadcast::addPacketHeaders(payload);
//
//  return payload;
//}
//
//void MPR_1::onBroadcastMsg(cPacket* pk, string sender) {
//  InteroperableBroadcast::isPacket<MprBroadcast>(pk, [&](const MprBroadcast* msg) {
//    bool atMprSet = msg->getMprSet().find(InteroperableBroadcast::nodeId) != msg->getMprSet().end();
//    if(atMprSet) {
//      EV_DEBUG << "[" << nodeId << "] I was chosen to FWD" << endl;
//      // local peer must forward receive message cause it is part of a MPR set
//      fwdBrMsgTimer->par("fwdType").setBoolValue(true);
//    } else {
//      EV_DEBUG << "[" << nodeId << "] I wasn't chosen to FWD" << endl;
//      fwdBrMsgTimer->par("fwdType").setBoolValue(false);
//      fwdBrMsgTimer->par("sender").setStringValue(sender.c_str());
//    }
//    fwdBrMsgTimer->setName(msg->getName());
//    // XXX found a situation where a FWD_BROADCAST event is scheduled twice
//    //     how is that possible ?
//    if( !fwdBrMsgTimer->isScheduled() ) {
//      InteroperableBroadcast::scheduleEvent(FWD_BROADCAST_MSG, InteroperableBroadcast::sentMsgDelay,
//          fwdBrMsgTimer); // to avoid collisions/contentions, schedule retransmission of broadcast message
//    }
//    return true;
//  });
//}
//
//void MPR_1::onControlMsg(cPacket* pk, string sender) {
//  InteroperableBroadcast::isPacket<MprCtrl>(pk, [&](const MprCtrl* ctrlMsg) {
//    _1hopNeigs.insert(sender);
//    string msg("MyNeighbors ["+nodeId+"] :: ["+sender+"] = {");
//    MprNeighbours neigs = ctrlMsg->getNeighbors();
//    for(MprNeighbours::iterator it = neigs.begin(); it != neigs.end(); ++it) {
//      if(*it != InteroperableBroadcast::nodeId) {
//        _2hopNeigs[sender].insert(*it);
//        msg += *it + ", ";
//      }
//    }
////    cerr << msg << "}" << endl;
//      EV_DEBUG << msg << "}" << endl;
//      return true;
//    });
//  InteroperableBroadcast::isPacket<MprCtrl_1_Neig>(pk, [&](const MprCtrl_1_Neig* ctrlMsg) {
//    if(recvCtrlMsgs.find(ctrlMsg->getName()) == recvCtrlMsgs.end()) {
//      recvCtrlMsgs.insert(ctrlMsg->getName());
//      if(ctrlMsg->getHops() - 1 > 0) {
//        rCtrlMsgTimer->setName(ctrlMsg->getName());
//
//        cMsgPar* p1 = new cMsgPar("emitter");
//        p1->setStringValue(ctrlMsg->getEmitter());
//        cMsgPar* p2 = new cMsgPar("hops");
//        p2->setLongValue(ctrlMsg->getHops() - 1);
//
//        rCtrlMsgTimer->addPar(p1);
//        rCtrlMsgTimer->addPar(p2);
//
//        InteroperableBroadcast::scheduleEvent(FWD_CTRL_MSG, InteroperableBroadcast::sentMsgDelay,
//            rCtrlMsgTimer); // to avoid collisions/contentions, schedule retransmission of broadcast message
//    } else {
//      EV_DEBUG << "New 2-hop-neighbor [" << ctrlMsg->getEmitter() << "] wit neighborhood size equal to 1" << endl;
//      _2hopNodesWithOneNeig.insert(ctrlMsg->getEmitter());
//    }
//  } else {
//    // Ctrl message previously heard from a different sender
//    if(ctrlMsg->getHops()-1 == 0 && InteroperableBroadcast::nodeId != ctrlMsg->getEmitter()) {
//      EV_DEBUG << "New 2-hop-neighbor [" << ctrlMsg->getEmitter() << "] wit neighborhood size equal to 1" << endl;
//      _2hopNodesWithOneNeig.insert(ctrlMsg->getEmitter());
//    }
//  }
//  return true;
//});
//}
