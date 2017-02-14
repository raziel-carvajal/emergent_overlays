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

using inet::mpr_t2::MprBroadcast;
using inet::mpr_t2::MprHello;

namespace inet {

Define_Module(Mpr_t2);


enum ControlMessageTypes {
	WAKEUP_HOPS_REQUESTER = BroadcastingAppBase::ControlMessageTypes::Last + 1,
	DISPLAY_HOPS,
	REFRESH_HOPS
};


void
Mpr_t2::processStart()
{
	BroadcastingAppBase::processStart();
	string simT = ev.getConfig()->getConfigValue("sim-time-limit");
	// number of times that the information of two-hops neighbors will be exchanged
	// to compute the MPR set
	builtMprCounter = 3; //stoi(simT.substr(0, simT.size() - 1)) / par("builtMprTimeout").doubleValue();

	delayed_event(DISPLAY_HOPS, "", par("display_time_hops").doubleValue() + get_random_delay());

}


void
Mpr_t2::handleMessageWhenUp(cMessage *msg)
{
    if (msg->isSelfMessage()) {
        switch (msg->getKind()) {
					case SAY_HELLO:
						delayed_event(REFRESH_HOPS, "", get_random_delay());
						BroadcastingAppBase::handleMessageWhenUp(msg);
						break;
					case DISPLAY_HOPS:
						{
							if (builtMprCounter > 0) {
								  if (builtMprCounter > 0)
										delayed_event(DISPLAY_HOPS, "", par("builtMprTimeout").doubleValue() + 2);
							}
						}
						cancelAndDelete(msg);
						break;
					case REFRESH_HOPS:
						erase_old_hops();
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
			BroadcastingAppBase::on_network_message_received(pkt);
}


void
Mpr_t2::erase_old_hops()
{
	for( auto it = hop1.begin(); it != hop1.end(); ) {
		//bool b = false;
		double elapsed = (simTime() - it->second.time).dbl();
		double threshold = 2 * par("helloTime").doubleValue();
		if( elapsed > threshold )  {
			it = hop1.erase(it);
			// cerr << getLogHeader() << " removing " << it->first << endl;
		}
		else ++it;
	}
}


void
Mpr_t2::on_mpr_hello(const MprHello *m)
{
	string j = m->getSender();
	if (j == myself) return;
	//for being able to measure collisions
	neighbors[j] = Neighbor();
	/* first, it is obvious that the sender is a member of hops level 0 */
	hop1[j] = NodeNeighbor(simTime());

	hops_position[j] = Coord(m->getX(), m->getY());

	for (int i = 0 ; i < (int) m->getNeighborsArraySize() ; i++) {
		string name(m->getNeighbors(i));
		if (myself == name) continue;

		hop1[j].hop1.insert(name);
		hops_position[name] = Coord(m->getXs(i), m->getYs(i));
	}

}


inet::broadcasting::Hello*
Mpr_t2::build_hello_message() {
  auto m = new MprHello("MprHello");
	m->setNeighborsArraySize(hop1.size());
	m->setXsArraySize(hop1.size());
	m->setYsArraySize(hop1.size());
	int i = 0;
	for (const auto& p : hop1) {
		auto h = p.first;
		m->setNeighbors(i, h.c_str());
		m->setXs(i, hops_position[h].x);
		m->setYs(i, hops_position[h].y);
		i++;
	}
	return m;
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
	cout << getLogHeader() << "KEY_RECEPTION " << key << " FROM_PEER " << string(m->getSender()) << endl;
	emitBroadcastMsgReceived( key );

	if (payloads.find(key) == payloads.end()) {
		log_status_for_animation("MSG_RECEIVED");
		payloads[key] = m->getPayload();
		auto mprBroadcast = dynamic_cast<const MprBroadcast*>(m);
		bool from_selector = (mprBroadcast == 0);
		if (mprBroadcast) {
			for (int i = 0 ; !from_selector && i < (int) mprBroadcast->getInMprArraySize() ; i++) {
				string j = mprBroadcast->getInMpr(i);
				from_selector = (j == myself);
			}
		}

		if (from_selector || amIbridge) {
			broadcast(key, build_message_to_broadcast());
			log_status_for_animation("MSG_RECEIVED_SENT");
		}
	}
}


void
Mpr_t2::time_to_broadcast_payload(void* user_data)
{
   string key;
    if (!user_data) {
      key = createUniqueBroadcastingSessionId();
      emitBroadcastMsgReceived(key);
    }else {
      key = string( (char*)user_data );
    }
    payloads[key] = key;
    broadcast(key, build_message_to_broadcast());
}


set<string>
Mpr_t2::compute_mpr()
{
	set<string> mpr;
	hops[0].clear();
	hops[1].clear();
	// first fill the array hops
	for (const auto& p: hop1) {
		hops[0].insert(p.first);
	}
	for (const auto& p: hop1) {
		string j = p.first;
		for (const auto& name: p.second.hop1) {
			if (name == myself) continue;
			bool no_neighbor = hops[0].find(name) == hops[0].end();
			if (no_neighbor) {
				hops[1].insert(name);
			}
		}
	}

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

	return mpr;
}


} //namespace
