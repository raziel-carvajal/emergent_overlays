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

#include "mpr2.h"
#include "mprMsgs_m.h"


#include "inet/networklayer/common/L3AddressResolver.h"
#include "inet/transportlayer/contract/udp/UDPControlInfo.h"
#include "inet/mobility/contract/IMobility.h"

#include <algorithm>
#include <cmath>
#include <vector>
#include <chrono>
#include <random>

using namespace std;
using inet::broadcasting::Broadcast;
using inet::BroadcastingAppBase;

namespace inet {

Define_Module(Mpr2);

void
Mpr2::handleMessageWhenUp(cMessage *msg){
    if (msg->isSelfMessage()){
        switch (msg->getKind()) {
            case START:
                cout << "Calling my START \n";
                ctrlMsg0->setKind(GET_2_HOPS_N);
                scheduleAt(simTime() + par("helloTime").doubleValue(), ctrlMsg0);
                break;
            case GET_2_HOPS_N:
                cout << "Calling Neigh.Neigh \n";
                if (neighbors.size() != 0){
                    L3AddressResolver resolver;
                    L3Address addr = resolver.resolve("255.255.255.255", L3AddressResolver::ADDR_IPv4);
                    typedef map<string, Neighbor>::iterator neigIt;
                    stringstream ss;
                    for (neigIt ite = neighbors.begin(); ite != neighbors.end(); ite++){
                        ss << ite->first << '_' << ite->second.addr.str() << '_' <<
                                ite->second.pos.x << '_' << ite->second.pos.y << '&';
                    }
                    mpr2::Neighbours* pck = new mpr2::Neighbours();
                    pck->setNeighbours(ss.str().c_str());
                    pck->setEmitter(myself.c_str());
                    cout << "Neighbors were sent: " << ss.str() << "\n";
                    socket.sendTo(pck, addr, remote_port);
                } else {
                    cout << "I have no neighbors \n";
                    return;
                }
                this->nr_hello_msg--;
                if (this->nr_hello_msg > 0) {
                    cout << "Another GET_2_HOP_N now and we still must send " << this->nr_hello_msg << " in " << myself << endl;
                    ctrlMsg0->setKind(GET_2_HOPS_N);
                    scheduleAt(simTime() + par("helloTime").doubleValue(), ctrlMsg0);
                }
                return;
                break;
        }
    }
    BroadcastingAppBase::handleMessage(msg);
}

bool
Mpr2::on_network_message_received(cPacket* pkt){
    return BroadcastingAppBase::on_network_message_received(pkt) ||
            processMessage<mpr2::Neighbours>(pkt, &Mpr2::onNeigh);
}

void
Mpr2::onNeigh(const mpr2::Neighbours* m){
    cout << "Calling onNeigh...";
    cout << "Received string: " << m->getNeighbours();
}

void
Mpr2::on_payload_received(const Broadcast* m) {
    // Store in a map a a broadcast session ID
    // string key = string(m->getId())
    emitBroadcastMsgReceived( string(m->getId()) );

    /*bool firstTime = !is_source && payloads[key].empty();

    if (firstTime) {
        double angle = 0;
        double delta = 2*PIPI / 36;
        while (angle < 2*PIPI) {
            auto y = std::sin(angle)*radious;
            auto x = std::cos(angle)*radious;
            received_from[key].insert(make_pair(x+position.x, y + position.y));
            angle += delta;
        }
    }

    auto mm = (abba::ABBABroadcast*)m;
    auto r = radious;

    auto a = mm->getX();
    auto b = mm->getY();

    for (auto i = received_from[key].begin(), f = received_from[key].end() ; i != f ; ++i) {
        auto x = i->first;
        auto y = i->second;

        if ((x - a)*(x - a) + (y - b)*(y - b) < r*r) {
            received_from[key].erase(i);
        }
    }

    if (firstTime) {
        payloads[key] = m->getPayload();
        // unsigned seed = std::chrono::system_clock::now().time_since_epoch().count();
        // std::minstd_rand0 generator (seed); // minstd_rand0 is a standard linear_congruential_engine
        // std::uniform_real_distribution<double> distribution(0.1,0.5);
        delayed_broadcast(key, uniform(0.1, 0.5));
    }*/
}


void
Mpr2::send_message(string& key)
{
    if (is_source || received_from[key].size() > 0) {
        //cerr << myself << " has still " << received_from[key].size() << " points " << endl;

        L3AddressResolver resolver;
        L3Address addr = resolver.resolve("255.255.255.255", L3AddressResolver::ADDR_IPv4); // TODO: refactor this
        Broadcast* m = new Broadcast("payload");
        m->setPayload(payloads[key].c_str());
        m->setId(key.c_str());
        m->setSender(myself.c_str());
        //m->setX(position.x);
        //m->setY(position.y);
        socket.sendTo(m, addr, remote_port);
        emitSent(key);
    }
}


void
Mpr2::time_to_broadcast_payload(void* user_data)
{
//    BroadcastingAppBase::time_to_broadcast_payload(user_data);
    string key;
    if (is_source) {
        key = myself + "-" + to_string(get_next_id_for_msg()); // TODO: createUniqueBroadcastSessionID()
        payloads[key] = " this is the payload, initially sent from " + myself;
        emitBroadcastMsgReceived(key);
    }
    else {
        char* s = (char*)user_data;
        key = string(s);
        delete s;
    }
    //cout << "Broadcasting in " << myself << " at " << simTime() << endl;
    send_message(key);
}

template <typename T> bool
Mpr2::processMessage(cPacket* pkt, void (Mpr2::*action)(const T* msg))
{
    T* t = check_and_cast_nullable<T*>(dynamic_cast<T*>(pkt));
    if (t != nullptr) {
        (this->*action)(t);
        return true;
    }
    else {
        return false;
    }
}

map<string, string>
Mpr2::splitString(string str, string delimiter){
    map<string, string> v;
    int i = 1;
    size_t pos = 0;
    string token;
    while ((pos = str.find(delimiter)) != string::npos) {
        token = str.substr(0, pos);
        v.emplace(to_string(i), token);
        str.erase(0, pos + delimiter.length());
        i++;
    }
    return v;
}

map<string, BroadcastingAppBase::Neighbor>
Mpr2::get2HopNe(string str){
    map<string, string> neighs = splitString(str, "&");
    map<string, string> attr;
    Neighbor n;
    size_t sz;
    map<string, BroadcastingAppBase::Neighbor> r;
    typedef map<string, string>::iterator strIt;
    for (strIt ite = neighs.begin(); ite != neighs.end(); ite++){
        attr = splitString(ite->second, "_");
        n.name = attr.find("1")->second;
        n.addr = getAddr(attr.find("2")->second);
        n.pos.x = stod(attr.find("3")->second, &sz);
        n.pos.x = stod(attr.find("4")->second, &sz);
        r.emplace(n.name, n);
    }
    return r;
}

} //namespace

