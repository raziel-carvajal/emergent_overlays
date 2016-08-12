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

#include "dist2mean2.h"


#include "inet/networklayer/common/L3AddressResolver.h"
#include "inet/transportlayer/contract/udp/UDPControlInfo.h"
#include "inet/mobility/contract/IMobility.h"

#include <algorithm>

using namespace std;
using inet::broadcasting::Broadcast;

namespace inet {

Define_Module(Dist2Mean2);

Dist2Mean2::Dist2Mean2()
{
}


void
Dist2Mean2::on_payload_received(const Broadcast* m) {

    string key = string(m->getId());
    BroadcastingAppBase::on_payload_received(m);

    bool first_time = !is_source && received_from[key].empty(); // is the first time I received this message ?

    emitBroadcastMsgReceived(key);

    received_from[key].insert(m->getSender());
    if (first_time) {
        payloads[key] = m->getPayload();
        auto p = neighbors[m->getSender()].pos;
        double d = sqrt((p.x - position.x)*(p.x - position.x) + (p.y - position.y)*(p.y - position.y));
        double delay = (1 - d/radious) * 0.5;
        // cerr  << "A delay : " << delay << endl;
        // delayed_broadcast();
        delayed_broadcast(key, delay);
    }
}


void
Dist2Mean2::send_message(string& key)
{

  bool must_send = is_source;

  if (!must_send) {
    double mx = 0;
    double my = 0;

    for (auto& s : received_from[key]) {
        auto p = neighbors[s].pos;
        mx += p.x;
        my += p.y;
    }
    mx /= received_from[key].size();
    my /= received_from[key].size();

    double dist = sqrt((mx - position.x)*(mx - position.x) + (my - position.y)*(my - position.y));

  	double norm_d = dist / radious;


  	int n = (neighbors.size() > 0) ? neighbors.size() : 0;

  	double t_c = 0.95 - 0.7 * exp(-0.11*n);

    must_send = must_send || norm_d > 0.40; // || norm_d > t_c;

    // if (norm_d < t_c)
    //   cerr << norm_d << " < " << t_c << endl;
  }



  if (must_send) {

      // EV_DEBUG << "====================== Sending in " << myself << " because the distance to mean  is " << dist << " > " << par("threshold").doubleValue() << "\n";
      // cout << myself << ": sending !!! " << "\n";
      emitSent(key);
      Broadcast* m = new Broadcast("payload");
      m->setPayload(payloads[key].c_str());
      m->setId(key.c_str());
      m->setSender(myself.c_str());
      send_package(m);
  }
}


void
Dist2Mean2::time_to_broadcast_payload(void* user_data)
{
    BroadcastingAppBase::time_to_broadcast_payload(user_data);
    string key;
    if (is_source) {
        key = myself + "-" + to_string(get_next_id_for_msg());
        payloads[key] = " this is the payload, initially sent from " + myself;
        emitBroadcastMsgReceived(key);
    }
    else {
        char* s = (char*)user_data;
        key = string(s);
        delete s;
    }
    // cout << "Broadcasting in " << myself << endl;
    send_message(key);
}



} //namespace
