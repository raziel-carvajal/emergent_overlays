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

#ifndef MACLAYERWITHCD_H_
#define MACLAYERWITHCD_H_

#include <set>
#include <map>
#include <msgs/Basic_m.h>

using namespace std;

class cPacket;
class cMessage;
class InteroperableBroadcast;

class MacLayerWithCD {
  private:
    enum Events {
      WAIT_PONG_MSGs, SEND_PONG, WAIT_ACKs, SEND_ACK, RESET_STATE
    };

    int collisions;
    int ongoingTry;
    int payloadType;
    int MAX_TRIES;

    string ongoingSession;

    bool amIsender;

    set<string> neighbors;
    set<string> ackSenders;

    InteroperableBroadcast* controller = nullptr;

    cPacket* payload;

    cMessage* waitPongTimer = new cMessage("waitPongTimer");
    cMessage* deliveryTimer = new cMessage("deliveryTimer");
    cMessage* resetTimer = new cMessage("resetTimer");
    cMessage* waitAcksTimer = new cMessage("waitAcksTimer");

  private:
    void resetStatus();

    cPacket* getPingPk();
    cPacket* getPongPk();
    cPacket* getAckPk();

  public:
    MacLayerWithCD() {
    }
    virtual ~MacLayerWithCD() {
    }
    void send(cPacket* pk);
    void recv(cPacket* pk);
    void processPingPk(Ping* pk);
    void processPongPk(Pong* pk);
    void processAckPk(Ack* pk);
    void processMsg(const char* id);
    void handleEvent(cMessage* e);
    void initialize();
    void setController(InteroperableBroadcast* c);

    bool isSelfEvent(cMessage* e);

    double getWaitingMsgDeliveryTime();
    double getWaitingMsgReceptionTime();
    double getMaxDisseminationTime();
    double getLowerBoundWaitingTime();
    double getUpperBoundWaitingTime();
};

#endif /* MACLAYERWITHCD_H_ */
