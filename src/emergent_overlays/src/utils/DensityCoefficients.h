////
//// This program is free software: you can redistribute it and/or modify
//// it under the terms of the GNU Lesser General Public License as published by
//// the Free Software Foundation, either version 3 of the License, or
//// (at your option) any later version.
////
//// This program is distributed in the hope that it will be useful,
//// but WITHOUT ANY WARRANTY; without even the implied warranty of
//// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//// GNU Lesser General Public License for more details.
////
//// You should have received a copy of the GNU Lesser General Public License
//// along with this program.  If not, see http://www.gnu.org/licenses/.
////
//
//#ifndef DENSITYCOEFFICIENTS_H_
//#define DENSITYCOEFFICIENTS_H_
//
//#include <DensityMetrics.h>
//#include <inet/applications/udpapp/UDPBasicApp.h>
//#include <inet/mobility/contract/IMobility.h>
//
//using namespace inet;
//using namespace std;
//
//class DensityCoefficients : public UDPBasicApp {
//
//  protected:
//    enum Zone {
//      UNDETERMINED, SPARSE, DENSE
//    };
//    enum Events {
//      SEND_HELLO_MSG, SEND_CTRL_MSG, GET_DENSITY_METRICS, FWD_WILL_TO_CHANGE, UPDATE_WILL_TO_CHANGE, FWD_CHANGE_NOW_MSG
//    };
//    enum Timers {
//      HELLO, CTRL, DENSITY_METRICS
//    };
//    enum PacketType {
//      HELLO_PK, CTRL_PK, WILL_TO_CHANGE_PK, CHANGE_NOW
//    };
//
//    cMessage* helloEvent = new cMessage("helloEvent");
//    cMessage* ctrlEvent = new cMessage("ctrlEvent");
//    cMessage* densityEvent = new cMessage("densityEvent");
//    cMessage* willToChangeEv = new cMessage("willToChangeEv");
//    cMessage* changeNowEv = new cMessage("changeNowEv");
//
//    static simsignal_t clusteringCoef;
//    static simsignal_t closureCoef;
//    static simsignal_t positionAtX;
//    static simsignal_t positionAtY;
//    static simsignal_t runningProtocol;
//
//    int changeMsgId = 1;
//
//    double sentMsgDelay;
//
//    string nodeId;
//
//    DensityMetrics metrics;
//
//    IMobility* mobilityModel;
//
//    set<string> _1hopNeigs;
//    set<string> receivedMsgs;
//
//    map<string, set<string>> _2hopNeigs;
//
//    L3Address localAddress;
//    L3Address broadcastAddress;
//
//  protected:
//    virtual void sendPacket() override;
//    virtual void processStart() override;
//    virtual void handleMessageWhenUp(cMessage *msg) override;
//    virtual void processPacket(cPacket *msg) override;
//
//    void scheduleEvent(short kind, double delay, cMessage *selfMsgPtr);
//    cPacket* getHelloMsg();
//    cPacket* getCtrlMsg();
//    cPacket* getChangeMsg(const char* name, int density);
//    cPacket* getChangeNowMsg(const char* name, int algoID);
//    L3Address getSrcAddress(cPacket* msg) {
//      return check_and_cast<UDPDataIndication *>(msg->getControlInfo())->getSrcAddr();
//    }
//
//    bool selfEvent(cMessage* msg) {
//      return msg == helloEvent || msg == ctrlEvent || msg == densityEvent || msg == willToChangeEv || msg == changeNowEv;
//    }
//    void log(string msg) {
//      EV << "[" << nodeId << ", " << simTime() << "] - " << msg << endl;
//    }
//    void printNeighbors() {
//      set<string>::iterator i;
//      string info("One-hop neighbors: { ");
//      for (i = _1hopNeigs.begin(); i != _1hopNeigs.end(); ++i)
//        info += *i + ", ";
//      log(info + " }");
//
//      string temp;
//      log("Two-hop neighbors");
//      for (auto& j : _2hopNeigs) {
//        temp = "[" + j.first + "] - { ";
//        for (i = j.second.begin(); i != j.second.end(); ++i)
//          temp += *i + ", ";
//        log(temp + " }");
//      }
//    }
//
//  public:
//    DensityCoefficients() {
//    }
//    ~DensityCoefficients() {
//    }
//};
//
//#endif /* DENSITYCOEFFICIENTS_H_ */
