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
using inet::mpr_t2::MprFound;

namespace inet {

Define_Module(Mpr_t2);


enum ControlMessageTypes {
	REPLY_NEIGHBORS = 101,
	DELEGATE_REQUEST = 102,
	WAKEUP_HOPS_REQUESTER = 103,
	DISPLAY_HOPS = 104,
	NOTIFY_MPR = 105
};


Mpr_t2::Mpr_t2():BroadcastingAppBase()
{
	hops_built.fill(false);
}


void
Mpr_t2::processStart()
{
	BroadcastingAppBase::processStart();
	string simT = ev.getConfig()->getConfigValue("sim-time-limit");
	// number of times that the information of two-hops neighbors will be exchanged
	// to compute the MPR set
	builtMprCounter = 1; // stoi(simT.substr(0, simT.size() - 1)) / par("builtMprTimeout").doubleValue();
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
								if (builtMprCounter > 0) {
										builtMprCounter--;
			              int n = par("hops_required");
			              // cerr << myself << "(" << simTime() << ")" << endl;
			              // for (int l = 0 ; l <= n ; l++) {
			              //     cerr << "\thops level " << l << ", found = " << hops_built[l] << endl;
			              //     for (auto& h : hops[l])
			              //         cerr << "\t\t" << h << "(" << hops_position[h].first << ", " << hops_position[h].second  << ")" << endl;
			              //     cerr << endl;
			              // }
			              delayed_event(NOTIFY_MPR, "", uniform(0.1, 0.2));
			              // Doing this loop little bit later that the information about
			              // two-hops neighbors have been exchanged
										if (builtMprCounter > 0) delayed_event(DISPLAY_HOPS, "", par("builtMprTimeout").doubleValue() + 2);
								}
							}
							cancelAndDelete(msg);
							break;
						case NOTIFY_MPR:
							{
								auto mpr = compute_mpr();
								MprFound* m = new MprFound("mpr found");
								m->setSender(myself.c_str());
								m->setInMprArraySize(mpr.size());
								int idx = 0;
								for (auto& h: mpr) {
									//cerr << h << " ======== is in mpr" << endl << endl;
									m->setInMpr(idx++, strdup(h.c_str()));
								}
								send_package(m);
							}
							cancelAndDelete(msg);
							break;
						case WAKEUP_HOPS_REQUESTER:
							{
									int n = par("hops_required");
							    // cerr << myself << ": BuiltMprCounter :: " << builtMprCounter << ", hops_required :: " << n << endl;
							    if(builtMprCounter > 0){

							        // cerr << myself << ": Wakeup to build hops, number of builds left: " << builtMprCounter << endl;
							        request_hops(n-1);

							        if (builtMprCounter > 0)  delayed_event(WAKEUP_HOPS_REQUESTER, "", par("builtMprTimeout").doubleValue());
							    }
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
            processMessage<Neighbors>(pkt, [&](const Neighbors*m) { this->on_neighbors(m); }) ||
			processMessage<RequestNeighbors>(pkt, [&](const RequestNeighbors*m) { this->on_request_neighbors(m); }) ||
			processMessage<MprFound>(pkt, [&](const MprFound*m) { this->on_mpr_found(m); });
			;
}



void
Mpr_t2::on_mpr_found(const mpr_t2::MprFound* m)
{
	int n = m->getInMprArraySize();
	for (int i = 0 ; i < n ; i++) {
		string j = m->getInMpr(i);
		if (j == myself) {

			selectors.insert(m->getSender());
			// cerr << myself << "(" << simTime() << ")" << ": YESSSSSS, " << m->getSender() << " selected me" << endl;
			in_mpr = true;
			return;
		}
	}
	// couldn't find my self, so This guy is not my selector
	selectors.erase(string(m->getSender()));
}


void
Mpr_t2::on_neighbors(const mpr_t2::Neighbors* m)
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
			if (myself == name) continue;
			if (h != l) continue;

			bool b = all_of(hops.begin(), hops.end(), [&] (set<string> s) {
				return s.find(name) == s.end();
			});

