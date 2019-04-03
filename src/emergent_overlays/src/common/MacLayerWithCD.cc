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

#include <MacLayerWithCD.h>
#include <InteroperableBroadcast.h>

void MacLayerWithCD::resetStatus() {
  collisions = 0;
  ongoingTry = 0;
  payloadType = -1;
  ongoingSession = "";
  amIsender = false;
  neighbors.clear();
  ackSenders.clear();
  payload = nullptr;
}

void MacLayerWithCD::send(cPacket* pk) {
  resetStatus();

  amIsender = true;
  payload = pk->dup();
  payloadType = payload->par("PkType").longValue();
  ongoingSession = payload->getName();
  controller->log("[" + ongoingSession + "] payload type [" + to_string(payloadType) + "]");

  cPacket* ping = getPingPk();
  controller->send(ping);
  controller->log("[" + ongoingSession + "] sending PingPk");
  if (!waitPongTimer->isScheduled()) {
    controller->scheduleEvent(WAIT_PONG_MSGs, getWaitingMsgReceptionTime(), waitPongTimer);
  }
}

void MacLayerWithCD::initialize() {
  MAX_TRIES = controller->par("maxRetriesAtMac").longValue();
  resetStatus();
}

cPacket* MacLayerWithCD::getPingPk() {
  Ping* ping = new Ping(ongoingSession.c_str());
  controller->addPacketType(ping, controller->PING);
  return ping;
}

cPacket* MacLayerWithCD::getPongPk() {
  Pong* pong = new Pong(ongoingSession.c_str());
  pong->setSender(controller->nodeId.c_str());
  controller->addPacketType(pong, controller->PONG);
  return pong;
}

void MacLayerWithCD::recv(cPacket* pk) {
}

void MacLayerWithCD::processPingPk(Ping* pk) {
  string sessionId(pk->getName());
  ongoingSession = sessionId;
  double t = getWaitingMsgDeliveryTime();
  controller->log("[" + ongoingSession + "] Ping packet received, schedule event in [" + to_string(t) + "]s");
  if (!deliveryTimer->isScheduled()) {
    controller->scheduleEvent(SEND_PONG, t, deliveryTimer);
  }
}

void MacLayerWithCD::processPongPk(Pong* pk) {
  controller->log("[" + ongoingSession + "] Pong packet received");
  if (ongoingSession == pk->getName()) {
    controller->log("[" + ongoingSession + "] PongPk reception, new neighbor [" + pk->getSender() + "]");
    neighbors.insert(pk->getSender());
  }
}

void MacLayerWithCD::handleEvent(cMessage* e) {
  switch (e->getKind()) {
    case WAIT_PONG_MSGs: {
      controller->log("[" + ongoingSession + "] sending payload for 1st time");
      controller->send(payload);
      ++ongoingTry;
      if (!waitAcksTimer->isScheduled() && !resetTimer->isScheduled()) {
        controller->scheduleEvent(WAIT_ACKs, getWaitingMsgReceptionTime(), waitAcksTimer);
        controller->scheduleEvent(RESET_STATE, getWaitingMsgReceptionTime() * MAX_TRIES, resetTimer);
      }
    }
      break;
    case SEND_PONG: {
      controller->log("[" + ongoingSession + "] answer with PongPk");
      controller->send(getPongPk());
    }
      break;
    case WAIT_ACKs: {
      if (neighbors != ackSenders) {
        int currentCollisions = neighbors.size() - ackSenders.size();
        collisions += currentCollisions;
        controller->log("[" + ongoingSession + "] collisions (" + to_string(currentCollisions) + ") detected");
        ++ongoingTry;
        if (ongoingTry <= MAX_TRIES) {
          controller->log("[" + ongoingSession + "] retransmit message again");
          controller->send(payload->dup());
          if (!waitAcksTimer->isScheduled()) {
            controller->scheduleEvent(WAIT_ACKs, getWaitingMsgReceptionTime(), waitAcksTimer);
          }
        } else {
          controller->log("[" + ongoingSession + "] maximum number of retransmissions reached for message");
        }
      } else {
        controller->log("[" + ongoingSession + "] all ACKs were received");
      }
    }
      break;
    case SEND_ACK: {
      controller->log("[" + ongoingSession + "] sending ACK");
      controller->send(getAckPk());
    }
      break;
    case RESET_STATE: {
      controller->log("[" + ongoingSession + "] session is over, amIsender=" + to_string(amIsender));
      if (amIsender) {
        switch (payloadType) {
          case controller->BROADCAST: {
            controller->log("]" + ongoingSession + "] record collisions of broadcast message");
            controller->emit(controller->broaMsgCollisions, collisions);
          }
            break;
          case controller->CTRL: {
            controller->log("]" + ongoingSession + "] record collisions of control message");
            controller->emit(controller->ctrlMsgCollisions, collisions);
          }
            break;
          default:
            throw cRuntimeError("Invalid payload type (%d) in MacLayerWithCD", payloadType);
        }
      }
      resetStatus();
    }
      break;
    default:
      throw cRuntimeError("Invalid kind %d in MacLayerWithCD", (int) e->getKind());
  }
}

bool MacLayerWithCD::isSelfEvent(cMessage* e) {
  return e == waitPongTimer || e == deliveryTimer || e == resetTimer || e == waitAcksTimer;
}

double MacLayerWithCD::getWaitingMsgDeliveryTime() {
  double t0 = getLowerBoundWaitingTime();
  double t1 = getUpperBoundWaitingTime();
  return controller->getRandomTime(t0, t1);
}

void MacLayerWithCD::processMsg(const char* id) {
  if (ongoingSession == id) {
    controller->log("[" + ongoingSession + "] payload received from ");
    if (ongoingTry == 0) {
      ++ongoingTry;
      if (!resetTimer->isScheduled()) {
        controller->scheduleEvent(RESET_STATE, getWaitingMsgReceptionTime() * MAX_TRIES, resetTimer);
      }
    }
    if (!deliveryTimer->isScheduled()) {
      controller->scheduleEvent(SEND_ACK, getWaitingMsgDeliveryTime(), deliveryTimer);
    }
  }
}

cPacket* MacLayerWithCD::getAckPk() {
  Ack* a = new Ack(ongoingSession.c_str());
  a->setSender(controller->nodeId.c_str());
  controller->addPacketType(a, controller->ACK);
  return a;
}

void MacLayerWithCD::setController(InteroperableBroadcast* c) {
  controller = c;
}

double MacLayerWithCD::getWaitingMsgReceptionTime() {
  return controller->par("minSentDelay").doubleValue() * 100;
}

void MacLayerWithCD::processAckPk(Ack* pk) {
  if (ongoingSession == pk->getName()) {
    controller->log("[" + ongoingSession + "] ACK received with sender [" + pk->getSender() + "]");
    ackSenders.insert(pk->getSender());
  }
}

double MacLayerWithCD::getMaxDisseminationTime() {
  return getWaitingMsgReceptionTime() * (MAX_TRIES) + controller->par("minSentDelay").doubleValue() * 5;
}

double MacLayerWithCD::getLowerBoundWaitingTime() {
  return controller->par("minSentDelay").doubleValue();
}

double MacLayerWithCD::getUpperBoundWaitingTime() {
  return controller->par("minSentDelay").doubleValue() * 90;
}
