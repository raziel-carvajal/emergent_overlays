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

#ifndef SWITCHINGCRITERIA_H_
#define SWITCHINGCRITERIA_H_

#include <cmessage.h>
#include <Observables.h>
#include <IPolicy.h>

using namespace std;

class InteroperableBroadcast;

class SwitchingCriteria {
  private:
    enum Timers {
      APPLY_CRITERIA
    };

    enum Policies {
      SINGLE, COLLECTIVE
    };

    InteroperableBroadcast* controller = nullptr;

    IPolicy* policy = nullptr;

    Observables* observables = nullptr;

    cMessage* switchTimer = new cMessage("swichTimer");

  private:
    void applyCriteria();

  public:
    SwitchingCriteria(InteroperableBroadcast* c, Observables* obs);

    bool isSelfEvent(cMessage* event);
    void handleEvent(cMessage* event);
    void cancelSelfEvents();
};

#endif /* SWITCHINGCRITERIA_H_ */
