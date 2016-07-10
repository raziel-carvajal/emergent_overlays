#ifndef __INET_DIST2MEAN_H_
#define __INET_DIST2MEAN_H_

#include <omnetpp.h>

#include <map>
#include <vector>
#include <string>
#include <queue>
#include <set>
#include <array>


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

	struct R {
	};

	int nr_hops_required = 2;

	array< set<string>, 5 > hops;
	array< bool, 5> hops_built;
	array< set<string>, 5 > hops_under_construction;

    int buildMprCounter;
    double builtMprTimeout;
    map<string, map<string, Neighbor>> twoHopNeighbors;

    /* payload of the message to broadcast */
    map< string, string >  payloads;

    /* indicates the set of nodes from whom I received this message */
    map< string, set< pair<double, double> > > received_from;

    virtual void on_payload_received(const broadcasting::Broadcast* m) override;
    virtual void time_to_broadcast_payload(void* user_data) override;

    void send_message(string& key);

    virtual bool on_network_message_received(cPacket* pkt) override;

    virtual void on_neighbors(const mpr_t2::Neighbors* m);
	virtual void on_request_neighbors(const mpr_t2::RequestNeighbors* m);

    template <typename T> bool processMessage2(cPacket* pkt, void (Mpr_t2::*action)(const T* msg));

	void request_hops(int h);


	/**
	 *
	 * This is the one one should call to get the hops in a level.
	 * For instance, using l = 0 will return the direct neighbors
	 * using l = 1 will return nodes you can reach using one of your neighbors 
	 * */
	set<string> get_hops_in_level(int l);

};

} //namespace

#endif
