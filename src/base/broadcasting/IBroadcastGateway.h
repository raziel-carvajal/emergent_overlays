#ifndef __INET_BROADCAST_GATEWAY_H_
#define __INET_BROADCAST_GATEWAY_H_

#include "inet/networklayer/common/L3AddressResolver.h"
#include "inet/common/geometry/common/Coord.h"

#include "BroadcastingAppBase_m.h"

namespace inet {

template<typename T>
struct identity { typedef T type; };

class IBroadcastGateway {
protected:
  virtual double get_double_parameter(const std::string& param) = 0;
public:
  virtual Coord get_current_position() = 0;
  virtual double get_transmission_radius() = 0;
  virtual L3Address getAddr(const std::string& id) = 0; // so ugly

  virtual void send_package(cPacket* m) = 0; // send a package to all nearby devices
  virtual void broadcast(std::string key, broadcasting::Broadcast* msg) = 0;
  virtual std::string createUniqueBroadcastingSessionId() = 0;

  virtual void emitBroadcastMsgReceived(const std::string& value) = 0; // important. you should use it. log data (statistics in vector)

  virtual void delayed_event(int type, const std::string& key, double delay) = 0;
  virtual cMessage* delayed_broadcast(const std::string& key, double delay) = 0; // call this one in the implementation of on_payload_received. it is like a Timer that will be called after 'delay' seconds
  virtual void cancel_message(cMessage* m) = 0;
  virtual int register_new_control_message() = 0;


  template<typename T> T get_parameter(const std::string& param) {
    return get_parameter(param, identity<T>());
  }

  double get_parameter(const std::string& param, identity<double>) {
    return get_double_parameter(param);
  }
};

}

#endif
