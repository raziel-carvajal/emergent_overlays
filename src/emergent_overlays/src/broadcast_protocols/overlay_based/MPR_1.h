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

#ifndef MPR_1_H_
#define MPR_1_H_

#include <common/InteroperableBroadcast.h>
#include <broadcast_protocols/overlay_based/MPR_1_m.h>

using namespace std;

class MPR_1 : public InteroperableBroadcast {
  private:
    enum Mpr_1_Timers {
      SEND_CTRL_MSG_TO_BOOT, SEND_CTRL_MSG, FWD_BROADCAST_MSG, FWD_CTRL_MSG, WAIT_CTRL_MSG_DISS
    };

    int sentBootEvents = 1;
    int ctrlMsgC1id = 1;

    cMessage* initNeigTimer = nullptr;
    cMessage* sCtrlMsgTimer = nullptr;
    cMessage* fwdBrMsgTimer = nullptr;
    cMessage* rCtrlMsgTimer = nullptr;

    set<string> _1hopNeigs;
    set<string> recvCtrlMsgs;
    set<string> _2hopNodesWithOneNeig;

    map<string, set<string>> _2hopNeigs;

    set<string> getMprSet(string ignoredNode);

    void eraseLocalState();

  protected:
    virtual void initialize(int stage) override;
    virtual void handleMessageWhenUp(cMessage *msg) override;
    virtual cPacket* getCtrlMsg() override;
    virtual void sendPacket() override;
    virtual void sendCtrlMsg() override;

    cPacket* buildBroadcastMsg(const char* header, string discartedNode);
    virtual cPacket* getCtrlMsgC1();
    virtual cPacket* getCtrlMsgC1(string header, string emitter, int hops);

    virtual void onBroadcastMsg(cPacket* pk, string sender);
    virtual void onControlMsg(cPacket* pk, string sender);
    virtual void cancelSelfEvents() {
      cancelAndDelete(initNeigTimer);
      cancelAndDelete(sCtrlMsgTimer);
      cancelAndDelete(fwdBrMsgTimer);
      cancelAndDelete(rCtrlMsgTimer);
    }

  public:
    MPR_1() {
    }
    ~MPR_1() {
    }
};

#endif /* MPR_1_H_ */
