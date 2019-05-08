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

#ifndef OBSERVABLES_H_
#define OBSERVABLES_H_

#include <map>
#include <set>
#include <cmessage.h>
#include <vector>

using namespace std;

class InteroperableBroadcast;

class Observables {
  private:

    enum Timers {
      UPDATE_WINDOW
    };

    int indx = 0;

    bool withRateOfChange;

    vector<int> windowIndx;

    // time window of density and mobility
    map<int, int> densityApprox;
    map<int, set<string>> mobilityApprox;
    map<int, int[2]> intervals;

    InteroperableBroadcast* controller = nullptr;

    cMessage* updateTimer = new cMessage("updateTimer");

  private:

    void registerObservables(double density, double mobility);
    double getDensityObs();
    double getMobilityObs();
    void updateTimeWindow();

    map<int, int[2]> getInvervals();

  public:
    double latestDensity;
    double latestStability;

    set<string> neighbors;

  public:
    Observables(InteroperableBroadcast* c);
    virtual ~Observables() {

    }
    void initForWeightedAvg();
    void initForRateOfChange();
    bool isSelfEvent(cMessage* event);
    void handleEvent(cMessage* event);
    void cancelSelfEvents();
    int getLatestNeigsNo();
};

#endif /* OBSERVABLES_H_ */
