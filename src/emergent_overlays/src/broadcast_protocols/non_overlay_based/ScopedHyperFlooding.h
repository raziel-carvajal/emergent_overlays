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

#ifndef SCOPEDHYPERFLOODING_H_
#define SCOPEDHYPERFLOODING_H_

#include <utils/IProtocol.h>
#include <cmessage.h>

using namespace std;

class ScopedHyperFlooding : public IProtocol {
  private:

    enum Timers {
      SEND_CTRL_MSG
    };

    set<string> neighbors;

    InteroperableBroadcast* controller = nullptr;

    cMessage* sendCtrlMsgTimer = new cMessage("sendCtrlMsgTimer");

    int ctrlMsgId = 0;

    double sentCtrlMsgDelay;
    double minSentDelay;
    double neigSimilarity;

  public:
    ScopedHyperFlooding() {
    }

    cPacket* getCtrlMsg();
    bool isProtocolEvent(cMessage* msg);

    void setController(InteroperableBroadcast* c) {
      controller = c;
    }
    bool onBroadcastMsg(cPacket* pk, const char* pkName);

    void handleEvent(cMessage* msg);

    void addProtocolHeaders(cPacket* pk) {
    }
    void updateProtocolHeaders(cPacket* pk) {
    }
    void cancelSelfEvents();
    void initialize(bool firstCall);
    void onControlMsg(cPacket* pk, const char* sender);

    cPacket* createBroadcastMsg(const char* msgId);

    int getFwdType();

    bool amIoverlayRelay();

    set<string> getNeighbors() {
      set<string> neigs;
      return neigs;
    }
};

#endif /* SCOPEDHYPERFLOODING_H_ */
