#ifndef __INET_DIST2MEAN_H_
#define __INET_DIST2MEAN_H_

#include <omnetpp.h>

#include <map>
#include <vector>
#include <string>
#include <queue>
#include <set>
#include <memory>


#include "inet/common/geometry/common/Coord.h"

#include "broadcasting/BroadcastingAppBase.h"
#include "broadcasting/BroadcastingAppBase_m.h"

#include "broadcasting/IBroadcastProtocol.h"


namespace inet {

class INET_API Flooding2 : public BroadcastProtocolAdapter
{
  private:
    /* payload of the message to broadcast */
    std::map< std::string, std::string >  payloads;
    void process_payload(const broadcasting::Broadcast* m) override;
    void time_to_broadcast_payload(void* user_data) override;
};

} //namespace

#endif
