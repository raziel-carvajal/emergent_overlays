#ifndef __INET_DIST2MEAN_H_
#define __INET_DIST2MEAN_H_

#include <omnetpp.h>

#include <map>
#include <vector>
#include <string>
#include <queue>
#include <set>


#include "inet/common/INETDefs.h"
#include "inet/common/ModuleAccess.h"
#include "inet/common/geometry/common/Coord.h"

#include "inet/applications/base/ApplicationBase.h"
#include "inet/transportlayer/contract/udp/UDPSocket.h"

#include "broadcasting/BroadcastingAppBase.h"
#include "broadcasting/BroadcastingAppBase_m.h"

#include "mprMsgs_m.h"

using namespace std;

namespace inet {

class INET_API Mpr2 : public BroadcastingAppBase{
protected:
    enum mpr2cases{
        GET_2_HOPS_N
    };

  private:
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

    virtual bool on_network_message_received(cPacket* pkt);

    virtual void handleMessageWhenUp(cMessage *msg);

    virtual void onNeigh(const mpr2::Neighbours* m);

    virtual map<string, string> splitString(string str, string delimiter);

    virtual map<string, Neighbor> get2HopNe(string str);

    template <typename T> bool processMessage(cPacket* pkt, void (Mpr2::*action)(const T* msg));
};

} //namespace

#endif
