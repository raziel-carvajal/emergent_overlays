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

#include "flooding.h"


#include "inet/networklayer/common/L3AddressResolver.h"
#include "inet/transportlayer/contract/udp/UDPControlInfo.h"
#include "inet/mobility/contract/IMobility.h"

#include <algorithm>
#include <cmath>
#include <vector>
#include <chrono>
#include <random>

using namespace std;
using inet::broadcasting::Broadcast;

namespace inet {

Define_Module(Flooding2);

void
Flooding2::on_payload_received(const Broadcast* m) {

    string key = string(m->getId());

    emitBroadcastMsgReceived(key);

    bool firstTime = !is_source && payloads[key].empty();

    if (firstTime) {
        payloads[key] = m->getPayload();
        delayed_broadcast(key, uniform(0.1, 0.5));
    }
}


void
Flooding2::send_message(string& key)
{
    Broadcast* m = new Broadcast("payload");
    m->setPayload(payloads[key].c_str());
    m->setId(key.c_str());
    m->setSender(myself.c_str());
    send_package(m);
    emitSent(key);
}


void
Flooding2::time_to_broadcast_payload(void* user_data)
{
    string key;
    if (is_source) {
        key = createUniqueBroadcastingSessionId();
        payloads[key] = " this is the payload, initially sent from " + myself;
        emitBroadcastMsgReceived(key);
    }
    else {
        char* s = (char*)user_data;
        key = string(s);
        delete s;
    }
    //cout << "Broadcasting in " << myself << " at " << simTime() << endl;
    send_message(key);
}



} //namespace
