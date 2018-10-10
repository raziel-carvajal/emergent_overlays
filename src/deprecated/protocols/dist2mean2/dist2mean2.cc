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

Register_Class(Dist2Mean2);


void
Dist2Mean2::process_payload(const Broadcast* m) {
    string key = string(m->getId());
    if (m->getSender() == myself) return;

    bool first_time =  payloads.find(m->getPayload()) == payloads.end();

    gateway->emitBroadcastMsgReceived(key);

    received_from[key].insert(m->getSender());
    if (first_time) {
        Coord position = gateway->get_current_position();
        payloads[key] = m->getPayload();
        auto p = neighbors[m->getSender()].pos;
        double d = sqrt((p.x - position.x)*(p.x - position.x) + (p.y - position.y)*(p.y - position.y));
        double delay = (1 - d/gateway->get_transmission_radius()) * 0.5;
        // cerr  << "A delay : " << delay << endl;
        // delayed_broadcast();
        gateway->delayed_broadcast(key, delay);
    }
}


void
Dist2Mean2::send_message(const string& key, bool is_source)
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

    Coord position = gateway->get_current_position();
    double dist = sqrt((mx - position.x)*(mx - position.x) + (my - position.y)*(my - position.y));

  	double norm_d = dist / gateway->get_transmission_radius();


  	//int n = (neighbors.size() > 0) ? neighbors.size() : 0;

    //double t_c = 0.95 - 0.7 * exp(-0.11*n);

    must_send = must_send || norm_d > 0.40; // || norm_d > t_c;

    // if (norm_d < t_c)
    //   cerr << norm_d << " < " << t_c << endl;
  }



  if (must_send) {

      // EV_DEBUG << "====================== Sending in " << myself << " because the distance to mean  is " << dist << " > " << par("threshold").doubleValue() << "\n";
      // cout << myself << ": sending !!! " << "\n";
      Broadcast* m = new Broadcast("payload");
      payloads[key] = key;
      gateway->broadcast(key, m);
  }
}


void
Dist2Mean2::time_to_broadcast_payload(void* user_data)
{
    string key;
    bool is_source = (user_data == nullptr);
    if (is_source) {
        key = gateway->createUniqueBroadcastingSessionId();
        gateway->emitBroadcastMsgReceived(key);
    }
    else {
        char* s = (char*)user_data;
        key = string(s);
        delete s;
    }
    // cout << "Broadcasting in " << myself << endl;
    send_message(key, is_source);
}



} //namespace
