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
Abba2::updateAngleCovered(Coord b, string& key){
    double d = position.distance(b);
    double alp = acos(abs(position.x - b.x) / d) * 180 / M_PI;
    double bet = acos(d * 0.5 / radious) * 180 / M_PI;
    switch (findQuadrant(b)) {
    case FIRST:
        if (alp < bet) {
            firHalfPairs[key].push_back( make_pair(0, alp + bet) );
            secHalfPairs[key].push_back( make_pair(360 - (bet - alp), 360) );
        } else
            firHalfPairs[key].push_back( make_pair(alp - bet, alp + bet) );
        break;
    case SECOND:
        if (alp < bet) {
            firHalfPairs[key].push_back( make_pair(180 - (alp + bet), 180) );
            secHalfPairs[key].push_back( make_pair(180, 180 + (bet - alp)) );
        } else
            firHalfPairs[key].push_back( make_pair(alp - bet, alp + bet) );
        break;
    case THIRD:
        if (alp < bet) {
            firHalfPairs[key].push_back( make_pair(180 - (alp + bet), 180) );
            secHalfPairs[key].push_back( make_pair(180, 180 + (bet - alp)) );
        } else
            secHalfPairs[key].push_back( make_pair(180 + (alp - bet), 180 + alp + bet) );
        break;
    case FOURTH:
        if (alp < bet) {
            firHalfPairs[key].push_back( make_pair(360 - (alp + bet), 360) );
            secHalfPairs[key].push_back( make_pair(0, bet - alp) );
        } else
            secHalfPairs[key].push_back( make_pair(180 + (alp - bet), 180 + alp + bet) );
        break;
    default:
        cerr << myself + "ENUM value is not recognized\n";
        break;
    }
}

bool Abba2::inPair(double x, std::pair<double, double>& p) { return x < p.second ? true : false; }

double
Abba2::getAngleCovered(std::vector<std::pair<double, double>>& items) {
    int i, j; double sum;
    if (items.size() == 0) return 0.0;
    if (items.size() == 1) return items[0].second - items[0].first;
    std::sort(items.begin(), items.end());
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
    timeOut = par("timeOut").doubleValue();
    BroadcastingAppBase::processStart();
}

double
//Inversely proportional to the angle covered by all receptions
Abba2::computeTimeout(double angle) { return timeOut - timeOut * (angle / 360); }

void
Abba2::on_payload_received(const Broadcast* m) {
    if (m->getSender() == myself) return;//avoiding that the source of a broadcast receives the message
    string key = string(m->getId());
    cerr << getLogHeader() + "broadcast message " + key + " was sent by peer " + m->getSender() + "\n";
    emitBroadcastMsgReceived(key);
    if (ignoredMsgs.find(key) == ignoredMsgs.end()) {
        auto tmp = (abba::ABBABroadcast*)m;
        Coord b; b.x = tmp->getX(); b.y = tmp->getY();
        updateAngleCovered(b,key);
        cerr << getLogHeader() + "Computing angle covered\n";
        double angleCovered = getAngleCovered(firHalfPairs[key]) + getAngleCovered(secHalfPairs[key]);
        cerr << getLogHeader() + "current angle covered " +  to_string(angleCovered) + "\n";
        double newTimeout = computeTimeout(angleCovered);
        cerr << getLogHeader() + "computed timeout " +  to_string(newTimeout) + "\n";
        if (newTimeout <= 0 || newTimeout > timeOut) {// just in case we will considered that the angle is more than 306 degrees which is rare
            // TODO Optimizing messages delivery: find a way to put this event at the top of the scheduler
            // cancel retransmission (ASAP I thought...)
            cMessage* old_msg = delayMessages[key];
            cancelAndDelete(old_msg);
            ignoredMsgs[key] = key;
            firHalfPairs[key].clear();
        	  secHalfPairs[key].clear();
            cerr << getLogHeader() + "timeout zero for message  " + key + " \n";
        } else {
            if (timeouts.find(key) == timeouts.end()) {// is this key was received for the first time?
                cerr << getLogHeader() + "setting first timeout to " + to_string(newTimeout) + " \n";
            } else if (timeouts[key] != newTimeout) {// just cancel when timeouts differ
                cerr << getLogHeader() + "updating timeout to " + to_string(newTimeout) + " \n";
                cMessage* old_msg = delayMessages[key];
                cancelAndDelete(old_msg);
            }

            if (std::isnan(newTimeout)) { // FIXME: well, something the previous code tries to go back in time :-)
              newTimeout = 0.001;
            }
            timeouts[key] = newTimeout;
            delayMessages[key] = delayed_broadcast(key, newTimeout);
        }
    } else {
        cerr << getLogHeader() + "ignoring in reception this message " + key + " \n";
    }
}


void
Abba2::send_message(string& key)
{
    bool applyRetransmission = ignoredMsgs.find(key) == ignoredMsgs.end();
    if (applyRetransmission) {
        cerr << getLogHeader() + "broadcasting message " + key + " \n";
        // this happens when the timeout couldn't be stop (imminent retransmission)
        ignoredMsgs[key] = key;
        firHalfPairs[key].clear();
        secHalfPairs[key].clear();

        abba::ABBABroadcast* m = new abba::ABBABroadcast("payload");
        m->setX(position.x);
        m->setY(position.y);
        broadcast(key, m);
        emitSent(key);
    } else {
        cerr << getLogHeader() + "ignoring message at send_message()" + key + " \n";
    }
}


void
Abba2::time_to_broadcast_payload(void* user_data)
{
    string key = is_source ? myself + "-" + to_string(get_next_id_for_msg()) : string((char*)user_data);
    if (is_source) {
        emitBroadcastMsgReceived(key);
        ignoredMsgs[key] = key;
        cerr << getLogHeader() + "doing broadcast of message  " + key + " \n";
        abba::ABBABroadcast* m = new abba::ABBABroadcast("payload");
        m->setX(position.x);
        m->setY(position.y);
        broadcast(key, m);
        emitSent(key);
    } else
        send_message(key);
}

} //namespace
