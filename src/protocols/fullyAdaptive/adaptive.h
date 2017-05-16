#ifndef __INET_DIST2MEAN_H_
#define __INET_DIST2MEAN_H_

#include <omnetpp.h>

#include <map>
#include <vector>
#include <string>
#include <queue>
#include <set>

#include "inet/common/geometry/common/Coord.h"

#include "broadcasting/BroadcastingAppBase.h"
#include "broadcasting/BroadcastingAppBase_m.h"

#include "broadcasting/IBroadcastProtocol.h"
#include "IMonitoringMechanism.h"


namespace inet {

class INET_API FullyAdaptive : public inet::BroadcastingAppBase
{
  protected:
    virtual void processStart();
    virtual void handleMessageWhenUp(cMessage *msg) override;
  private:
    virtual inet::broadcasting::Hello* build_hello_message();
    virtual void on_payload_received(const broadcasting::Broadcast* m) override;
    virtual void on_hello_received(const broadcasting::Hello* msg);
    virtual void time_to_broadcast_payload(void* user_data) override;

    void change_current_protocol(const std::string& protocol);

    void adaptation();

  private:
    int DO_ADAPTATION;
    std::unique_ptr<IMonitoringMechanism> monitor;
    std::string current_protocol_name;
    std::map<std::string, std::unique_ptr<IBroadcastProtocol>> knownProtocols;
};

} //namespace

#endif
