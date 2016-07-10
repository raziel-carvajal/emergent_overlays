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

#include "mpr_t2.h"
#include "mprtMsgs_m.h"


#include "inet/networklayer/common/L3AddressResolver.h"
#include "inet/transportlayer/contract/udp/UDPControlInfo.h"
#include "inet/mobility/contract/IMobility.h"

#include <algorithm>
#include <cmath>
#include <vector>
#include <exception>
#include <stdexcept>

using namespace std;
using inet::broadcasting::Broadcast;
using inet::BroadcastingAppBase;

using inet::mpr_t2::Neighbors;
using inet::mpr_t2::RequestNeighbors;

namespace inet {

Define_Module(Mpr_t2);


enum ControlMessageTypes {
	REPLY_NEIGHBORS = 101,
	DELEGATE_REQUEST = 102,
	WAKEUP_HOPS_REQUESTER = 103,
	DISPLAY_HOPS = 104
};



void
Mpr_t2::processStart()
{
	BroadcastingAppBase::processStart();

	bool b = par("build_hops").boolValue();

	if (b) {
		delayed_event(WAKEUP_HOPS_REQUESTER, 
						"", 
						par("wakeup_time_to_build_hops").doubleValue());


	}

	delayed_event(DISPLAY_HOPS, "", par("display_time_hops").doubleValue());
		
}


void
Mpr_t2::handleMessageWhenUp(cMessage *msg)
{

    if (msg->isSelfMessage()) {

        switch (msg->getKind()) {
            case REPLY_NEIGHBORS:
                {
					char* s = (char*)msg->getContextPointer();
					int n = stoi(string(s));
					int count = 0;
					for (int l = 0 ; l <= n ; l++) {
						count += hops[l].size();
					}
					Neighbors* m = new Neighbors("neighbors");
					m->setSender(myself.c_str());
					m->setNeighborsArraySize(count);
					m->setHopLevelsArraySize(count);	
					int i = 0;
					for (int l = 0 ; l <= n ; l++) {
						for (auto& h : hops[l]) {
							m->setNeighbors(i, h.c_str());
							m->setHopLevels(i, l);
							i++;
						}
					}
					m->setMaxHopLevel(n);
					send_package(m);
				}
				cancelAndDelete(msg);
				break;
			case DELEGATE_REQUEST:
				{
					char* s = (char*)msg->getContextPointer();
					int n = stoi(string(s));
					request_hops(n);
				}
				cancelAndDelete(msg);
				break;
			case DISPLAY_HOPS:
				{
					int n = par("hops_required");
					cerr << myself << "(" << simTime() << ")" << endl;
					for (int l = 0 ; l <= n ; l++) {
						cerr << "\thops level " << l << ", found = " << hops_built[l] << endl;
						for (auto& h : hops[l])
							cerr << "\t\t" << h << endl;
						cerr << endl;
					}
				}
				cancelAndDelete(msg);
				break;
			case WAKEUP_HOPS_REQUESTER:
				{
					int n = par("hops_required");
					cerr << myself << ": Wakeup to build hops " << endl;	
					request_hops(n-1);
				}
				cancelAndDelete(msg);
				break;
			default:
				BroadcastingAppBase::handleMessageWhenUp(msg);
				break;
		}
	}
	else BroadcastingAppBase::handleMessageWhenUp(msg);
}

bool
Mpr_t2::on_network_message_received(cPacket* pkt){
    return BroadcastingAppBase::on_network_message_received(pkt) ||
            processMessage2<mpr_t2::Neighbors>(pkt, &Mpr_t2::on_neighbors) ||
			processMessage2<mpr_t2::RequestNeighbors>(pkt, &Mpr_t2::on_request_neighbors)
			;
}

void
Mpr_t2::on_neighbors(const mpr_t2::Neighbors* m)
{

	int nr_hops = m->getNeighborsArraySize();

	/* first, it is obvious that the sender is a member of hops level 0 */
	if (myself != m->getSender()) {
		hops[0].insert(string(m->getSender()));
	}

	for (int l = 0 ; l < hops.size() ; l++) {
		for (int i = 0 ; i < nr_hops ; i++) {
			string name = m->getNeighbors(i);
			int h = m->getHopLevels(i) + 1;
			if (myself == name) continue;
			if (h != l) continue;

			bool b = all_of(hops.begin(), hops.end(), [&] (set<string> s) {
				return s.find(name) == s.end();
			});

			if (b) {
				hops[h].insert(name);
				//cerr << myself << "(" << simTime() << ")===== : Adding " << name << " to level " << h << endl;
			}
		}
	}

	// Ok, clean the mess
	for (int l = 0 ; l < hops.size() - 1 ; l++ ) {
		for (auto& h : hops[l]) {
			for (int l2 = l + 1; l2 < hops.size() ; l2++) {
				auto it = hops[l2].find(h);
				if (it != hops[l2].end()) {
					hops[l2].erase(it);
				}
			}
		}
	}

	// decide if we are ready to reply
	int max_hop_level = m->getMaxHopLevel() + 1;
	hops_under_construction[max_hop_level].erase(m->getSender());
	if (hops_under_construction[max_hop_level].empty()) {
		for (int l = 0 ; l <= max_hop_level ; l++) {
			hops_built[l] = true;
		}
		if (max_hop_level < nr_hops_required) {
			// reply back, but only to the maximum level
			delayed_event(REPLY_NEIGHBORS, to_string(max_hop_level), uniform(0.1, 0.3));
		}
	}
}



set<string>
Mpr_t2::get_hops_in_level(int l)
{
	if (l < 0 || l >= hops.size()) throw invalid_argument("Level is out of range");
	return hops[l];
}


void
Mpr_t2::on_request_neighbors(const mpr_t2::RequestNeighbors* m)
{
	string j = m->getSender();
	int max_hop_level = m->getMaxHopLevel();
	
	for (auto& n: neighbors) {
		string s = n.first;
		hops[0].insert(s);
	}

	hops_built[0] = true;

	if (max_hop_level == 0) {
		// just reply back my neighbors
		delayed_event(REPLY_NEIGHBORS, "0", uniform(0.1, 0.3));
	}
	else {
		if (hops_built[max_hop_level]) {
			/* I already got the information. I will just send it back */
			delayed_event(REPLY_NEIGHBORS, to_string(max_hop_level), uniform(0.1, 0.3));
		}
		else {
			int l = max_hop_level - 1;
			// request max_hop_level - 1 to my neighbors
			delayed_event(DELEGATE_REQUEST, to_string(l), uniform(0.1, 0.3));

			for (auto& n : neighbors) {
				if (n.first != myself) {
					hops_under_construction[l].insert(n.first);
				}
			}
		}

		// record the fact that someone is requesting
	}
}


void
Mpr_t2::request_hops(int h)
{
	/*
	if (h < 1) {
		cerr << "Error: You already got hops level 0. They are located in 'neighbors'." << endl;
		throw runtime_error("The nr of requested hops must be 1 or more");
	}
	*/


	RequestNeighbors* m = new RequestNeighbors("Requesting hops");
	m->setSender(myself.c_str());
	m->setMaxHopLevel(h);
	send_package(m);

}

		
void
Mpr_t2::on_payload_received(const Broadcast* m)
{
    // Store in a map a a broadcast session ID
    // string key = string(m->getId())
    emitBroadcastMsgReceived( string(m->getId()) );

}


void
Mpr_t2::send_message(string& key)
{
    if (is_source || received_from[key].size() > 0) {

        Broadcast* m = new Broadcast("payload");
        m->setPayload(payloads[key].c_str());
        m->setId(key.c_str());
        m->setSender(myself.c_str());
        emitSent(key);
    }
}


void
Mpr_t2::time_to_broadcast_payload(void* user_data)
{
//    BroadcastingAppBase::time_to_broadcast_payload(user_data);
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
    // send_message(key);
}

template <typename T> bool
Mpr_t2::processMessage2(cPacket* pkt, void (Mpr_t2::*action)(const T* msg))
{
    T* t = check_and_cast_nullable<T*>(dynamic_cast<T*>(pkt));
    if (t != nullptr) {
        (this->*action)(t);
        return true;
    }
    else {
        return false;
    }
}

} //namespace
