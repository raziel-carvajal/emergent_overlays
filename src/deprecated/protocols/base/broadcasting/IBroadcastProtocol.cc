#include "IBroadcastProtocol.h"


namespace inet{

void
BroadcastProtocolAdapter::initialize(const std::string& node_name, const std::shared_ptr<IBroadcastGateway> gateway)
{
  this->myself = node_name;
  this->gateway = gateway;
}


bool
BroadcastProtocolAdapter::handle(const cMessage *msg)
{
  return false;
}


void
BroadcastProtocolAdapter::on_saying_hello()
{
  return;
}


inet::broadcasting::Hello*
BroadcastProtocolAdapter::build_hello_message()
{
  auto hello = new inet::broadcasting::Hello("Hello");
  auto position = gateway->get_current_position();
  hello->setX(position.x);
  hello->setY(position.y);
  hello->setSender(myself.c_str());
  return hello;
}


void
BroadcastProtocolAdapter::process_hello(const broadcasting::Hello* msg)
{
  // add coordinates
  if (myself == msg->getSender())
    return;

  if (neighbors.find(msg->getSender()) == neighbors.end()) {

    Neighbor node;
    node.name = msg->getSender();
    node.addr = gateway->getAddr(msg->getSender());
    node.pos.x = msg->getX();
    node.pos.y = msg->getY();

    auto position = gateway->get_current_position();
    node.w = (position.x - msg->getX())*(position.x - msg->getX())
                            + (position.y - msg->getY())*(position.y - msg->getY());

    neighbors[node.name] = node;
  }
}

} // namespace
