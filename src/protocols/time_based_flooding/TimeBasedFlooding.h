/*
 * TimeBasedFlooding.h
 *
 *  Created on: Sep 28, 2017
 *      Author: raziel
 */

#ifndef TIMEBASEDFLOODING_H_
#define TIMEBASEDFLOODING_H_

#include "broadcasting/BroadcastingAppBase.h"
#include "broadcasting/BroadcastingAppBase_m.h"
#include "broadcasting/IBroadcastProtocol.h"

namespace inet{
    class INET_API TimeBasedFlooding : public BroadcastProtocolAdapter {
        private:
            std::map<std::string, cMessage*> timers;
            std::map<std::string, std::string >  dispatchedMsgs;
            void process_payload(const broadcasting::Broadcast* m) override;
            void time_to_broadcast_payload(void* user_data) override;
    };
}

#endif /* TIMEBASEDFLOODING_H_ */
