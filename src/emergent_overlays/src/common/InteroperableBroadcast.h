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

using namespace inet;
using namespace std;

class InteroperableBroadcast : public UDPBasicApp {

	protected:
		// define a new implementation for these methods of class INET::UDPBasicApp
		virtual void initialize(int stage) override;
		virtual void processStart() override;
		virtual void sendPacket() override;
		virtual void handleMessageWhenUp(cMessage *msg) override;
		virtual void processPacket(cPacket *msg) override;

		string nodeId;
		set<string> receivedMsg;

//		const char *packetName = UDPBasicApp::packetName;

		// methods that sub-classes may override
		virtual void onBroadcastMsg(cPacket* pk);
		virtual void onControlMsg(cPacket* pk);

		void fwdBroadcastMsg(cPacket* pk);

		cPacket* getCtrlMsg();
		//
		int getMsgId(const char* msgHeader);

		// signals for this class
		static simsignal_t rcvdBroadcastMsg;
		static simsignal_t sentBroadcastMsg;
		static simsignal_t positionAtX;
		static simsignal_t positionAtY;

	private:

		enum Timer {
			HALT_APP = 1, SEND_CTRL_MSG, BROADCAST_SESSION, MONITOR
		};
		enum UdpPacket {
			BROADCAST = 1, CTRL, BORDER
		};

		cMessage* ctrlMsgTimer = nullptr;
		cMessage* haltSimTimer = nullptr;
		cMessage* broaMsgTimer = nullptr;
		cMessage* monitorTimer = nullptr;

		L3Address localAddress;
		L3Address broadcastAddress;

		IMobility* mobilityModel;

		L3Address getSrcAddress(cPacket *msg);
		void scheduleEvent(short kind, double delay, cMessage *selfMsgPtr);
		void addPacketType(cPacket* msg, long t);
		void addSender(cPacket* pk);

		bool isSelfTimer(cMessage *msg);

	public:
		InteroperableBroadcast() {
		}
		~InteroperableBroadcast() {
		}
};

#endif /* INTEROPERABLEBROADCAST_H_ */
