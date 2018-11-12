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

#ifndef INTEROPERABLEBROADCAST_H_
#define INTEROPERABLEBROADCAST_H_

#include <inet/applications/udpapp/UDPBasicApp.h>
#include <inet/mobility/contract/IMobility.h>
#include <functional>

using namespace inet;
using namespace std;

class InteroperableBroadcast : public UDPBasicApp {

  protected:
    // define a new implementation for some methods of super class (INET::UDPBasicApp)
    virtual void initialize(int stage) override;
    virtual void processStart() override;
    virtual void sendPacket() override;
    virtual void handleMessageWhenUp(cMessage *msg) override;
    virtual void processPacket(cPacket *msg) override;

    enum UdpPacket {
      BROADCAST = 1, CTRL, BORDER
    };
    enum Timer {
      HALT_APP = 1, SEND_CTRL_MSG, BROADCAST_SESSION, MONITOR, BORDER_DETECTOR
    };
    enum ForwardType {
      SIMPLE, CDS_RELAY, BORDER_NODE
    };
    // attributes that are accessible from subclasses of InteroperableBroadcast
    bool amIborderNode = false;

    double transRadious;

    string nodeId;

    set<string> receivedMsg;
    set<string> receivedBorderMsgs;

    L3Address localAddress;
    L3Address broadcastAddress;

    IMobility* mobilityModel;

    // methods that sub-classes may override
    virtual void onBroadcastMsg(cPacket* pk);
    virtual void onControlMsg(cPacket* pk);
    virtual void cancelSelfEvents();
    virtual cPacket* getCtrlMsg();

    // signals for this class
    static simsignal_t rcvdBroadcastMsg;
    static simsignal_t sentBroadcastMsg;
    static simsignal_t positionAtX;
    static simsignal_t positionAtY;
    static simsignal_t forward_type;
//    static simsignal_t density_approximation;

    void fwdBroadcastMsg(cPacket* pk);
    int getMsgId(const char* msgHeader);
    void scheduleEvent(short kind, double delay, cMessage *selfMsgPtr);
    void addPacketType(cPacket* msg, long t);
    void addSender(cPacket* pk);
    void addSendersRunningAlgo(cPacket* pk);

    template<typename T> bool isPacket(cPacket* pkt, function<void(const T*)> action) {
      T* t = dynamic_cast<T*>(pkt);
      if (t != nullptr) {
        action(t);
        return true;
      } else {
        return false;
      }
    }
    cMessage* monitorTimer = nullptr;
  private:

    cMessage* ctrlMsgTimer = nullptr;
    cMessage* haltSimTimer = nullptr;
    cMessage* broaMsgTimer = nullptr;

    set<string> knownNeigs;

    L3Address getSrcAddress(cPacket *msg);

    string runningAlgorithm;

    map<string, set<string>> knownForeignNodes;
    map<string, cMessage*> borderNodeTimers;

    bool isSelfTimer(cMessage *msg);
    bool isBorderDetectorTimer(cMessage *msg);
    void detectBorderNode(string sender, string sendersAlgo);
    cPacket* makeBorderMessage(const char* foreignAlgo, const char* chosenNode, double hopsToLive);

    // misc functions
    string splitString(string substr, string target) {
      return target.substr(substr.size(), target.size() - substr.size());
    }
    string removeQuotes(string target) {
      return target.substr(1, target.size() - 2);
    }

  public:
    InteroperableBroadcast() {
    }
    ~InteroperableBroadcast() {
    }
};

#endif /* INTEROPERABLEBROADCAST_H_ */
