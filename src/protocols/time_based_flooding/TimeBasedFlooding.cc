/*
 * TimeBasedFlooding.cc
 *
 *  Created on: Sep 28, 2017
 *      Author: raziel
 */

#include "TimeBasedFlooding.h"

using namespace std;
using inet::broadcasting::Broadcast;

Register_Class(inet::TimeBasedFlooding);

void inet::TimeBasedFlooding::process_payload(
        const broadcasting::Broadcast* m) {
    string key = string(m->getId());
    gateway->emitBroadcastMsgReceived(key);
//    cout << simTime().str() << " " << myself << " :: " << "reception of 1" << key << endl;
    if (myself == m->getSender()) return;
//    cout << simTime().str() << " " << myself << " :: " << "reception of 2" << key << endl;
    bool wasntDispatched = dispatchedMsgs.find(key) == dispatchedMsgs.end();
    if (wasntDispatched) {
        bool wasntReceived = timers.find(key) == timers.end();
        double maxTimer = gateway->get_parameter<double>(protocol_name, "maxTimer");
        double t = uniform(0, maxTimer);
        timers[key] = gateway->delayed_broadcast(key, t);
//        cout << simTime().str() << " " << myself << " :: " << "first reception of " << key;
//        cout << " its broadcast will be delayed " << t << " seconds" << endl;
//        if (wasntReceived) {
//            double maxTimer = gateway->get_parameter<double>(protocol_name, "maxTimer");
//            double t = uniform(0, maxTimer);
////            cout << simTime().str() << " " << myself << " :: " << "first reception of " << key;
////            cout << " its broadcast will be delayed " << t << " seconds" << endl;
//            timers[key] = gateway->delayed_broadcast(key, t);
//        } else {
////            cout << simTime().str() << " " << myself << " :: " << "forward of  " << key << " was cancelled" << endl;
//            if (timers.find(key) != timers.end()) {
//                gateway->cancel_message(timers[key]);
//                timers.erase(key);
//                dispatchedMsgs[key] = key;
//            }
//        }

    }
}

void inet::TimeBasedFlooding::time_to_broadcast_payload(void* user_data) {
    string key;
    if (!user_data){ //node is the source of a broadcast session
        key = gateway->createUniqueBroadcastingSessionId();
//        cout << simTime().str() << " " << myself << " :: " << "forward of " << key << " as source";
    } else { //a msg containing user_data was delayed and now is time to forward it
        key = string( (char*)user_data );
//        cout << simTime().str() << " " << myself << " :: " << "forward of " << key << " cause timer reaches 0";
    }
    gateway->broadcast(key, new broadcasting::Broadcast("payload"));
//    cout << " broadcast of " << key << " was forwarded" << endl;
    dispatchedMsgs[key] = key;
//    cout << "deleting " << key << " " << endl;
}
