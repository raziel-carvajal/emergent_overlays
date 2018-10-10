#ifndef __INET_MONITORING_MECHANISM_H_
#define __INET_MONITORING_MECHANISM_H_

#include <memory>
#include <omnetpp.h>
#include <math.h>
#include "broadcasting/IBroadcastGateway.h"
#define LATEST_APPROX 15

namespace inet {

class IMonitoringMechanism: public cObject {

private:
  int lastDensitiesApprox[LATEST_APPROX];

public:
  virtual int get_density_approx() = 0;
  virtual void compute_density_approx() = 0;
  virtual double mobility_estimation() = 0;
  virtual bool handle_messages(cMessage* m) = 0;
  virtual void initialise(std::shared_ptr<IBroadcastGateway> gateway) = 0;
  void initialiseAproxArray() {
      for (int i = 0; i < LATEST_APPROX; i++) lastDensitiesApprox[i] = -1;
  }
  int getLatestApprox(){
      int latest = - 1;
      for (int i = LATEST_APPROX - 1; i >= 0; i--) {
          if (lastDensitiesApprox[i] != -1) {
            latest = lastDensitiesApprox[i];
            break;
        }
      }
      return latest;
  }
  bool appendApprox(int approx) {
      bool r = false;
      for (int i = 0; i < LATEST_APPROX; i++) {
        if (lastDensitiesApprox[i] == -1) {
            lastDensitiesApprox[i] = approx;
            r = true;
            break;
        }
      }
      return r;
  }
  int roundApprox() {
      int j = 0;
      float avg = 0;
      for (int i = 0; i < LATEST_APPROX; i++) {
          if (lastDensitiesApprox[i] != -1) {
              avg = avg + lastDensitiesApprox[i];
              j++;
          } else
              break;
      }
      return (int) ceil(avg / (j*1.0));
  }
};

}

#endif
