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

#ifndef IPROTOCOL_H_
#define IPROTOCOL_H_

#include <set>
#include <string>

class cMessage;
class InteroperableBroadcast;
class cPacket;

class IProtocol {
  public:
    virtual ~IProtocol() {}

    virtual void setController(InteroperableBroadcast* c) = 0;
    virtual void handleEvent(cMessage* msg) = 0;
    // each implementation have to store the type of forward nodes perform
    virtual void onBroadcastMsg(cPacket* pk, const char* pkName) = 0;
    virtual void addProtocolHeaders(cPacket* pk) = 0;
    virtual void updateProtocolHeaders(cPacket* pk) = 0;
    virtual void cancelSelfEvents() = 0;
    virtual void initialize() = 0;
    virtual void onControlMsg(cPacket* pk, const char* sender) = 0;

    virtual cPacket* createBroadcastMsg(const char* msgId) = 0;

    virtual int getFwdType() = 0;

    virtual bool amIoverlayRelay() = 0;
    virtual bool isProtocolEvent(cMessage* msg) = 0;

    virtual std::set<std::string> getNeighbors() = 0;
};

#endif /* IPROTOCOL_H_ */
