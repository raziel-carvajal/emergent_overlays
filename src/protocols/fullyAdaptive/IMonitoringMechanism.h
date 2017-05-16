#ifndef __INET_MONITORING_MECHANISM_H_
#define __INET_MONITORING_MECHANISM_H_

#include <memory>

#include <omnetpp.h>

#include "broadcasting/IBroadcastGateway.h"

namespace inet {

class IMonitoringMechanism: public cObject {
public:
  virtual int density_estimation() = 0;
  virtual double mobility_estimation() = 0;
  virtual bool handle_messages(cMessage* m) = 0;
  virtual void initialise(std::shared_ptr<IBroadcastGateway> gateway) = 0;
};

}

#endif
