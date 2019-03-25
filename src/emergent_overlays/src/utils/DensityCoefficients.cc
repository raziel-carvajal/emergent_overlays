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

#include <DensityCoefficients.h>
#include <inet/common/ModuleAccess.h>
#include <msgs/NeighborsPacket_m.h>
#include <inet/common/geometry/common/Coord.h>
#include <inet/networklayer/common/L3AddressResolver.h>

Define_Module(DensityCoefficients);

simsignal_t DensityCoefficients::clusteringCoef = registerSignal("clusteringCoef");
simsignal_t DensityCoefficients::closureCoef = registerSignal("closureCoef");
simsignal_t DensityCoefficients::positionAtX = registerSignal("positionAtX");
simsignal_t DensityCoefficients::positionAtY = registerSignal("positionAtY");
simsignal_t DensityCoefficients::runningProtocol = registerSignal("runningProtocol");

void DensityCoefficients::sendPacket() {
  _1hopNeigs.clear();
  _2hopNeigs.clear();

  double t = par("minFixedDelay").doubleValue() + sentMsgDelay;
  scheduleEvent(SEND_HELLO_MSG, t, helloEvent);

  t += par("maxNodesNo").longValue() * par("sentMsgFixedDelay").doubleValue();
  scheduleEvent(SEND_CTRL_MSG, t, ctrlEvent);

  t += par("maxNodesNo").longValue() * par("sentMsgFixedDelay").doubleValue() - sentMsgDelay;
  scheduleEvent(DENSITY_METRICS, t, densityEvent);
}

void DensityCoefficients::scheduleEvent(short kind, double delay, cMessage* selfMsgPtr) {
  simtime_t t = simTime() + delay;
  selfMsgPtr->setKind(kind);
  scheduleAt(t, selfMsgPtr);
}

void DensityCoefficients::processStart() {
  mobilityModel = check_and_cast<IMobility*>(getContainingNode(this)->getSubmodule("mobility"));

  const char* id = getParentModule()->getFullName();
  nodeId = id;
  metrics.setNodeId(nodeId);

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

  localAddress = L3AddressResolver().resolve(id);

  socket.setOutputGate(gate("udpOut"));
  socket.bind(localAddress, localPort);
  UDPBasicApp::setSocketOptions();

  L3AddressResolver().tryResolve(par("destAddresses"), broadcastAddress);
  if (broadcastAddress.isUnspecified())
    throw cRuntimeError("invalid broadcast address");

  UDPBasicApp::processSend();
  emit(runningProtocol, Zone::UNDETERMINED);

  cMsgPar* d = new cMsgPar("density");
  d->setDoubleValue(-1);
  cMsgPar* name = new cMsgPar("name");
  name->setStringValue("");
  cMsgPar* name1 = new cMsgPar("name");
  name1->setStringValue("");
  cMsgPar* algoId = new cMsgPar("algoId");
  algoId->setDoubleValue(-1);

  willToChangeEv->addPar(d);
  willToChangeEv->addPar(name);

  changeNowEv->addPar(name1);
  changeNowEv->addPar(algoId);
}

void DensityCoefficients::handleMessageWhenUp(cMessage* msg) {
//  log("Event [" + to_string(msg->getKind()) + "]");
  if (msg->isSelfMessage() && selfEvent(msg)) {
    switch (msg->getKind()) {
      case SEND_HELLO_MSG: {
//        log("sending hello msg");
        UDPBasicApp::socket.sendTo(getHelloMsg(), broadcastAddress, UDPBasicApp::destPort);
      }
        break;
      case SEND_CTRL_MSG: {
//        log("sending control msg");
        Coord c = mobilityModel->getCurrentPosition();
        emit(positionAtX, c.x);
        emit(positionAtY, c.y);
        UDPBasicApp::socket.sendTo(getCtrlMsg(), broadcastAddress, UDPBasicApp::destPort);
      }
        break;
      case GET_DENSITY_METRICS: {
//        log("get density metric");
//        printNeighbors();
        metrics.setNeighbors(_1hopNeigs, _2hopNeigs);
        log("My density is: " + to_string(metrics.getDensity()));
        emit(clusteringCoef, metrics.getClusteringCoef());
        emit(closureCoef, metrics.getClosureCoef());
        if (par("isSourceNode").boolValue()) {
          emit(runningProtocol, Zone::DENSE);
          log("Sending WillToChange message");
          string msgName = "ChangeMsg-" + to_string(changeMsgId);
          UDPBasicApp::socket.sendTo(getChangeMsg(msgName.c_str(), metrics.getDensity()), broadcastAddress,
              UDPBasicApp::destPort);
          receivedMsgs.insert(msgName);
          changeMsgId++;
        }
      }
        break;
      case FWD_WILL_TO_CHANGE: {
        log("FWD_WILL_TO_CHANGE of msg: " + string(msg->par("name").stringValue()));
        UDPBasicApp::socket.sendTo(getChangeMsg(msg->par("name").stringValue(), msg->par("density").longValue()),
            broadcastAddress, UDPBasicApp::destPort);
      }
        break;
      case UPDATE_WILL_TO_CHANGE: {
        log("UPDATE_WILL_TO_CHANGE of msg: " + string(msg->par("name").stringValue()));
        UDPBasicApp::socket.sendTo(getChangeNowMsg(msg->par("name").stringValue(), msg->par("algoId").longValue()),
            broadcastAddress, UDPBasicApp::destPort);
      }
        break;
      case FWD_CHANGE_NOW_MSG: {
        log("FWD_CHANGE_NOW_MSG of msg: " + string(msg->par("name").stringValue()));
        UDPBasicApp::socket.sendTo(getChangeNowMsg(msg->par("name").stringValue(), msg->par("algoId").longValue()),
            broadcastAddress, UDPBasicApp::destPort);
      }
        break;
      default:
        throw cRuntimeError("Invalid kind %d in self message", (int) msg->getKind());
        break;
    }
  } else {
    UDPBasicApp::handleMessageWhenUp(msg);
  }
}

