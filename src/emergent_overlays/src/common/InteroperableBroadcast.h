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

#include <MacLayerWithCD.h>
#include <inet/applications/udpapp/UDPBasicApp.h>
#include <inet/mobility/contract/IMobility.h>
#include <functional>
#include <utils/IProtocol.h>
#include <utils/Observables.h>
#include <utils/SwitchingCriteria.h>

// implementations of broadcast protocols
#include <broadcast_protocols/overlay_based/MPR.h>
#include <broadcast_protocols/non_overlay_based/Flooding.h>
#include <broadcast_protocols/non_overlay_based/ControlledFlooding.h>
#include <broadcast_protocols/non_overlay_based/AdaptiveControlledFlooding.h>
#include <broadcast_protocols/non_overlay_based/ScopedHyperFlooding.h>

using namespace inet;
using namespace std;

class InteroperableBroadcast : public UDPBasicApp {
  private:
    enum Timer {
      HALT_APP = 1, FWD_BROADCAST_MSG, SEND_BROADCAST_MSG, STORE_POSITION, SEND_BORDER_REQ, RESET_BORDER_STATUS
    };

    int runningProtocolId;
    int* sourceNodes = nullptr;

    IProtocol* runningProtocol = nullptr;

    cMessage* haltSimTimer = new cMessage("haltSimTimer");
    cMessage* broaMsgTimer = new cMessage("broaMsgTimer");
    cMessage* motionTimer = new cMessage("motionTimer");
    cMessage* fwdBMsgTimer = new cMessage("fwdBMsgTimer");
    cMessage* borderMsgTimer = new cMessage("borderMsgTimer");
    cMessage* resetBorderTimer = new cMessage("resetBorderTimer");

    set<int> knownForeignAlgos;

    cPacket* latestPkToFwd = nullptr;

    L3Address localAddress;
    L3Address broadcastAddress;

    Observables* collector = nullptr;

    SwitchingCriteria* switchingPolicy = nullptr;

  private:
    void intializeCatalog() {
      for (int i = 0; i < Protocols::LAST_PROTOCOL; ++i) {
        switch (i) {
          case Protocols::FLOODING: {
            protocols[i] = new Flooding();
            protocolsNames[i] = getProtocolName(FLOODING);
          }
            break;
          case Protocols::MPR: {
            protocols[i] = new Mpr();
            protocolsNames[i] = getProtocolName(MPR);
          }
            break;
          case Protocols::CONTROLLED_FLOODING: {
            protocols[i] = new ControlledFlooding();
            protocolsNames[i] = getProtocolName(CONTROLLED_FLOODING);
          }
            break;
          case Protocols::ADAPTIVE_CONTROLLED_FLOODING: {
            protocols[i] = new AdaptiveControlledFlooding(collector);
            protocolsNames[i] = getProtocolName(ADAPTIVE_CONTROLLED_FLOODING);
          }
            break;
          case Protocols::HYPER_SCOPED_FLOODING: {
            protocols[i] = new ScopedHyperFlooding();
            protocolsNames[i] = getProtocolName(HYPER_SCOPED_FLOODING);
          }
            break;
          default:
            throw cRuntimeError("[%d] is an invalid protocol identifier", i);
            break;
        }
        protocols[i]->setController(this);
      }
    }

    cPacket* getBroadcastMsg();
    cPacket* getBorderReqMsg();

    L3Address getSrcAddress(cPacket *msg);

    bool isSelfTimer(cMessage *msg);

    string splitString(string substr, string target) {
      return target.substr(substr.size(), target.size() - substr.size());
    }

//    set<string> choseBorderNodes();

  protected:
    // define a new implementation for some methods of super class (INET::UDPBasicApp)
    virtual void initialize(int stage) override;
    virtual void processStart() override;
    virtual void sendPacket() override;
    virtual void handleMessageWhenUp(cMessage *msg) override;
    virtual void processPacket(cPacket *msg) override;

    string removeQuotes(string target) {
      return target.substr(1, target.size() - 2);
    }

    void setSourceNodesList();

  public:
    enum Protocols {
      FLOODING, MPR, CONTROLLED_FLOODING, ADAPTIVE_CONTROLLED_FLOODING, HYPER_SCOPED_FLOODING, LAST_PROTOCOL
    };
    enum ForwardType {
      SIMPLE, OVERLAY_RELAY, BORDER_NODE
    };
    enum UdpPacket {
      BROADCAST = 1, CTRL, BORDER_REQ, PING, PONG, ACK
    };

    int numSentCtrlMsgs = 0;
    int numRecvCtrlMsgs = 0;
    int broadcastMsgId = 0;

    double transRadious;

    bool isBorderNode = false;

    static simsignal_t rcvdBroadcastMsg;
    static simsignal_t sentBroadcastMsg;
    static simsignal_t positionAtX;
    static simsignal_t positionAtY;
    static simsignal_t forward_type;
    static simsignal_t sentCtrlFrames;
    static simsignal_t recvCtrlFrames;
    static simsignal_t densityObs;
    static simsignal_t mobilityObs;
    static simsignal_t runningAlgorithm;

    IProtocol* protocols[Protocols::LAST_PROTOCOL];

    set<string> receivedMsg;

    string nodeId;
    string ctrlMsgName = "2ctrlMsg-";
    string protocolsNames[Protocols::LAST_PROTOCOL];

    IMobility* mobilityModel;

    MacLayerWithCD* mac = nullptr;

  public:
    InteroperableBroadcast() {
    }
    ~InteroperableBroadcast() {
    }

    void log(string msg) {
      if (par("withDebugging").boolValue()) {
        cout << "[" << nodeId << ", " << simTime() << "] - " << msg << endl;
      } else {
        EV_DEBUG << "[" << nodeId << ", " << simTime() << "] - " << msg << endl;
      }
    }

    void send(cPacket* pk);
    void addBroadcastHeaders(cPacket* pk);
    void addCtrlHeaders(cPacket* pk);
    void addSender(cPacket* pk);
    void fwdBroadcastMsg(cPacket* pk);
    void scheduleEvent(short kind, double delay, cMessage *selfMsgPtr);
    void addPacketType(cPacket* msg, long t);
    void updateRunningAlgorithm(int newAlgo);

    string getProtocolName(Protocols p) {
      switch (p) {
        case FLOODING:
          return "FLOODING";
        case MPR:
          return "MPR";
        case CONTROLLED_FLOODING:
          return "CONTROLLED_FLOODING";
        case ADAPTIVE_CONTROLLED_FLOODING:
          return "ADAPTIVE_CONTROLLED_FLOODING";
        case HYPER_SCOPED_FLOODING:
          return "HYPER_SCOPED_FLOODING";
        default:
          return "UNKNOWN";
      }
    }
    string getBroadcastMsgName() {
      return this->packetName;
    }

    int getMsgId(string msgHeader, string substr);
    int turnNodeIdToInt();

    double getRandomTime(double a, double b) {
      return uniform(a, b);
    }
    double getRandWaitingTime() {
      double t0 = mac->getLowerBoundWaitingTime();
      double t1 = mac->getUpperBoundWaitingTime();
      return uniform(t0, t1);
    }
};

#endif /* INTEROPERABLEBROADCAST_H_ */
