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

#ifndef MPR_H_
#define MPR_H_

#include <utils/IProtocol.h>
#include <inet/common/geometry/common/Coord.h>

using namespace std;

class Mpr : public IProtocol {
  private:

    enum MprTimers {
      BUILD_CDS, SCHEDULE_FIRST_CTRL_MSG, SCHEDULE_CTRL_MSGS, SEND_CTRL_MSG, FWD_BROADCAST_MSG
    };

    bool isOverlayRelay = false;

    int viewSize;
    int sentBootEvents = 1;
    int nodesNo;
    int ctrlMsgId = 0;
    int sentCtrlMsgFreq = 0;

    double sentCtrlMsgDelay;
    double minSentDelay;

    string ctrlMsgName = "1ctrlMsg-";

    cMessage* buildCdsTimer = new cMessage("buildCdsTimer");
    cMessage* sCtrlMsgTimer = new cMessage("sCtrlMsgTimer");
    cMessage* fwdBrMsgTimer = new cMessage("fwdBrMsgTimer");
    cMessage* sRemainingCtrlMsgTimer = new cMessage("sRemainingCtrlMsgTimer");

    set<string> currentMpr;

    map<string, set<string>> neighbors;

    map<string, inet::Coord> neigsPositions;

    array<set<string>, 2> hops;

    InteroperableBroadcast* controller = nullptr;

  private:

    map<string, set<string>> make_cpy(map<string, set<string>> a) {
      map<string, set<string>> b;
      for (auto it = a.begin(); it != a.end(); ++it) {
        for (set<string>::iterator it1 = a[it->first].begin(); it1 != a[it->first].end(); ++it1)
          b[it->first].insert(*it1);
      }
      return b;
    }

    bool is_a_covered_by_b(string a, string b);

    set<string> compute_mpr();

    bool amIrelay(set<string> senderNeigs);

  public:

    Mpr() {
    }

    bool isProtocolEvent(cMessage* msg);

    void setController(InteroperableBroadcast* c) {
      controller = c;
    }
    bool onBroadcastMsg(cPacket* pk, const char* pkName);

    void handleEvent(cMessage* msg);
    // FIXME add headers for interop mechanism
    void addProtocolHeaders(cPacket* pk) {
    }
    void updateProtocolHeaders(cPacket* pk) {
    }
    void cancelSelfEvents();
    void initialize(bool firstCall);
    void sendCtrlMsg();
    void onControlMsg(cPacket* pk, const char* sender);

    cPacket* createBroadcastMsg(const char* msgId);
    cPacket* getCtrlMsg(int withName);

    int getFwdType();

    bool amIoverlayRelay();

    set<string> getNeighbors() {
      set<string> neigs;
      for (auto it = neighbors.begin(); it != neighbors.end(); it++) {
        neigs.insert(it->first);
      }
      return neigs;
    }
};

#endif /* MPR_H_ */
