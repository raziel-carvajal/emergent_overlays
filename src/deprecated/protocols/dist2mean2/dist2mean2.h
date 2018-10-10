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

#include "broadcasting/IBroadcastProtocol.h"
#include "broadcasting/BroadcastingAppBase_m.h"


namespace inet {

class INET_API Dist2Mean2 : public inet::BroadcastProtocolAdapter
{
  private:
    /* payload of the message to broadcast */
    std::map< std::string, std::string >  payloads;
    /* indicates the set of nodes from whom I received this message */
    std::map< std::string, std::set<std::string>> received_from;

    void process_payload(const broadcasting::Broadcast* m) override;
    void time_to_broadcast_payload(void* user_data) override;

    void send_message(const std::string& key, bool is_source);
};

} //namespace

#endif
