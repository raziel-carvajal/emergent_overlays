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

#include "cds2.h"
#include "cdsMsgs_m.h"


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

using inet::cds2::Neighbors;
using inet::cds2::RequestNeighbors;
using inet::cds2::MarkerChanged;

namespace inet {

Define_Module(CDS2);


enum ControlMessageTypes {
	REPLY_NEIGHBORS = 101,
	DELEGATE_REQUEST = 102,
	WAKEUP_HOPS_REQUESTER = 103,
	DISPLAY_HOPS = 104,
	NOTIFY_MPR = 105
};



void
CDS2::processStart()
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
CDS2::handleMessageWhenUp(cMessage *msg)
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
					m->setXsArraySize(count);	
					m->setYsArraySize(count);	
					int i = 0;
					for (int l = 0 ; l <= n ; l++) {
						for (auto& h : hops[l]) {
							m->setNeighbors(i, h.c_str());
							m->setHopLevels(i, l);
							m->setXs(i, hops_position[h].first);
							m->setYs(i, hops_position[h].second);
							i++;
						}
					}
					m->setMaxHopLevel(n);
					m->setX(position.x);
					m->setY(position.y);
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
					int n = nr_hops_required;
					cerr << myself << "(" << simTime() << ")" << endl;
					for (int l = 0 ; l <= n ; l++) {
						cerr << "\thops level " << l << ", found = " << hops_built[l] << endl;
						for (auto& h : hops[l])
							cerr << "\t\t" << h << "(" << hops_position[h].first << ", " << hops_position[h].second  << ")" << endl;
						cerr << endl;
					}
					delayed_event(NOTIFY_MPR, "", uniform(0.1, 0.3));
				}
				cancelAndDelete(msg);
				break;
			case NOTIFY_MPR:
				{
					cerr << myself << endl;
					for (auto& p: N) {
						auto u = p.first;
						cerr << "\tneighbor => " << u << endl;
						for (auto& v: p.second) {
							cerr << "\t\t" << v << endl;
						}

						cerr << endl;
					}

					initialize_marker();
				}
				cancelAndDelete(msg);
				break;
			case WAKEUP_HOPS_REQUESTER:
				{
					int n = nr_hops_required;
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
CDS2::on_network_message_received(cPacket* pkt){
    return BroadcastingAppBase::on_network_message_received(pkt) ||
            processMessage2<Neighbors>(pkt, &CDS2::on_neighbors) ||
			processMessage2<RequestNeighbors>(pkt, &CDS2::on_request_neighbors) ||
			processMessage2<MarkerChanged>(pkt, &CDS2::on_marker_changed);
			;
}



void
CDS2::on_marker_changed(const cds2::MarkerChanged* m)
{

	string u = m->getSender();
	markers[u] = m->getMarker();

}


void
CDS2::on_neighbors(const cds2::Neighbors* m)
{
	string j = m->getSender();
	if (j == myself) return;
	int nr_hops = m->getNeighborsArraySize();

	/* first, it is obvious that the sender is a member of hops level 0 */
	hops[0].insert(j);
	hops_position[j] = make_pair(m->getX(), m->getY());

	for (unsigned int l = 0 ; l < hops.size() ; l++) {
		for (int i = 0 ; i < nr_hops ; i++) {
			string name = m->getNeighbors(i);
			int h = m->getHopLevels(i) + 1;

			/* there is only one level */
			N[j].insert(name);

			if (myself != name && h == l) {

				bool b = all_of(hops.begin(), hops.end(), [&] (set<string> s) {
					return s.find(name) == s.end();
				});

				if (b) {
					hops[h].insert(name);
					hops_position[name] = make_pair(m->getXs(i), m->getYs(i));
				}

			}
		}
	}

	// Ok, clean the mess
	for (unsigned int l = 0 ; l < hops.size() - 1 ; l++ ) {
		for (auto& h : hops[l]) {
			for (unsigned int l2 = l + 1; l2 < hops.size() ; l2++) {
				auto it = hops[l2].find(h);
				if (it != hops[l2].end()) {
					hops[l2].erase(it);
				}
			}
		}
	}

	// decide if we are ready to reply
	int max_hop_level = m->getMaxHopLevel() + 1;
	hops_under_construction[max_hop_level].erase(j);

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
CDS2::get_hops_in_level(int l)
{
	if (l < 0 || l >= (int)hops.size()) throw invalid_argument("Level is out of range");
	return hops[l];
}


void
CDS2::on_request_neighbors(const cds2::RequestNeighbors* m)
{
	string j = m->getSender();
	if (j == myself) return;
	int max_hop_level = m->getMaxHopLevel();
	
	for (auto& n: neighbors) {
		string s = n.first;
		hops[0].insert(s);
		auto p = make_pair(n.second.pos.x, n.second.pos.y);
		hops_position[s] = p;
	}

	/* add also the one sending the message */
	hops[0].insert(string(m->getSender()));
	hops_position[string(m->getSender())] = make_pair(m->getX(), m->getY());

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
CDS2::request_hops(int h)
{
	
	RequestNeighbors* m = new RequestNeighbors("Requesting hops");
	m->setSender(myself.c_str());
	m->setMaxHopLevel(h);
	m->setX(position.x);
	m->setY(position.y);
	send_package(m);

}


void
CDS2::initialize_marker()
{
	/* setip initial markers */
	marker = any_of(hops[0].begin(), hops[0].end(), [&] (string v) {

		bool a = any_of(hops[0].begin(), hops[0].end(), [&](string u){
			return v != u && N[u].find(v) == N[u].end();
		});
		
		return a;		
	});

	cerr << myself << ": marker = " << marker << endl;

	if (marker) {

		/* apply rule 1 to reduce the number of nodes with markers */
		string v = myself;
		set<string> N_v (hops[0].begin(), hops[0].end());
		N_v.insert(v);

		marker = !any_of(hops[0].begin(), hops[0].end(), [&] (string u) { 

			set<string> N_u (N[u].begin(), N[u].end());
			N_u.insert(u);

			bool b = (v < u) && includes(N_u.begin(), N_u.end(), N_v.begin(), N_v.end());

			if (b) {
				cerr << "FOUNNNNNNNNND v = " << v << ", u = " << u << endl;
			}

			return b;
		});
	}
	
	cerr << myself << ": marker = " << marker << endl;
}


		
void
CDS2::on_payload_received(const Broadcast* m)
{
    // Store in a map a a broadcast session ID
    string key = m->getId();
    emitBroadcastMsgReceived( key );
	
	bool first = (!is_source && payloads.find(key) == payloads.end());

	if (first) {
		payloads[key] = m->getPayload();
		if (marker)
			delayed_broadcast(key, uniform(0.01, 0.2));
	}	
}


void
CDS2::send_message(string& key)
{
    if (is_source || marker) {

        Broadcast* m = new Broadcast("payload");
        m->setPayload(payloads[key].c_str());
        m->setId(key.c_str());
        m->setSender(myself.c_str());
		send_package(m);
        emitSent(key);
    }
}


void
CDS2::time_to_broadcast_payload(void* user_data)
{
    //BroadcastingAppBase::time_to_broadcast_payload(user_data);
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

template <typename T> bool
CDS2::processMessage2(cPacket* pkt, void (CDS2::*action)(const T* msg))
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
