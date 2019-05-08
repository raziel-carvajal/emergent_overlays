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

#ifndef CONTROLLEDFLOODING_H_
#define CONTROLLEDFLOODING_H_

#include <utils/IProtocol.h>
#include <map>

using namespace std;

class ControlledFlooding : public IProtocol {
  private:
    InteroperableBroadcast* controller = nullptr;

    map<string, cMessage*> timers;
    map<string, int> counters;
    map<string, cPacket*> msgs;

    enum Timer { EXPIRES };

    int allowedReceptions;

  public:
    ControlledFlooding() {
    }

    bool isProtocolEvent(cMessage* msg);

    void setController(InteroperableBroadcast* c) {
      controller = c;
    }
    void onBroadcastMsg(cPacket* pk, const char* pkName);

    void handleEvent(cMessage* msg);

    void addProtocolHeaders(cPacket* pk) {
    }
    void updateProtocolHeaders(cPacket* pk) {
    }
    void cancelSelfEvents();
    void initialize(bool firstCall);
    void onControlMsg(cPacket* pk, const char* sender) {
    }

    cPacket* createBroadcastMsg(const char* msgId);

    int getFwdType();

    bool amIoverlayRelay();

    set<string> getNeighbors() {
      set<string> neigs;
      return neigs;
    }
};

#endif /* CONTROLLEDFLOODING_H_ */