			if (b) {
				hops[h].insert(name);
				hops_position[name] = make_pair(m->getXs(i), m->getYs(i));
				// cerr << myself << "(" << simTime() << ")===== : Adding " << name << " to level " << h << endl;
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
			delayed_event(REPLY_NEIGHBORS, to_string(max_hop_level), uniform(0.1, 0.2));
		}
	}
}



set<string>
Mpr_t2::get_hops_in_level(int l)
{
	if (l < 0 || l >= (int)hops.size()) throw invalid_argument("Level is out of range");
	return hops[l];
}


void
Mpr_t2::on_request_neighbors(const mpr_t2::RequestNeighbors* m)
{
	// cerr << myself << ": Someone is requesting " << m->getMaxHopLevel()  << ", and I know " << neighbors.size() <<  endl;
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
		delayed_event(REPLY_NEIGHBORS, "0", uniform(0.1, 0.2));
	}
	else {
		if (hops_built[max_hop_level]) {
			/* I already got the information. I will just send it back */
			delayed_event(REPLY_NEIGHBORS, to_string(max_hop_level), uniform(0.1, 0.2));
		}
		else {
			int l = max_hop_level - 1;
			// request max_hop_level - 1 to my neighbors
			delayed_event(DELEGATE_REQUEST, to_string(l), uniform(0.1, 0.2));

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

	RequestNeighbors* m = new RequestNeighbors("Requesting hops");
	m->setSender(myself.c_str());
	m->setMaxHopLevel(h);
	m->setX(position.x);
	m->setY(position.y);
	send_package(m);

}


void
Mpr_t2::on_payload_received(const Broadcast* m)
{
  // Store in a map a a broadcast session ID
  string key = m->getId();
  emitBroadcastMsgReceived( key );

	bool first = (!is_source && payloads.find(key) == payloads.end());

	if (first) {
		// cerr << myself << "(" << simTime() << ")" << ": receiving message with key = " << key << endl;
		payloads[key] = m->getPayload();
		bool from_selector = selectors.find(m->getSender()) != selectors.end();
		if (in_mpr && from_selector)
			delayed_broadcast(key, uniform(0.01, 0.2));
	}
}


void
Mpr_t2::send_message(string& key)
{
    if (is_source || in_mpr) {

        Broadcast* m = new Broadcast("payload");
        m->setPayload(payloads[key].c_str());
        m->setId(key.c_str());
        m->setSender(myself.c_str());
				send_package(m);
        emitSent(key);
    }
}


void
Mpr_t2::time_to_broadcast_payload(void* user_data)
{
    BroadcastingAppBase::time_to_broadcast_payload(user_data);
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


set<string>
Mpr_t2::compute_mpr()
{
	set<string> mpr;

	/* base case (or case 1 in Raziel's presentation)  */
	for (auto& z: hops[1]){
		set<string> s;

		for (auto& y: hops[0]) {
			if (is_a_covered_by_b(z, y, radious) ) {
				s.insert(y);
			}
		}

		if (s.size() == 1) {
			mpr.insert(s.begin(), s.end());
		}

	}

	auto checking_coverage = [&] (string z) {

		bool r = any_of(mpr.begin(), mpr.end(), [&] (string h) {
			return is_a_covered_by_b(z, h, radious);
		});

		//if (!r) {
		// cerr << "Apparently " << z << " not covered in " << myself << endl;
		//}

		return !r;
	};

	bool b = any_of(hops[1].begin(), hops[1].end(), checking_coverage);

	while (b) {
		//cerr << myself << ": building mpr, already with " << mpr.size() << " elements" << endl;
		string max_y = "";
		int max = -1;
		for (auto& y: hops[0]) {
			if (mpr.find(y) != mpr.end()) continue;
			int c = 0;
			for (auto& z: hops[1])
				if (is_a_covered_by_b(z, y, radious))
					c++;

			if (c > max) {
				max_y = y;
				max = c;
			}
		}

		if (max_y != "") {
				mpr.insert(max_y);
			//	cerr << "\nadding " << max_y << endl;
		}

		b = any_of(hops[1].begin(), hops[1].end(), checking_coverage);
	}





	return mpr;
}


} //namespace
