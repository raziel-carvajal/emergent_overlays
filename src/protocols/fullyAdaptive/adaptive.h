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

#include "AdaptationPolicies_m.h"

namespace inet {

class INET_API FullyAdaptive : public inet::BroadcastingAppBase
{
  protected:
    virtual void processStart() override;
    virtual void handleMessageWhenUp(cMessage *msg) override;
  private:
    virtual inet::broadcasting::Hello* build_hello_message() override;
    virtual void on_payload_received(const broadcasting::Broadcast* m) override;
    virtual void on_hello_received(const broadcasting::Hello* msg) override;
    virtual void time_to_broadcast_payload(void* user_data) override;

    void change_current_protocol(const std::string& protocol);

    void adaptation();

    enum AdaptationPolicy {
      LOCAL, SWSP, DENSITY_AREA
    };

  private:
//    int DO_ADAPTATION; // self-message ID
    AdaptationPolicy policy;

    bool willingToChange = false;
    std::string willingToChangeToProtocol;
    WillingToChange* packet_to_piggybag = nullptr;

    std::unique_ptr<IMonitoringMechanism> monitor;
    std::string current_protocol_name;
    std::map<std::string, std::unique_ptr<IBroadcastProtocol>> knownProtocols;
    int density_threshold_lower;
    int density_threshold_upper;
    double centerDensAx;
    double centerDensAy;
    double denseAreaWid;
    double adapTimer;

    // events and signals
    simsignal_t signal_protocol_change;
    //ground truth of density
    double deltaApprox;
};

} //namespace

#endif
