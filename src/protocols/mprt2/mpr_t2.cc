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
using inet::mpr_t2::MprBroadcast;
using inet::mpr_t2::MprHello;

namespace inet {

Define_Module(Mpr_t2);


enum ControlMessageTypes {
	WAKEUP_HOPS_REQUESTER = BroadcastingAppBase::ControlMessageTypes::Last + 1,
	DISPLAY_HOPS
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
	builtMprCounter = 3; //stoi(simT.substr(0, simT.size() - 1)) / par("builtMprTimeout").doubleValue();
	bool b = par("build_hops").boolValue();

	if (b) {
		delayed_event(WAKEUP_HOPS_REQUESTER,
						"",
						par("wakeup_time_to_build_hops").doubleValue() + get_random_delay());


	}

	delayed_event(DISPLAY_HOPS, "", par("display_time_hops").doubleValue() + get_random_delay());

}


void
Mpr_t2::handleMessageWhenUp(cMessage *msg)
{

    if (msg->isSelfMessage()) {

        switch (msg->getKind()) {
				case DISPLAY_HOPS:
					{
						if (builtMprCounter > 0) {

							  //int n = par("hops_required");
							  //cerr << myself << "(" << simTime() << ")" << endl;
							  //for (int l = 0 ; l <= n ; l++) {
							  //	cerr << "\thops level " << l << ", found = " << hops_built[l] << endl;
							  //	for (auto& h : hops[l])
							  //        cerr << "\t\t" << h << "(" << hops_position[h].first << ", " << hops_position[h].second  << ")" << endl;
							  //     cerr << endl;
							  //}

							  if (builtMprCounter > 0) delayed_event(DISPLAY_HOPS, "", par("builtMprTimeout").doubleValue() + 2);
						}
					}
					cancelAndDelete(msg);
					break;
				case WAKEUP_HOPS_REQUESTER:
					{
						int n = par("hops_required");
				    // cerr << myself << ": BuiltMprCounter :: " << builtMprCounter << ", hops_required :: " << n << endl;
				    if(builtMprCounter > 0){
							builtMprCounter--;
			        // cerr << myself << ": Wakeup to build hops, number of builds left: " << builtMprCounter << endl;
			        request_hops(n-1);
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
    return
			processMessage<MprHello>(pkt, [&](const MprHello *m) { this->on_mpr_hello(m); }) ||
      processMessage<Neighbors>(pkt, [&](const Neighbors *m) { this->on_neighbors(m); }) ||
			processMessage<RequestNeighbors>(pkt, [&](const RequestNeighbors *m) { this->on_request_neighbors(m); }) ||
			BroadcastingAppBase::on_network_message_received(pkt);
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
}


void
Mpr_t2::on_mpr_hello(const MprHello *m) {
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
			if (myself == name || h != l) continue;

			bool b = all_of(hops.begin(), hops.end(), [&] (const set<string>& s) {
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
}



set<string>
Mpr_t2::get_hops_in_level(int l)
{
	if (l < 0 || l >= (int)hops.size()) throw invalid_argument("Level is out of range");
	return hops[l];
}


void
Mpr_t2::reply_hops(int n)
{
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


void
Mpr_t2::on_request_neighbors(const mpr_t2::RequestNeighbors* m)
{
	// cerr << myself << ": Someone is requesting " << m->getMaxHopLevel()  << ", and I know " << neighbors.size() <<  endl;
	string j = m->getSender();
	if (j == myself) return;
	int max_hop_level = m->getMaxHopLevel();

	for (auto& n: neighbors) {
		string name = n.first;
		hops[0].insert(name);
		hops_position[name] = make_pair(n.second.pos.x, n.second.pos.y);
	}

	/* add also the one sending the message */
	hops[0].insert(string(m->getSender()));
	hops_position[string(m->getSender())] = make_pair(m->getX(), m->getY());

	hops_built[0] = true;

	if (max_hop_level == 0) {
		reply_hops(0); // just reply back my neighbors
	}
	else {
		throw std::runtime_error("why on earth do you need more than 1 hop humps?");
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



MprBroadcast*
Mpr_t2::build_message_to_broadcast()
{
	auto mpr = compute_mpr();
	auto m = new MprBroadcast("payload");
	m->setInMprArraySize(mpr.size());
	int idx = 0;
	for (const auto& h: mpr) {
		m->setInMpr(idx++, strdup(h.c_str()));
	}
	return m;
}


void
Mpr_t2::on_payload_received(const Broadcast* m)
{
	// Store in a map a a broadcast session ID
	if (m->getSender() == myself) return;
	string key = m->getId();
	emitBroadcastMsgReceived( key );

	bool first = (!is_source && payloads.find(key) == payloads.end());

	if (first) {
		log_status_for_animation("MSG_RECEIVED");
		payloads[key] = m->getPayload();
		auto mprBroadcast = dynamic_cast<const MprBroadcast*>(m);
		bool from_selector = false;

		int n = mprBroadcast->getInMprArraySize();
		for (int i = 0 ; i < n ; i++) {
			string j = mprBroadcast->getInMpr(i);
			if (j == myself) {
				in_mpr = true;
				from_selector = true;
				break;
			}
		}

		if (in_mpr && from_selector) {
			broadcast(key, build_message_to_broadcast());
			log_status_for_animation("MSG_RECEIVED_SENT");
		}
	}
}


void
Mpr_t2::time_to_broadcast_payload(void* user_data)
{
    //BroadcastingAppBase::time_to_broadcast_payload(user_data);
    string key;
    if (is_source) {
        key = createUniqueBroadcastingSessionId();
				payloads[key] = key;
        emitBroadcastMsgReceived(key);
				broadcast(key, build_message_to_broadcast());
    }
}


set<string>
Mpr_t2::compute_mpr()
{
	set<string> mpr;

	/* base case (rule 2 in the paper)  */
	for (const auto& z: hops[1]){
		int count = 0;
		string unique = "";

		for (const auto& y: hops[0]) {
			if (is_a_covered_by_b(z, y, radious) ) {
				unique = y;
				count ++;
			}
		}

		if (count == 1) {
			mpr.insert(unique);
		}

	}


	/* rule 3 from the paper */
	auto is_not_covered_by_mpr = [&] (string z) {
		bool r = any_of(mpr.begin(), mpr.end(), [&] (string h) {
			return is_a_covered_by_b(z, h, radious);
		});
		return !r;
	};

	bool still_uncovered = any_of(hops[1].begin(), hops[1].end(), is_not_covered_by_mpr);

	int iterations = 0;

	int MAX_ITERATION = 1000; // FIXME: this is crap

	set<string> already_covered;
	for (const auto& z: hops[1]){
		for (const auto& e: mpr) {
			if (is_a_covered_by_b(z, e, radious)) {
				already_covered.insert(z);
			}
		}
	}

	while (still_uncovered && iterations < MAX_ITERATION) {
		//cerr << myself << ": building mpr, already with " << mpr.size() << " elements" << endl;
		string max_y = "";
		int max = -1;
		for (const auto& y: hops[0]) {
			if (mpr.find(y) == mpr.end()) {
				int c = 0;
				for (const auto& z: hops[1])
					if (already_covered.find(z) == already_covered.end() && is_a_covered_by_b(z, y, radious))
						c++;

				if (c > max) {
					max_y = y;
					max = c;
				}
			}
		}

		if (max_y != "") {
				mpr.insert(max_y);
				for (const auto& z: hops[1]){
					for (const auto& e: mpr) {
						if (is_a_covered_by_b(z, e, radious)) {
							already_covered.insert(z);
						}
					}
				}
		}

		still_uncovered = any_of(hops[1].begin(), hops[1].end(), is_not_covered_by_mpr);
		iterations ++;
	}

	// if (myself == "hostR187") {
	// 	cout << getLogHeader() << endl;
	// 	for (auto e: mpr) {
	// 		cout << "\t\t\tcrazy " << e << endl;
	// 	}
	// }

	return mpr;
}


} //namespace
