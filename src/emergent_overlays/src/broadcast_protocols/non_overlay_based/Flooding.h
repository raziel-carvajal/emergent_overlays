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

#ifndef FLOODING_H_
#define FLOODING_H_

#include <utils/IProtocol.h>

class Flooding : public IProtocol {
  private:
    InteroperableBroadcast* controller = nullptr;

  public:
    Flooding() {
    }

    bool isProtocolEvent(cMessage* msg) {
      // this implementation do not handle any self event
      return true;
    }

    void setController(InteroperableBroadcast* c) {
      controller = c;
    }
    void onBroadcastMsg(cPacket* pk, const char* pkName);

    void handleEvent(cMessage* msg) {}
    void addProtocolHeaders(cPacket* pk) {}
    void updateProtocolHeaders(cPacket* pk) {}
    void cancelSelfEvents() {}
    void initialize();
    void onControlMsg(cPacket* pk, const char* sender) {}

    cPacket* createBroadcastMsg(const char* msgId);

    int getFwdType();
};

#endif /* FLOODING_H_ */
