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

#include <ControlledFlooding.h>
#include <common/InteroperableBroadcast.h>
#include <msgs/Basic_m.h>

bool ControlledFlooding::onBroadcastMsg(cPacket* pk, const char* pkName) {
  // tag packet as received
  bool firstReception = false;
  string timerName("CfTimer-" + string(pkName));
  if (controller->receivedMsg.find(pkName) == controller->receivedMsg.end()) {
    controller->log("1st reception of  " + string(pkName));
    firstReception = true;
    controller->receivedMsg.insert(pkName);

    timers[timerName] = new cMessage(timerName.c_str());
    counters[timerName] = 1;
    msgs[timerName] = pk->dup();
    msgs[timerName]->getParList().remove("Sender");
    controller->addSender(msgs[timerName]);
    //
    double t = controller->getRandWaitingTime() * controller->par("macWaitingTimeFactor").doubleValue();
    controller->log("CF timer: " + to_string(t));
    controller->scheduleEvent(Timer::EXPIRES, t, timers[timerName]);
    controller->log("Timer scheduled !");
  } else {
    if (counters.find(timerName) != counters.end()) {
      counters[timerName]++;
      controller->log("msg: " + timerName + ", copies: " + to_string(counters[timerName]));
      if (counters[timerName] >= allowedReceptions) {
        if (timers[timerName]) {
          controller->log("msg: " + timerName + ", threshold reached !");
          controller->cancelAndDelete(timers[timerName]);
          timers.erase(timerName);
          counters.erase(timerName);
          msgs.erase(timerName);
        }
      }
    }
  }
  return firstReception;
}

void ControlledFlooding::initialize(bool firstCall) {
  cancelSelfEvents();
  controller->log("Running protocol: " + controller->getProtocolName(controller->CONTROLLED_FLOODING));
  allowedReceptions = controller->par("counterCfcondition").longValue();
}

cPacket* ControlledFlooding::createBroadcastMsg(const char* msgId) {
  Broadcast* m = new Broadcast(msgId);
  m->setRunningProtocol(controller->CONTROLLED_FLOODING);
  return m;
}

int ControlledFlooding::getFwdType() {
  return controller->SIMPLE;
}

bool ControlledFlooding::isProtocolEvent(cMessage* msg) {
  string event = string(msg->getName());
//  controller->log("Handling: " + event);
  return timers.find(event) != timers.end() && timers[event] == msg ? true : false;
}

void ControlledFlooding::handleEvent(cMessage* msg) {
  string event(msg->getName());
  controller->log("Timer expire for: " + event);
  if (timers.find(event) != timers.end() && counters.find(event) != counters.end()) {
    if (timers[event] == msg && counters[event] < allowedReceptions) {
      controller->log("Sending msg: " + event + ", copies: " + to_string(counters[event]));

      controller->send(msgs[event]);
      controller->emit(controller->sentBroadcastMsg,
          controller->getMsgId(msgs[event]->getName(), controller->getBroadcastMsgName()));
      if (controller->isBorderNode) {
        controller->emit(controller->forward_type, controller->ForwardType::BORDER_NODE);
      } else {
        controller->emit(controller->forward_type, getFwdType());
      }
      timers.erase(event);
      counters.erase(event);
      msgs.erase(event);
    }
  }

}

bool ControlledFlooding::amIoverlayRelay() {
  return false;
}

void ControlledFlooding::cancelSelfEvents() {
  for (map<string, cMessage*>::iterator it = timers.begin(); it != timers.end(); ++it) {
    controller->cancelAndDelete(it->second);
  }
  msgs.clear();
  timers.clear();
  counters.clear();

}
