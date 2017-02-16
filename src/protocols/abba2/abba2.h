#ifndef __INET_DIST2MEAN_H_
#define __INET_DIST2MEAN_H_

#include <omnetpp.h>

#include <map>
#include <vector>
#include <string>
#include <queue>
#include <set>


#include "inet/common/geometry/common/Coord.h"

#include "broadcasting/IBroadcastProtocol.h"
#include "broadcasting/BroadcastingAppBase_m.h"


namespace inet {

class INET_API Abba2 : public inet::BroadcastProtocolAdapter
{

  private:
    enum Quadrant {
        FIRST, SECOND, THIRD, FOURTH
    };
    double timeOut;
    std::set<std::string> ignoredMsgs;
    std::map<std::string, double> timeouts;
    std::map<std::string, cMessage*> delayMessages;
    std::map<std::string, std::vector<std::pair<double, double>> > firHalfPairs;
    std::map<std::string, std::vector<std::pair<double, double>> > secHalfPairs;
    cMessage* currentBrodcast;

    void initialize(const std::string& node_name, const std::shared_ptr<IBroadcastGateway> gateway) override;
    void process_payload(const broadcasting::Broadcast* m) override;
    void time_to_broadcast_payload(void* user_data) override;

    void send_message(std::string& key);

    int findQuadrant(Coord b);
    void updateAngleCovered(Coord b, std::string& key);
    bool inPair(double x, std::pair<double, double>& p);
    double getAngleCovered(std::vector<std::pair<double, double>>& items);
    double computeTimeout(double angle);
};

} //namespace

#endif
