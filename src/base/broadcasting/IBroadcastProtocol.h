#ifndef __INET_BROADCAST_PROTOCOL_H_
#define __INET_BROADCAST_PROTOCOL_H_

#include <omnetpp.h>

#include <memory>

#include "IBroadcastGateway.h"
#include "BroadcastingAppBase_m.h"

namespace inet {

class IBroadcastProtocol: public cObject
{
public:
  virtual void initialize(const std::string& node_name, const std::shared_ptr<IBroadcastGateway> gateway) = 0;
  virtual bool handle(const cMessage *msg) = 0;
  virtual inet::broadcasting::Hello* build_hello_message() = 0;
  virtual void process_payload(const broadcasting::Broadcast* m) = 0;
  virtual void process_hello(const broadcasting::Hello* msg) = 0;
  virtual void on_saying_hello() = 0;
  virtual void time_to_broadcast_payload(void* user_data) = 0;
};


class BroadcastProtocolAdapter: public IBroadcastProtocol
{
protected:
  std::shared_ptr<IBroadcastGateway> gateway;
  std::string myself;
  std::map<std::string, Neighbor> neighbors;
  double get_random_delay() { return uniform(0.03, 0.1); }
public:
  void initialize(const std::string& node_name, const std::shared_ptr<IBroadcastGateway> gateway) override;
  bool handle(const cMessage *msg) override;
  inet::broadcasting::Hello* build_hello_message() override;
  void process_hello(const broadcasting::Hello* msg) override;
  void on_saying_hello() override;
};

}

#endif
