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

#ifndef CDS_3_H_
#define CDS_3_H_

#include "broadcasting/IBroadcastProtocol.h"
#include "broadcasting/BroadcastingAppBase_m.h"


#include "Cds3_m.h"

using namespace std;

namespace inet {

class Cds_3 : public inet::BroadcastProtocolAdapter {
private:
    int age = 0;
    int lastSize = -1;
    bool doRule2;
    bool doOptiP;
    bool amIrelay;
    bool markingProcedureDone;
    bool optimizProcedureDone;

    std::map<std::string, NeighMap> neighboursChache;
    std::map<std::string, std::string> alreadyDispatched;
    std::map<std::string, std::string> relaysIcanSee;
    void applyRule1();
    void applyRule1_1();
    void applyRule2();
    void applyRule2_1();
    void doMarkingProcedure();
    std::map<std::string, std::string> computeUnion(NeighMap a, NeighMap b);
    bool isSubset(std::map<std::string, std::string> a, std::map<std::string, std::string> b);
    std::map<std::string, std::string> cloneNeighbors();
    std::map<std::string, std::string> cloneMap(NeighMap a);
    bool changeAtVicinity();

protected:
    inet::broadcasting::Hello* build_hello_message() override;
    void process_hello(const broadcasting::Hello* msg) override;
    void on_saying_hello() override;

    void process_payload(const broadcasting::Broadcast* m) override;
    void time_to_broadcast_payload(void* user_data) override;

    void initialize(const std::string& node_name, const std::shared_ptr<IBroadcastGateway> gateway) override;
};


}
#endif /* CDS_3_H_ */
