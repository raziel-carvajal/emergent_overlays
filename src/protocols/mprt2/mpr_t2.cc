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

#include "inet/mobility/contract/IMobility.h"

#include <algorithm>
#include <cmath>
#include <vector>
#include <exception>
#include <stdexcept>

using namespace std;
using inet::broadcasting::Broadcast;

using inet::mpr_t2::MprBroadcast;
using inet::mpr_t2::MprHello;

namespace inet {

Register_Class(Mpr_t2);

void Mpr_t2::initialize(const std::string& node_name,
		const std::shared_ptr<IBroadcastGateway> gateway) {
	BroadcastProtocolAdapter::initialize(node_name, gateway);
	refresh_hops_message = gateway->register_new_control_message();
}

void Mpr_t2::on_saying_hello() {
//    std::cout << simTime().str() << " " + gateway->get_name() << " :: " << "Scheduling HelloMessage with type: " << refresh_hops_message << endl;
//	gateway->delayed_event(refresh_hops_message, "", get_random_delay());
	currentMpr = compute_mpr();
}

bool Mpr_t2::handle(const cMessage *msg) {
//    std::cout << simTime().str() << " HANDLE()" << endl;
	if (msg->getKind() == refresh_hops_message) {
//        std::cout << simTime().str() << " ERASE OLD HOPS" << endl;
//		erase_old_hops();
		return true;
	}
	return false;
}

void Mpr_t2::erase_old_hops() {
	for (auto it = hop1.begin(); it != hop1.end();) {
		//bool b = false;
		double elapsed = (simTime() - it->second.time).dbl();
		double threshold = 2
				* gateway->get_parameter<double>(protocol_name, "helloTime");
		if (elapsed > threshold) {
			it = hop1.erase(it);
			// cerr << getLogHeader() << " removing " << it->first << endl;
		} else
			++it;
	}
}

void Mpr_t2::process_hello(const broadcasting::Hello* msg) {
	string j = msg->getSender();
	if (j == myself) return;

	auto m = dynamic_cast<const MprHello*>(msg);
	if (!m) {
		cerr << myself << " : hello from " << j << ", ptr=" << m << ", raw_ptr="
				<< msg->getProtocolId() << endl;
		return;
	}

	hop1[j] = NodeNeighbor(simTime());
	hops_position[j] = Coord(m->getX(), m->getY());
	// std::cerr << "\t" << myself << " adding " << j << " as neighbor" << '\n';

	for (int i = 0; i < (int) m->getNeighborsArraySize(); i++) {
		string name(m->getNeighbors(i));
		if (myself == name)
			continue;

		hop1[j].hop1.insert(name);
		hops_position[name] = Coord(m->getXs(i), m->getYs(i));
		// std::cerr << "\t" << myself << " adding " << name << " as neighbor hop 1" << '\n';
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
	auto position = gateway->get_current_position();
	m->setX(position.x);
	m->setY(position.y);
	m->setSender(myself.c_str());
	return m;
}

MprBroadcast*
Mpr_t2::build_message_to_broadcast() {
	auto m = new MprBroadcast("payload");
	m->setInMprArraySize(currentMpr.size());
	int idx = 0;
	for (const auto& h : currentMpr) {
		m->setInMpr(idx++, strdup(h.c_str()));
	}
	return m;
}

void Mpr_t2::process_payload(const Broadcast* m) {
	string key = m->getId();
	gateway->emitBroadcastMsgReceived(key);
//    cout << simTime().str() << " " + gateway->get_name()
//            << " msg rcv from " << m->getSender() << endl;
	if (m->getSender() == myself) return;

	if (payloads.find(key) == payloads.end()) {
		payloads[key] = m->getPayload();
		auto mprBroadcast = dynamic_cast<const MprBroadcast*>(m);
		bool from_selector = (mprBroadcast == 0);
		if (mprBroadcast) {
			for (int i = 0;
					!from_selector && i < (int) mprBroadcast->getInMprArraySize(); i++) {
				string j = mprBroadcast->getInMpr(i);
				from_selector = (j == myself);
			}
		}
		if (gateway->amIborderNode() || from_selector) {
			if(gateway->amIborderNode())
				gateway->emitForwardTypeSignal(BroadcastingAppBase::ForwardType::BORDER);
			else
				gateway->emitForwardTypeSignal(BroadcastingAppBase::ForwardType::CDS_RELAY);
			gateway->broadcast(key, build_message_to_broadcast());
		}
	}
}

void Mpr_t2::time_to_broadcast_payload(void* user_data) {
	string key;
	if (!user_data)
		key = gateway->createUniqueBroadcastingSessionId();
	else
		key = string((char*) user_data);
	payloads[key] = key;
	gateway->emitForwardTypeSignal(BroadcastingAppBase::ForwardType::CDS_RELAY);
	gateway->broadcast(key, build_message_to_broadcast());
}

set<string> Mpr_t2::compute_mpr() {
	set<string> mpr;
	if (first_exec) {
		first_exec = false;
		latest = make_cpy(hop1);
	} else {
		bool changeOfNeigs = false;
		if (hop1.size() != 0) {
			if (latest.size() != hop1.size()) {
				changeOfNeigs = true;
			} else {
				for (const auto& p : hop1) {
					string key = p.first;
					if (latest.find(key) == latest.end()) {
						changeOfNeigs = true;
						break;
					}
				}

			}
		}
		if (changeOfNeigs) {
			latest.clear();
			latest = make_cpy(hop1);
		}
	}
	hops[0].clear();
	hops[1].clear();
	// first fill the array hops
	for (const auto& p : latest) {
		hops[0].insert(p.first);
	}
	for (const auto& p : latest) {
		string j = p.first;
		for (const auto& name : p.second.hop1) {
			if (name == myself)
				continue;
			bool no_neighbor = hops[0].find(name) == hops[0].end();
			if (no_neighbor) {
				hops[1].insert(name);
			}
		}
	}

	/* base case (rule 2 in the paper)  */
	for (const auto& z : hops[1]) {
		int count = 0;
		string unique = "";

		for (const auto& y : hops[0]) {
			if (is_a_covered_by_b(z, y)) {
				unique = y;
				count++;
			}
		}

		if (count == 1) {
			mpr.insert(unique);
		}

	}

	/* rule 3 from the paper */
	auto is_not_covered_by_mpr = [&] (string z) {
		bool r = any_of(mpr.begin(), mpr.end(), [&] (string h) {
					return is_a_covered_by_b(z, h);
				});
		return !r;
	};

	bool still_uncovered = any_of(hops[1].begin(), hops[1].end(),
			is_not_covered_by_mpr);

	int iterations = 0;

	int MAX_ITERATION = 1000; // FIXME: this is crap

	set<string> already_covered;
	for (const auto& z : hops[1]) {
		for (const auto& e : mpr) {
			if (is_a_covered_by_b(z, e)) {
				already_covered.insert(z);
			}
		}
	}

	while (still_uncovered && iterations < MAX_ITERATION) {
		//cerr << myself << ": building mpr, already with " << mpr.size() << " elements" << endl;
		string max_y = "";
		int max = -1;
		for (const auto& y : hops[0]) {
			if (mpr.find(y) == mpr.end()) {
				int c = 0;
				for (const auto& z : hops[1])
					if (already_covered.find(z) == already_covered.end()
							&& is_a_covered_by_b(z, y))
						c++;

				if (c > max) {
					max_y = y;
					max = c;
				}
			}
		}

		if (max_y != "") {
			mpr.insert(max_y);
			for (const auto& z : hops[1]) {
				for (const auto& e : mpr) {
					if (is_a_covered_by_b(z, e)) {
						already_covered.insert(z);
					}
				}
			}
		}

		still_uncovered = any_of(hops[1].begin(), hops[1].end(),
				is_not_covered_by_mpr);
		iterations++;
	}
	hop1.clear();
	hops_position.clear();
	return mpr;
}

} //namespace
