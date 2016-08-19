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

#include "abba2.h"
#include "abbaMsgs_m.h"


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

namespace inet {

Define_Module(Abba2);

int
Abba2::findQuadrant(Coord b) {
    if (b.x > position.x) {
        if (b.y >= position.y) return FIRST;
        else return FOURTH;
    } else {
        if (b.y > position.y) return SECOND;
        else return THIRD;
    }
}

void
Abba2::updateAngleCovered(Coord b){
    double d = position.distance(b);
    double alp = acos(abs(position.x - b.x) / d) * 180 / M_PI;
    double bet = acos(d * 0.5 / radious) * 180 / M_PI;
    switch (findQuadrant(b)) {
    case FIRST:
        //cerr << myself + " FIRST\n";
        if (alp < bet) {
            firHalfPairs.push_back( make_pair(0, alp + bet) );
            secHalfPairs.push_back( make_pair(360 - (bet - alp), 360) );
        } else
            firHalfPairs.push_back( make_pair(alp - bet, alp + bet) );
        break;
    case SECOND:
        //cerr << myself + " SECOND\n";
        if (alp < bet) {
            firHalfPairs.push_back( make_pair(180 - (alp + bet), 180) );
            secHalfPairs.push_back( make_pair(180, 180 + (bet - alp)) );
        } else
            firHalfPairs.push_back( make_pair(alp - bet, alp + bet) );
        break;
    case THIRD:
        //cerr << myself + " THIRD\n";
        if (alp < bet) {
            firHalfPairs.push_back( make_pair(180 - (alp + bet), 180) );
            secHalfPairs.push_back( make_pair(180, 180 + (bet - alp)) );
        } else
            secHalfPairs.push_back( make_pair(180 + (alp - bet), 180 + alp + bet) );
        break;
    case FOURTH:
        //cerr << myself + " FOURTH\n";
        if (alp < bet) {
            firHalfPairs.push_back( make_pair(360 - (alp + bet), 360) );
            secHalfPairs.push_back( make_pair(0, bet - alp) );
        } else
            secHalfPairs.push_back( make_pair(180 + (alp - bet), 180 + alp + bet) );
        break;
    default:
        cerr << myself + "ENUM value is not recognized\n";
        break;
    }
}

bool Abba2::inPair(double x, std::pair<double, double> p) { return x < p.second ? true : false; }

double
Abba2::getAngleCovered(std::vector<std::pair<double, double>> items) {
    int i, j; double sum;
    std::sort(items.begin(), items.end());
    if (items.size() == 1) return items[0].second - items[0].first;
    for (i = 0; i < items.size(); i++)
        sum += items[i].second - items[i].first;
    for (i = 0; i < items.size() - 1; i++) {
        for (j = i + 1; j < items.size(); j++) {
            if ( inPair(items[j].first, items[i]) ) {
                if (items[j].second < items[i].second) sum -= items[j].second - items[j].first;
                else sum -= items[i].second - items[j].first;
            }
        }
    }
    return sum;
}

void Abba2::processStart() {
    timeOut = par("timeOut").longValue();
    BroadcastingAppBase::processStart();
}

double
//Inversely proportional to the angle covered by all receptions
Abba2::computeTimeout(double angle) { return timeOut - timeOut * (angle / 360); }

void
Abba2::on_payload_received(const Broadcast* m) {
    /* TODO
     * Take into consideration that this implementation isn't capable to compute two the reception
     * of more than one consecutive broadcast session, i. e., if two different broadcast messages
     * are received one after the other, then the vectors of pairs will store angles as it was
     * just one broadcast.
     * IDEA: one broadcast ID must map two independent vectors of pairs*/
    string key = string(m->getId());
    cerr << getLogHeader() + "reception of message " + key + " \n";
    emitBroadcastMsgReceived(key);
    if (ignoredMsgs.find(key) == ignoredMsgs.end()) {
        auto tmp = (abba::ABBABroadcast*)m;
        Coord b; b.x = tmp->getX(); b.y = tmp->getY();
        updateAngleCovered(b);
        double angleCovered = getAngleCovered(firHalfPairs) + getAngleCovered(secHalfPairs);
        cerr << getLogHeader() + "current angle covered " +  to_string(angleCovered) + " for message " + key + "\n";
        double newTimeout = computeTimeout(angleCovered);


        cMessage* mm = new cMessage("broadcast delay");
        mm->setContextPointer(strdup(key.c_str()));
        mm->setKind(BROADCAST_DELAY);

        if (newTimeout <= 0) {// just in case we will considered that the angle is more than 306 degrees which is "rare"
            // TODO find a way to put this event at the top of the scheduler
            // cancel retransmission (ASAP I thought...)
            cancelAndDelete(mm);
            ignoredMsgs[key] = key;
            cerr << getLogHeader() + "timeout zero for message  " + key + " \n";
        } else {
            if (timeouts.find(key) == timeouts.end()) {// is this key was received for the first time?
                cerr << getLogHeader() + "setting first timeout to " + to_string(newTimeout) + " \n";
                timeouts[key] = newTimeout;
                //delayed_broadcast(key, uniform(newTimeout, newTimeout + 0.2));
                delayed_broadcast(key, newTimeout);

            } else if (timeouts[key] != newTimeout) {// just cancel when timeouts differ
                cerr << getLogHeader() + "updating timeout to " + to_string(newTimeout) + " for message " + key + " \n";
                cancelAndDelete(mm);
                timeouts[key] = newTimeout;
                //delayed_broadcast(key, uniform(newTimeout, newTimeout + 0.2));
                delayed_broadcast(key, newTimeout);
            }
        }
    } else {
        cerr << getLogHeader() + "ignoring in reception this message " + key + " \n";
    }
/*    bool firstTime = !is_source && payloads[key].empty();

    if (firstTime) {
        double angle = 0;
        double delta = 2*M_PI / 36;
        while (angle < 2*M_PI) {
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
        delayed_broadcast(key, uniform(0.1, 0.5));
    }*/
}


void
Abba2::send_message(string& key)
{

    //if (is_source || received_from[key].size() > 0) {
    cerr << getLogHeader() + "calling send_message() for message " + key + " \n";
    bool applyRetransmission = ignoredMsgs.find(key) == ignoredMsgs.end();
    if (is_source || applyRetransmission) {
        cerr << getLogHeader() + "broadcasting message " + key + " \n";
        // this happens when the timeout couldn't be stop (imminent retransmission)
        ignoredMsgs[key] = key;
        while (!firHalfPairs.empty()) firHalfPairs.pop_back();
        while (!secHalfPairs.empty()) secHalfPairs.pop_back();

        L3AddressResolver resolver;
        L3Address addr = resolver.resolve("255.255.255.255", L3AddressResolver::ADDR_IPv4); // TODO: refactor this
        abba::ABBABroadcast* m = new abba::ABBABroadcast("payload");
        m->setPayload(payloads[key].c_str());
        m->setId(key.c_str());
        m->setSender(myself.c_str());
        m->setX(position.x);
        m->setY(position.y);
        socket.sendTo(m, addr, remote_port);
        emitSent(key);
    } else {
        cerr << getLogHeader() + "ignoring message at send_message()" + key + " \n";
    }
}


void
Abba2::time_to_broadcast_payload(void* user_data)
{
    string key;
    if (is_source) {
        key = myself + "-" + to_string(get_next_id_for_msg()) + ":";
        auto s = " this is the payload, initially sent from " + myself;
        cerr << key + s + "\n";
        payloads[key] = key + s;
        /* XXX why the source have to say "I received a broadcast message..." ?
        //      isn't just for non source nodes?
        emitBroadcastMsgReceived(key);
        */
        emitBroadcastMsgReceived(key);
    }
    else {
        char* s = (char*)user_data;
        key = string(s);
        delete s;
    }
    send_message(key);
}

std::string Abba2::getLogHeader() { return simTime().str() + " " + myself + " :: " ;}

} //namespace
