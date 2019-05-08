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

#include <SwitchingCriteria.h>
#include <common/InteroperableBroadcast.h>
#include <SinglePolicy.h>
#include <CollectivePolicy.h>

void SwitchingCriteria::cancelSelfEvents() {
  controller->cancelAndDelete(switchTimer);
}

SwitchingCriteria::SwitchingCriteria(InteroperableBroadcast* c, Observables* obs) {
  controller = c;
  observables = obs;

  int criteria = controller->par("adaptationPolicy").longValue();
  switch (criteria) {
    case SINGLE: {
      controller->log("using single adap policy");
      policy = new SinglePolicy(controller);
    }
      break;
    case COLLECTIVE: {
      controller->log("using collective adap policy");
      policy = new CollectivePolicy(controller);
    }
      break;
    default:
      throw cRuntimeError("Unknown switching criteria [%d] SwitchingCriteria()", criteria);
      break;
  }

  double t = controller->par("applyAdapPolicy").doubleValue();
  controller->log("apply switching criteria in " + to_string(t) + "s");
  controller->scheduleEvent(APPLY_CRITERIA, t, switchTimer);
}

bool SwitchingCriteria::isSelfEvent(cMessage* event) {
  return event == switchTimer;
}

void SwitchingCriteria::handleEvent(cMessage* event) {
  switch (event->getKind()) {
    case APPLY_CRITERIA: {
      controller->updateRunningAlgorithm(
          policy->choseAlgorithm(observables->latestDensity, observables->latestStability));

      double t = 2 * controller->par("windowSize").doubleValue() * controller->par("broadcastInterval").doubleValue();
      controller->log("apply switching criteria in " + to_string(t) + "s");
      controller->scheduleEvent(APPLY_CRITERIA, t, switchTimer);
    }
      break;
    default:
      throw cRuntimeError("Unknown event [%d] in SwitchingCriteria.handleEvent()", (int) event->getKind());
      break;
  }
}
