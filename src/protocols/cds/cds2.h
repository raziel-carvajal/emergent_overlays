#ifndef __INET_DIST2MEAN_H_
#define __INET_DIST2MEAN_H_

#include <omnetpp.h>

#include <map>
#include <vector>
#include <string>
#include <queue>
#include <set>
#include <array>
#include <stdexcept>

#include "inet/common/INETDefs.h"
#include "inet/common/ModuleAccess.h"
#include "inet/common/geometry/common/Coord.h"

#include "inet/applications/base/ApplicationBase.h"
#include "inet/transportlayer/contract/udp/UDPSocket.h"

#include "broadcasting/BroadcastingAppBase.h"
#include "broadcasting/BroadcastingAppBase_m.h"

#include "cdsMsgs_m.h"

using namespace std;

namespace inet {

class INET_API CDS2 : public BroadcastingAppBase{
protected:

	void handleMessageWhenUp(cMessage *msg);

    virtual void processStart() override;

private:


	int nr_hops_required = 1;

	array< set<string>, 3 > hops;
	array< bool, 3> hops_built;
	array< set<string>, 3 > hops_under_construction;

	map< string, pair<double, double> > hops_position;

	bool marker = false;

	/* N(v) is the set of neighbors of node v */
	map<string, set<string> > N;

	/* e(v) is the energy level of node v  */
	map<string, double> e;

	/* marker[v] indicates if v is marked as gateway or not */
	map<string, bool> markers;

	set<string> N_close(string v) {
		set<string> r(N[v].begin(), N[v].end());
		r.insert(v);
		return (r);
	}

	/* payload of the message to broadcast */
	map< string, string >  payloads;

	virtual void on_payload_received(const broadcasting::Broadcast* m) override;
	virtual void time_to_broadcast_payload(void* user_data) override;

	void send_message(string& key);

	virtual bool on_network_message_received(cPacket* pkt) override;

	virtual void on_neighbors(const cds2::Neighbors* m);
	virtual void on_request_neighbors(const cds2::RequestNeighbors* m);
	virtual void on_marker_changed(const cds2::MarkerChanged* m);


	template <typename T> bool processMessage2(cPacket* pkt, void (CDS2::*action)(const T* msg));

	void request_hops(int h);


	/**
	 *
	 * This is the one one should call to get the hops in a level.
	 * For instance, using l = 0 will return the direct neighbors
	 * using l = 1 will return nodes you can reach using one of your neighbors 
	 * */
	set<string> get_hops_in_level(int l);

	/**
	 * This one is also useful. You can call it to get the position of a host
	 */

	pair<double, double> get_hop_position(string n) {
		if (hops_position.find(n) == hops_position.end()) {
			throw new invalid_argument("unknown hop: " + n);
		}
		return hops_position[n];
	}

	bool is_a_covered_by_b(string a, string b, double b_radius) {
	
		auto pA = get_hop_position(a);
		auto pB = get_hop_position(b);

		return ( 
				b_radius * b_radius > 
					(pA.first - pB.first)*(pA.first - pB.first)+
					(pA.second - pB.second)*(pA.second - pB.second)
			   );

	
	}

	void initialize_marker();
	
};

} //namespace

#endif