void DensityCoefficients::processPacket(cPacket* msg) {
  if (getSrcAddress(msg) == localAddress) {
    delete msg;
    return;
  }
  int msgType = msg->par("PkType").longValue();
  switch (msgType) {
    case PacketType::HELLO_PK: {
//      log("hello message [" + to_string(msgType) + "] from [" + h->getSender() + "]");

      Hello* h = static_cast<Hello*>(msg);
      _1hopNeigs.insert(h->getSender());
    }
      break;
    case PacketType::CTRL_PK: {
//      log("control message [" + to_string(msgType) + "] from [" + n->getSender() + "]");

      OneHopNeighbors* n = static_cast<OneHopNeighbors*>(msg);
      string sender(n->getSender());
      _1hopNeigs.insert(sender);

      Neighbors neigs = n->getNeigs();
      _2hopNeigs[sender].clear();
      for (Neighbors::iterator i = neigs.begin(); i != neigs.end(); ++i) {
        _2hopNeigs[sender].insert(*i);
      }
    }
      break;
    case PacketType::WILL_TO_CHANGE_PK: {
      Change* c = static_cast<Change*>(msg);
      if (receivedMsgs.find(msg->getName()) == receivedMsgs.end()) {
        receivedMsgs.insert(msg->getName());

        cMsgPar* name = new cMsgPar("name");
        name->setStringValue(msg->getName());

        int sourceNodeDensity = c->getDensity();
        if (sourceNodeDensity - metrics.getDensity() == sourceNodeDensity) {
          // border node
          log("[Border] My new density is: " + to_string(Zone::SPARSE));
          emit(runningProtocol, Zone::SPARSE);

          changeNowEv->getParList().remove("name");
          changeNowEv->getParList().remove("algoId");

          cMsgPar* iD = new cMsgPar("algoId");
          iD->setDoubleValue(Zone::SPARSE);
          changeNowEv->addPar(name);
          changeNowEv->addPar(iD);

          scheduleEvent(UPDATE_WILL_TO_CHANGE, par("sentMsgFixedDelay").doubleValue() + sentMsgDelay, changeNowEv);
        } else {
          // at zone with high or medium density
          log("[Same Density] My new density is: " + to_string(Zone::DENSE));
          emit(runningProtocol, Zone::DENSE);

          willToChangeEv->getParList().remove("name");
          willToChangeEv->getParList().remove("density");

          cMsgPar* d = new cMsgPar("density");
          d->setDoubleValue(sourceNodeDensity);
          willToChangeEv->addPar(name);
          willToChangeEv->addPar(d);

          scheduleEvent(FWD_WILL_TO_CHANGE, par("sentMsgFixedDelay").doubleValue() + sentMsgDelay, willToChangeEv);
        }
      }
    }
      break;
    case PacketType::CHANGE_NOW: {
      ChangeNow* c = static_cast<ChangeNow*>(msg);
      if (receivedMsgs.find(msg->getName()) == receivedMsgs.end()) {
        receivedMsgs.insert(msg->getName());

        log("[CHANGE NOW] My new density is: " + to_string(c->getAlgoId()));
        emit(runningProtocol, c->getAlgoId());

        changeNowEv->getParList().remove("name");
        changeNowEv->getParList().remove("algoId");

        cMsgPar* iD = new cMsgPar("algoId");
        iD->setDoubleValue(c->getAlgoId());
        cMsgPar* name1 = new cMsgPar("name");
        name1->setStringValue(msg->getName());

        changeNowEv->addPar(name1);
        changeNowEv->addPar(iD);

        scheduleEvent(FWD_CHANGE_NOW_MSG, par("sentMsgFixedDelay").doubleValue() + sentMsgDelay, changeNowEv);
      }
    }
      break;
    default:
      throw cRuntimeError("Invalid kind of msg %d in self message", msgType);
      break;
  }
  delete msg;
}

cPacket* DensityCoefficients::getHelloMsg() {
  cMsgPar* p = new cMsgPar("PkType");
  p->setLongValue(PacketType::HELLO_PK);

  Hello* h = new Hello();
  h->setSender(nodeId.c_str());
  h->addPar(p);
  return h;
}

cPacket* DensityCoefficients::getCtrlMsg() {
  cMsgPar* p = new cMsgPar("PkType");
  p->setLongValue(PacketType::CTRL_PK);

  OneHopNeighbors* n = new OneHopNeighbors();
  n->setSender(nodeId.c_str());
  n->addPar(p);
  Neighbors neigs;
  for (set<string>::iterator i = _1hopNeigs.begin(); i != _1hopNeigs.end(); ++i) {
    neigs.insert(*i);
  }
  n->setNeigs(neigs);
  return n;
}

cPacket* DensityCoefficients::getChangeMsg(const char* name, int density) {
  cMsgPar* p = new cMsgPar("PkType");
  p->setLongValue(PacketType::WILL_TO_CHANGE_PK);

  Change* c = new Change(name);
  c->setSender(nodeId.c_str());
  c->setDensity(density);
  c->addPar(p);
  return c;
}

cPacket* DensityCoefficients::getChangeNowMsg(const char* name, int algoID) {
  cMsgPar* p = new cMsgPar("PkType");
  p->setLongValue(PacketType::CHANGE_NOW);

  ChangeNow* c = new ChangeNow(name);
  c->setSender(nodeId.c_str());
  c->setAlgoId(algoID);
  c->addPar(p);
  return c;
}
