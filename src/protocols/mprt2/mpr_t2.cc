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
	DISPLAY_HOPS
};


void
Mpr_t2::processStart()
{
	BroadcastingAppBase::processStart();
	string simT = ev.getConfig()->getConfigValue("sim-time-limit");
	// number of times that the information of two-hops neighbors will be exchanged
	// to compute the MPR set
	builtMprCounter = 3; //stoi(simT.substr(0, simT.size() - 1)) / par("builtMprTimeout").doubleValue();
	bool b = par("build_hops").boolValue();

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
							  if (builtMprCounter > 0)
									delayed_event(DISPLAY_HOPS, "", par("builtMprTimeout").doubleValue() + 2);
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
			BroadcastingAppBase::on_network_message_received(pkt);
}


void
Mpr_t2::on_mpr_hello(const MprHello *m) {
	string j = m->getSender();
	if (j == myself) return;

	/* first, it is obvious that the sender is a member of hops level 0 */
	hops[0].insert(j);
	hops_position[j] = make_pair(m->getX(), m->getY());

	for (int i = 0 ; i < m->getNeighborsArraySize() ; i++) {
		string name(m->getNeighbors(i));
		if (myself == name) continue;

		bool no_neighbor = hops[0].find(name) == hops[0].end();

		if (no_neighbor) {
			hops[1].insert(name);
			hops_position[name] = make_pair(m->getXs(i), m->getYs(i));
			// cerr << myself << "(" << simTime() << ")===== : Adding " << name << " to level " << h << endl;
		}
	}

	// Ok, clean the mess
	for (auto& h : hops[0]) {
		hops[1].erase(h);
	}
}



set<string>
Mpr_t2::get_hops_in_level(int l)
{
	if (l < 0 || l >= (int)hops.size())
		throw invalid_argument("Level is out of range");
	return hops[l];
}


inet::broadcasting::Hello*
Mpr_t2::build_hello_message() {
  auto m = new MprHello("MprHello");
	int count = hops[0].size();
	m->setNeighborsArraySize(count);
	m->setXsArraySize(count);
	m->setYsArraySize(count);
	int i = 0;
	for (const auto& h : hops[0]) {
		m->setNeighbors(i, h.c_str());
		m->setXs(i, hops_position[h].first);
		m->setYs(i, hops_position[h].second);
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
	emitBroadcastMsgReceived( key );

	bool first = (!is_source && payloads.find(key) == payloads.end());

	if (first) {
		log_status_for_animation("MSG_RECEIVED");
		payloads[key] = m->getPayload();
		auto mprBroadcast = dynamic_cast<const MprBroadcast*>(m);
		bool from_selector = false;
		for (int i = 0 ; !from_selector && i < mprBroadcast->getInMprArraySize() ; i++) {
			string j = mprBroadcast->getInMpr(i);
			from_selector = j == myself;
		}

		if (from_selector) {
			broadcast(key, build_message_to_broadcast());
			log_status_for_animation("MSG_RECEIVED_SENT");
		}
	}
}


void
Mpr_t2::time_to_broadcast_payload(void* user_data)
{
    if (is_source) {
        string key = createUniqueBroadcastingSessionId();
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

	return mpr;
}


} //namespace
