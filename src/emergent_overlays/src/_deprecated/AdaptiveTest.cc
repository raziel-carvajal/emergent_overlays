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
//#include <AdaptiveTest.h>
//#include <inet/common/ModuleAccess.h>
//#include <msgs/NeighborsPacket_m.h>
//#include <inet/common/geometry/common/Coord.h>
//#include <inet/networklayer/common/L3AddressResolver.h>
//#include <Flooding.h>
//
//Define_Module(AdaptiveTest);
//
//simsignal_t AdaptiveTest::clusteringCoef = registerSignal("clusteringCoef");
//simsignal_t AdaptiveTest::closureCoef = registerSignal("closureCoef");
//simsignal_t AdaptiveTest::positionAtX = registerSignal("positionAtX");
//simsignal_t AdaptiveTest::positionAtY = registerSignal("positionAtY");
//
//void AdaptiveTest::sendPacket() {
//  _1hopNeigs.clear();
//  _2hopNeigs.clear();
//
//  double t = par("minFixedDelay").doubleValue() + sentMsgDelay;
//  scheduleEvent(SEND_HELLO_MSG, t, helloEvent);
//
//  t += par("maxNodesNo").longValue() * par("sentMsgFixedDelay").doubleValue();
//  scheduleEvent(SEND_CTRL_MSG, t, ctrlEvent);
//
//  t += par("maxNodesNo").longValue() * par("sentMsgFixedDelay").doubleValue() - sentMsgDelay;
//  scheduleEvent(DENSITY_METRICS, t, densityEvent);
//}
//
//void AdaptiveTest::scheduleEvent(short kind, double delay, cMessage* selfMsgPtr) {
//  simtime_t t = simTime() + delay;
//  selfMsgPtr->setKind(kind);
//  scheduleAt(t, selfMsgPtr);
//}
//
//void AdaptiveTest::processStart() {
//  const char* id = getParentModule()->getFullName();
//  nodeId = id;
//  metrics.setNodeId(nodeId);
//
//  cerr << "START" << endl;
//  algos[0] = new Flooding();
//  log("START 1");
//  algos[0]->setController(this);
//  log("START 2");
//  mobilityModel = check_and_cast<IMobility*>(getContainingNode(this)->getSubmodule("mobility"));
//
//  // nodes identifiers start with an alphabetic character
//  bool isNumeric = false;
//  int i = 0;
//  while (!isNumeric) {
//    if (!isalpha(nodeId[i]))
//      isNumeric = true;
//    else
//      i++;
//  }
//  // get numeric substring from node identifier
//  std::string::size_type sz;
//  int n = stoi(nodeId.substr(i, nodeId.size()), &sz);
//  // unique value per node identifier (i.e. the value for this attribute isn't the same, for any pair of nodes)
//  int N = par("maxNodesNo").longValue();
//  sentMsgDelay = ((n - 1) % N) * par("sentMsgFixedDelay").doubleValue();
//
//  localAddress = L3AddressResolver().resolve(id);
//
//  socket.setOutputGate(gate("udpOut"));
//  socket.bind(localAddress, localPort);
//  UDPBasicApp::setSocketOptions();
//
//  L3AddressResolver().tryResolve(par("destAddresses"), broadcastAddress);
//  if (broadcastAddress.isUnspecified())
//    throw cRuntimeError("invalid broadcast address");
//
//  UDPBasicApp::processSend();
//}
//
//void AdaptiveTest::handleMessageWhenUp(cMessage* msg) {
////  log("Event [" + to_string(msg->getKind()) + "]");
//  if (msg->isSelfMessage() && selfEvent(msg)) {
//    switch (msg->getKind()) {
//      case SEND_HELLO_MSG: {
//        algos[0]->isProtocolEvent(msg);
////        log("sending hello msg");
//        UDPBasicApp::socket.sendTo(getHelloMsg(), broadcastAddress, UDPBasicApp::destPort);
//      }
//        break;
//      case SEND_CTRL_MSG: {
////        log("sending control msg");
//        Coord c = mobilityModel->getCurrentPosition();
//        emit(positionAtX, c.x);
//        emit(positionAtY, c.y);
//        UDPBasicApp::socket.sendTo(getCtrlMsg(), broadcastAddress, UDPBasicApp::destPort);
//      }
//        break;
//      case GET_DENSITY_METRICS: {
////        log("get density metric");
//        printNeighbors();
//        metrics.setNeighbors(_1hopNeigs, _2hopNeigs);
//        emit(clusteringCoef, metrics.getClusteringCoef());
//        emit(closureCoef, metrics.getClosureCoef());
//      }
//        break;
//      default:
//        throw cRuntimeError("Invalid kind %d in self message", (int) msg->getKind());
//        break;
//    }
//  } else {
//    UDPBasicApp::handleMessageWhenUp(msg);
//  }
//}
//
//void AdaptiveTest::processPacket(cPacket* msg) {
//  if (getSrcAddress(msg) == localAddress) {
//    delete msg;
//    return;
//  }
//  int msgType = msg->par("PkType").longValue();
//  switch (msgType) {
//    case PacketType::HELLO_PK: {
////      log("hello message [" + to_string(msgType) + "] from [" + h->getSender() + "]");
//
//      Hello* h = static_cast<Hello*>(msg);
//      _1hopNeigs.insert(h->getSender());
//    }
//      break;
//    case PacketType::CTRL_PK: {
////      log("control message [" + to_string(msgType) + "] from [" + n->getSender() + "]");
//
//      OneHopNeighbors* n = static_cast<OneHopNeighbors*>(msg);
//      string sender(n->getSender());
//      _1hopNeigs.insert(sender);
//
//      Neighbors neigs = n->getNeigs();
//      _2hopNeigs[sender].clear();
//      for (Neighbors::iterator i = neigs.begin(); i != neigs.end(); ++i) {
//        _2hopNeigs[sender].insert(*i);
//      }
//    }
//      break;
//    default:
//      throw cRuntimeError("Invalid kind of msg %d in self message", msgType);
//      break;
//  }
//  delete msg;
//}
//
//cPacket* AdaptiveTest::getHelloMsg() {
//  cMsgPar* p = new cMsgPar("PkType");
//  p->setLongValue(PacketType::HELLO_PK);
//
//  Hello* h = new Hello();
//  h->setSender(nodeId.c_str());
//  h->addPar(p);
//  return h;
//}
//
//cPacket* AdaptiveTest::getCtrlMsg() {
//  cMsgPar* p = new cMsgPar("PkType");
//  p->setLongValue(PacketType::CTRL_PK);
//
//  OneHopNeighbors* n = new OneHopNeighbors();
//  n->setSender(nodeId.c_str());
//  n->addPar(p);
//  Neighbors neigs;
//  for (set<string>::iterator i = _1hopNeigs.begin(); i != _1hopNeigs.end(); ++i) {
//    neigs.insert(*i);
//  }
//  n->setNeigs(neigs);
//  return n;
//}
//
