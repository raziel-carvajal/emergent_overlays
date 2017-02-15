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

#include "inet/common/geometry/common/Coord.h"

#include "broadcasting/BroadcastingAppBase.h"
#include "broadcasting/BroadcastingAppBase_m.h"

#include "mprtMsgs_m.h"

using namespace std;

namespace inet {

class INET_API Mpr_t2 : public BroadcastingAppBase{
protected:

    struct NodeNeighbor {
      simtime_t time;
      set<string> hop1;
      NodeNeighbor(): NodeNeighbor(0) {}
      NodeNeighbor(simtime_t t) : time(t) {}
    };

	  void handleMessageWhenUp(cMessage *msg);

private:

  	int nr_hops_required = 2;
  	int builtMprCounter;
  	//long int builtMprCounter = ev.getConfig()-> getAsDouble("General", "sim-time-limit");

  	array< set<string>, 2 > hops;

    map<string, NodeNeighbor> hop1;

  	map< string, Coord > hops_position;

    /* payload of the message to broadcast */
    map< string, string >  payloads;

    virtual inet::broadcasting::Hello* build_hello_message() override;

    virtual void on_payload_received(const broadcasting::Broadcast* m) override;
    virtual void time_to_broadcast_payload(void* user_data) override;

    virtual bool on_network_message_received(cPacket* pkt) override;

    void on_mpr_hello(const mpr_t2::MprHello* m);

    inet::mpr_t2::MprBroadcast* build_message_to_broadcast();

  	/**
  	 * This one is also useful. You can call it to get the position of a host
  	 */
  	Coord get_hop_position(string n) {
  		if (hops_position.find(n) == hops_position.end()) {
  			throw new invalid_argument("unknown hop: " + n);
  		}
  		return hops_position[n];
  	}

  	bool is_a_covered_by_b(string a, string b) {

      double b_radius = gateway->get_transmission_radius();

  		auto pA = get_hop_position(a);
  		auto pB = get_hop_position(b);

  		return (
  				b_radius * b_radius >
  					(pA.x - pB.x)*(pA.x - pB.x)+
  					(pA.y - pB.y)*(pA.y - pB.y)
  			   );
	  }


  	/** Compute MPR(x) */
  	set<string> compute_mpr();
    void erase_old_hops();


};

} //namespace

#endif
