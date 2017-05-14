//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
//

#include "adaptive.h"


#include "inet/mobility/contract/IMobility.h"

#include <algorithm>
#include <cmath>
#include <vector>

using namespace std;
using inet::broadcasting::Broadcast;

namespace inet {

Define_Module(FullyAdaptive);


void
FullyAdaptive::handleMessageWhenUp(cMessage *msg)
{
    if (msg->isSelfMessage()) {
        // detect if the message is handled by the protocols
        switch (msg->getKind()) {
          case START:
            BroadcastingAppBase::handleMessageWhenUp(msg);
            break;
          case SAY_HELLO:
            {
              gateway->send_package(build_hello_message());
              if (gateway->get_parameter<bool>(current_protocol_name, "nr_hello_messages")) {
                // cout << current_protocol_name << endl;
                gateway->delayed_event(SAY_HELLO, "helloTime", par("helloTime").doubleValue());
              }
              cancelAndDelete(msg);
              knownProtocols[current_protocol_name]->on_saying_hello();
            }

          break;
          default:
            if (!knownProtocols[current_protocol_name]->handle(msg)) {
              BroadcastingAppBase::handleMessageWhenUp(msg);
            }
            else {
              cancelAndDelete(msg);
            }
          break;
        }
    }
    else {
        BroadcastingAppBase::handleMessageWhenUp(msg);
    }

}

void
FullyAdaptive::on_payload_received(const Broadcast* m) {
  knownProtocols[current_protocol_name]->process_payload(m);
}

void
FullyAdaptive::time_to_broadcast_payload(void* user_data)
{
    knownProtocols[current_protocol_name]->time_to_broadcast_payload(user_data);
}


void
FullyAdaptive::on_hello_received(const broadcasting::Hello* msg)
{
  knownProtocols[current_protocol_name]->process_hello(msg);
}


void
FullyAdaptive::processStart()
{
  BroadcastingAppBase::processStart();

  auto protocols = { "Flooding2", "Mpr_t2" };
  for (const auto& p: protocols) {
    // select initial protocol
    current_protocol_name = p;
    auto current_protocol = dynamic_cast<IBroadcastProtocol*>(createOne(std::string("inet::" + current_protocol_name).c_str()));
    if (!current_protocol) {
      throw std::runtime_error("Couldn't create instance of class inet::" + current_protocol_name);
    }
    current_protocol->set_protocol_name(current_protocol_name);
    knownProtocols.emplace(current_protocol_name, std::unique_ptr<IBroadcastProtocol>(current_protocol));
  }

  // initialize protocol
  current_protocol_name = (gateway->get_current_position().y > 100)?"Flooding2":"Mpr_t2";
  gateway->setProtocolId(current_protocol_name);
  knownProtocols[current_protocol_name]->initialize(myself, gateway);
}


inet::broadcasting::Hello*
FullyAdaptive::build_hello_message()
{
  auto m = knownProtocols[current_protocol_name]->build_hello_message();
  m->setX(gateway->get_current_position().x);
  m->setY(gateway->get_current_position().y);
  m->setProtocolId (current_protocol_name.c_str());
  return m;
}

} //namespace
