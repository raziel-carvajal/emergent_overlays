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

#include "broadcasting/BroadcastingAppBase.h"
#include "broadcasting/BroadcastingAppBase_m.h"
#include "ProbFlooding_m.h"

#include <algorithm>
#include <vector>
const double M = 0.601;

using namespace std;

namespace inet {

class ProbFlooding : public BroadcastingAppBase {

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
    map<string, string> alreadyDispatched;
    map<string, NeigsMap>  broadcastTable;
    bool doDensityAndBorderAwareScheme(NeigsMap senderNeigs, bool both);

protected:
    virtual void on_payload_received(const broadcasting::Broadcast* m);
    void virtual time_to_broadcast_payload(void* user_data);
    virtual void on_hello_received(const broadcasting::Hello* msg);
    virtual bool handleNodeStart(IDoneCallback *doneCallback);

};

}
#endif /* PROBFLOODING_H_ */
