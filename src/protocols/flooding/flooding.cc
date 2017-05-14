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

using namespace std;
using inet::broadcasting::Broadcast;

namespace inet {

Register_Class(Flooding2);

void
Flooding2::process_payload(const Broadcast* m) {
    string key = string(m->getId());
    gateway->emitBroadcastMsgReceived(key);
    if (myself == m->getSender()) return;
    // cout << getLogHeader() + "KEY_RECEPTION " + key + " FROM_PEER " + string(m->getSender()) << endl;
    bool firstTime = payloads.find(key) == payloads.end();
    if (firstTime) {
        payloads[key] = key;
        gateway->broadcast(key, new broadcasting::Broadcast("payload"));
    }
}

void
Flooding2::time_to_broadcast_payload(void* user_data)
{
    string key;
    if (!user_data) {
        key = gateway->createUniqueBroadcastingSessionId();

		//to cope with mobility
        neighbors.empty();
    }else {
		key = string( (char*)user_data );
    }
    payloads[key] = key;
    gateway->broadcast(key, new broadcasting::Broadcast("payload"));
}

} //namespace
