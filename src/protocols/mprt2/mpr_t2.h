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

#include "mprtMsgs_m.h"

using namespace std;

namespace inet {

class INET_API Mpr_t2 : public BroadcastingAppBase{
protected:
    enum mpr2cases{
        GET_2_HOPS_N
    };

	void handleMessageWhenUp(cMessage *msg);

    virtual void processStart() override;

private:



	int nr_hops_required = 2;
	int builtMprCounter;
	//long int builtMprCounter = ev.getConfig()-> getAsDouble("General", "sim-time-limit");

	array< set<string>, 5 > hops;
	array< bool, 5> hops_built;
	array< set<string>, 5 > hops_under_construction;

	map< string, pair<double, double> > hops_position;

	set<string> selectors;

	bool in_mpr = false;

    /* payload of the message to broadcast */
    map< string, string >  payloads;


    virtual void on_payload_received(const broadcasting::Broadcast* m) override;
    virtual void time_to_broadcast_payload(void* user_data) override;

    void send_message(string& key);

    virtual bool on_network_message_received(cPacket* pkt) override;

    virtual void on_neighbors(const mpr_t2::Neighbors* m);
	virtual void on_request_neighbors(const mpr_t2::RequestNeighbors* m);
	virtual void on_mpr_found(const mpr_t2::MprFound* m);

	void request_hops(int h);
	
	void notify_mpr();


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


	/** Compute MPR(x) */
	set<string> compute_mpr();

public:
  Mpr_t2();

};

} //namespace

#endif
