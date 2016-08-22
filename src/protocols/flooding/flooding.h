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


namespace inet {

class INET_API Flooding2 : public inet::BroadcastingAppBase
{

  private:

    /* payload of the message to broadcast */
    std::map< std::string, std::string >  payloads;

    virtual void on_payload_received(const broadcasting::Broadcast* m) override;
    virtual void time_to_broadcast_payload(void* user_data) override;

    void send_message(std::string& key);
    std::string getLogHeader();
};

} //namespace

#endif
