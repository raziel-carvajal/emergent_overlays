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
  controller->cancelAndDelete(evalPoTimer);
  controller->cancelAndDelete(borderTimer);
}

SwitchingCriteria::SwitchingCriteria(InteroperableBroadcast* c, Observables* obs) {
  controller = c;
  observables = obs;

  int criteria = controller->par("adaptationPolicy").longValue();
  switch (criteria) {
    case SINGLE: {
      policy = new SinglePolicy(controller);
    }
      break;
    case COLLECTIVE: {
      policy = new CollectivePolicy(controller);
    }
      break;
    default:
      throw cRuntimeError("Unknown switching criteria [%d] SwitchingCriteria()", criteria);
      break;
  }

  double t = controller->par("applyAdapPolicy").doubleValue();
  controller->scheduleEvent(SEND_WILL_TO_SWITCH, t, switchTimer);
}

bool SwitchingCriteria::isSelfEvent(cMessage* event) {
  return event == switchTimer || event == evalPoTimer || event == borderTimer;
}

void SwitchingCriteria::handleEvent(cMessage* event) {
  switch (event->getKind()) {
    case SEND_WILL_TO_SWITCH: {
      // tell the controller to broadcast will to change
      addAdapHeader = true;

      double t = controller->par("applyAdapPolicy").doubleValue()
          - controller->par("broadcastInterval").doubleValue() / 2.0;
      controller->log("next evaluation for adaptation policy in: " + to_string(t) + "s");
      controller->scheduleEvent(SEND_WILL_TO_SWITCH, t, switchTimer);

      // reset variables that deal with border protocol
      controller->knownForeignAlgos.clear();
      controller->isBorderNode = false;
      enableBorderProtocol = true;

      double t1 = controller->par("broadcastInterval").doubleValue()
          + controller->par("broadcastInterval").doubleValue() / 4.0;
      controller->scheduleEvent(DISABLE_BORDER_PROTOCOL, t1, borderTimer);
    }
      break;
    case APPLY_POLICY: {
      applyPolicy();
    }
      break;
    case DISABLE_BORDER_PROTOCOL: {
      controller->log("DISABLE BORDER");
      enableBorderProtocol = false;
    }
      break;
    default:
      throw cRuntimeError("Unknown event [%d] in SwitchingCriteria.handleEvent()", (int) event->getKind());
      break;
  }
}

void SwitchingCriteria::onWillToChange() {
  double t = controller->par("waitToEvaluatePolicy").doubleValue();
  controller->scheduleEvent(APPLY_POLICY, t, evalPoTimer);
}

void SwitchingCriteria::applyPolicy() {
  controller->log("applying switching criteria");
  if (policy->emerge(observables->latestDensity, observables->latestStability)) {
    controller->updateRunningAlgorithm(controller->Protocols::MPR);
  } else {
    controller->updateRunningAlgorithm(controller->Protocols::CONTROLLED_FLOODING);
  }
}
