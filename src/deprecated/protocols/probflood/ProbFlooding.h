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

#ifndef PROBFLOODING_H_
#define PROBFLOODING_H_

#include "broadcasting/IBroadcastProtocol.h"
#include "broadcasting/BroadcastingAppBase_m.h"
#include "ProbFlooding_m.h"

#include <algorithm>
#include <vector>
#include <set>

const double M = 0.601;

using namespace std;

namespace inet {

class ProbFlooding : public inet::BroadcastProtocolAdapter {

private:
    int   scheme;
    double     A;
    double     k;
    double     T;
    double alpha;
    double sigma;
    double miTreb;
    double maTreb;
    double probLim;

    enum SCHEME {
        DENSITY_AWARE,
        BORDER_AWARE,
        DENSITY_BORDER_AWARE,
        DENSITY_BORDER_AWARE_NEIGS_ELIMINATION,
    };
    set<string> alreadyDispatched;
    map<string, NeigsMap>  broadcastTable;

    int refresh_hops_message;

    bool doDensityAndBorderAwareScheme(NeigsMap senderNeigs, bool both);
    void erase_old_hops();
protected:
    void process_payload(const broadcasting::Broadcast* m) override;
    void time_to_broadcast_payload(void* user_data) override;
    void process_hello(const broadcasting::Hello* msg) override;
    void on_saying_hello() override;

    void initialize(const std::string& node_name, const std::shared_ptr<IBroadcastGateway> gateway) override;
    bool handle(const cMessage *msg) override;

};

}
#endif /* PROBFLOODING_H_ */
