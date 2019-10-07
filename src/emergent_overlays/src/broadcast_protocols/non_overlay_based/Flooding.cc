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

#include <Flooding.h>
#include <common/InteroperableBroadcast.h>
#include <msgs/Basic_m.h>

bool Flooding::onBroadcastMsg(cPacket* pk, const char* pkName) {
  bool firstReception = false;
  // tag packet as received
  if (controller->receivedMsg.find(pkName) == controller->receivedMsg.end()) {
    controller->log("FWD message " + string(pkName));
    firstReception = true;
    controller->receivedMsg.insert(pkName);
    // forward iff message wasn't hear before
    controller->fwdBroadcastMsg(pk);
  }
  return firstReception;
}

cPacket* Flooding::createBroadcastMsg(const char* msgId) {
  Broadcast* m = new Broadcast(msgId);
  m->setRunningProtocol(controller->FLOODING);
  return m;
}

void Flooding::initialize(bool firstCall) {
  controller->log("Running protocol: " + controller->getProtocolName(controller->FLOODING));
  cancelSelfEvents();
}

int Flooding::getFwdType() {
  return controller->SIMPLE;
}

bool Flooding::amIoverlayRelay() {
  return false;
}
