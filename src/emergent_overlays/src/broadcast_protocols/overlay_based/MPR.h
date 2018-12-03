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

#include <common/InteroperableBroadcast.h>
#include <inet/common/geometry/common/Coord.h>
#include <broadcast_protocols/overlay_based/MPR_m.h>

using namespace std;

class MPR : public InteroperableBroadcast {
  private:
    enum MprTimers {
      SEND_CTRL_MSG_TO_BOOT, BUILD_CDS, SEND_CTRL_MSG, FWD_BROADCAST_MSG
    };

    int sentBootEvents = 1;

    cMessage* buildCdsTimer = nullptr;
    cMessage* sCtrlMsgTimer = nullptr;
    cMessage* fwdBrMsgTimer = nullptr;

    virtual void onBroadcastMsg(cPacket* pk, string sender);
    virtual void onControlMsg(cPacket* pk, string sender);
    virtual void cancelSelfEvents() {
      cancelAndDelete(buildCdsTimer);
      cancelAndDelete(sCtrlMsgTimer);
      cancelAndDelete(fwdBrMsgTimer);
    }

    // variables/methods to implement MPR V0.0.1
    set<string> currentMpr;

    map<string, set<string>> neighbors;

    map<string, Coord> neigsPositions;

    array<set<string>, 2> hops;

    map<string, set<string>> make_cpy(map<string, set<string>> a) {
      map<string, set<string>> b;
      for (auto it = a.begin(); it != a.end(); ++it) {
        for (set<string>::iterator it1 = a[it->first].begin(); it1 != a[it->first].end(); ++it1)
          b[it->first].insert(*it1);
      }
      return b;
    }
    bool is_a_covered_by_b(string a, string b) {
      Coord pA = neigsPositions[a];
      Coord pB = neigsPositions[b];
      double tx = InteroperableBroadcast::transRadious;
      if (!pA.isNil() && !pB.isNil())
        return (tx * tx > (pA.x - pB.x) * (pA.x - pB.x) + (pA.y - pB.y) * (pA.y - pB.y));
      else
        return false;
    }
    set<string> compute_mpr();
    cPacket* buildBroadcastMsg(const char* header);

  protected:

    virtual void initialize(int stage) override;
    virtual void handleMessageWhenUp(cMessage *msg) override;
    virtual cPacket* getCtrlMsg() override;
    virtual void sendPacket() override;
    virtual void sendCtrlMsg() override;
    virtual void processStart() override;

  public:
    MPR() {
    }
    ~MPR() {
    }
};

#endif /* MPR_H_ */
