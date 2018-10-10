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
#include "broadcasting/IBroadcastProtocol.h"
#include "broadcasting/BroadcastingAppBase_m.h"

#include "mprtMsgs_m.h"

using namespace std;

namespace inet {

class INET_API Mpr_t2 : public inet::BroadcastProtocolAdapter
{
protected:

    struct NodeNeighbor {
      simtime_t time;
      set<string> hop1;
      NodeNeighbor(): NodeNeighbor(0) {}
      NodeNeighbor(simtime_t t) : time(t) {}
    };

private:

    int refresh_hops_message;

  	array< set<string>, 2 > hops;

    map<string, NodeNeighbor> hop1;

  	map< string, Coord > hops_position;

    /* payload of the message to broadcast */
    map< string, string >  payloads;

    map<string, NodeNeighbor> latest;

    bool first_exec = true;

    set<string> currentMpr;

    void initialize(const std::string& node_name, const std::shared_ptr<IBroadcastGateway> gateway) override;
    bool handle(const cMessage *msg) override;
    map<string, NodeNeighbor> make_cpy(map<string, NodeNeighbor> a){
    	map<string, NodeNeighbor> b;
    	for (const auto& i : a) {
    		NodeNeighbor n = NodeNeighbor();
    		string key(i.first);
    		if( (key != "") && (i.second.hop1.size() != 0) ){
					for(set<string>::iterator it = i.second.hop1.begin(); it != i.second.hop1.end(); ++it)
						n.hop1.insert(*it);
					b[i.first] = n;
    		}
    	}
    	return b;
    }

    inet::broadcasting::Hello* build_hello_message() override;
    void process_hello(const broadcasting::Hello* msg) override;
    void on_saying_hello() override;

    void process_payload(const broadcasting::Broadcast* m) override;
    void time_to_broadcast_payload(void* user_data) override;
    inet::mpr_t2::MprBroadcast* build_message_to_broadcast();

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
//  		cout << simTime().str() << " " + gateway->get_name()
//  										<< " getting positions"<< endl;

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
