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
      BUILD_CDS, SCHEDULE_CTRL_MSGS, SEND_CTRL_MSG, FWD_BROADCAST_MSG
    };

    double similarity;
    bool previousDec;

    int viewSize;
    int sentBootEvents = 1;

    set<string> latestPayload;

    cMessage* buildCdsTimer = nullptr;
    cMessage* sCtrlMsgTimer = nullptr;
    cMessage* fwdBrMsgTimer = nullptr;

    set<string> currentMpr;
    set<string> previousNeigs;

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

    bool neigsChanged() {
      double ratio;
      double currentSim = 0.0;
      if (previousNeigs.size() < neighbors.size()) {
        ratio = 1 / (1.0 * neighbors.size());
        for (set<string>::iterator it = previousNeigs.begin(); it != previousNeigs.end(); ++it) {
          if (neighbors.find(*it) != neighbors.end())
            currentSim += ratio;
        }
      } else {
        ratio = 1 / (1.0 * previousNeigs.size());
        for (auto it = neighbors.begin(); it != neighbors.end(); ++it) {
          if (previousNeigs.find(it->first) != previousNeigs.end())
            currentSim += ratio;
        }
      }
      return currentSim >= similarity ? false : true;
    }

  public:

    Mpr() {
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
    void initialize();
    void sendCtrlMsg();
    void onControlMsg(cPacket* pk, const char* sender);

    cPacket* createBroadcastMsg(const char* msgId);
    cPacket* getCtrlMsg();

    int getFwdType();
};

#endif /* MPR_H_ */
