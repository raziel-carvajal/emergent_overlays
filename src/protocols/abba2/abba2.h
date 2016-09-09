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

class INET_API Abba2 : public inet::BroadcastingAppBase
{

  private:
    enum Quadrant {
        FIRST, SECOND, THIRD, FOURTH
    };
    /* payload of the message to broadcast */
    std::map< std::string, std::string >  payloads;
    /* indicates the set of nodes from whom I received this message */
    std::map< std::string, std::set< std::pair<double, double> > > received_from;

    double timeOut;
    std::map<std::string, std::string> ignoredMsgs;
    std::map<std::string, double> timeouts;
    std::map<std::string, cMessage*> delayMessages;
    std::map<std::string, std::vector<std::pair<double, double>> > firHalfPairs;
    std::map<std::string, std::vector<std::pair<double, double>> > secHalfPairs;
    cMessage* currentBrodcast;

    virtual void processStart() override;
    virtual void on_payload_received(const broadcasting::Broadcast* m) override;
    virtual void time_to_broadcast_payload(void* user_data) override;
    void send_message(std::string& key);

    int findQuadrant(Coord b);
    void updateAngleCovered(Coord b, std::string& key);
    bool inPair(double x, std::pair<double, double>& p);
    double getAngleCovered(std::vector<std::pair<double, double>>& items);
    double computeTimeout(double angle);
};

} //namespace

#endif
