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

#include <Observables.h>
#include <common/InteroperableBroadcast.h>

Observables::Observables(InteroperableBroadcast* c) {
  controller = c;
  withRateOfChange = controller->par("withRateOfChange").boolValue();
  if (withRateOfChange)
    initForRateOfChange();
  else
    initForWeightedAvg();
  intervals = getInvervals();
  //
  double t = controller->par("startObsApprox").doubleValue();
//  controller->log("update window every: " + to_string(t) + "s");
  controller->scheduleEvent(UPDATE_WINDOW, t, updateTimer);
}

void Observables::registerObservables(double density, double mobility) {
  controller->emit(controller->densityObs, density);
  controller->emit(controller->mobilityObs, mobility);
}

double Observables::getDensityObs() {
  double rate = 0;
  if (withRateOfChange) {
    for (auto it = densityApprox.begin(); it != densityApprox.end(); ++it) {
      rate += it->second;
    }
  } else {
    // TODO implement weighted average over "densityApprox"
  }
  rate /= (densityApprox.size() * 1.0);
//  controller->log("Density rate: " + to_string(rate));
  latestDensity = rate;
  return rate;
}

double Observables::getMobilityObs() {
  double rate = 0, delta;
  set<string> u, i, temp0, temp1;
  set<string>::iterator k;
  if (withRateOfChange) {
    for (auto j = intervals.begin(); j != intervals.end(); ++j) {
      u = set<string>(mobilityApprox[j->second[1]]);
      temp0 = mobilityApprox[j->second[0]];
      for (k = temp0.begin(); k != temp0.end(); ++k) {
        u.insert(*k);
      }
      temp1 = mobilityApprox[j->second[1]];
      for (k = temp0.begin(); k != temp0.end(); ++k) {
        if (temp1.find(*k) != temp1.end()) {
          i.insert(*k);
        }
      } // at this point: u <- union of sets AND i <- intersection of sets
      for (k = i.begin(); k != i.end(); ++k) {
        u.erase(*k);
      } // makes {u} - {i}
      delta = u.size();
      rate += delta;
    }
  } else {
    // TODO implement weighted average over "mobilityApprox"
  }
  rate /= (intervals.size() * 1.0);
//  controller->log("Mobility rate: " + to_string(rate));
  latestStability = rate;
  return rate;
}

void Observables::updateTimeWindow() {
  indx++;
  densityApprox[indx] = neighbors.size();
  string info = "update with index [" + to_string(indx) + "]. Neighbors: ";
  for (set<string>::iterator it = neighbors.begin(); it != neighbors.end(); ++it) {
    mobilityApprox[indx].insert(*it);
    info += *it + " ";
  }
//  controller->log(info);
  int n = controller->par("windowSize").longValue();
  if (indx % n == 0) {
    controller->log("record observables");
    registerObservables(getDensityObs(), getMobilityObs());
    indx = 0;
    for (auto it = mobilityApprox.begin(); it != mobilityApprox.end(); ++it)
      it->second.clear();
  }
}

bool Observables::isSelfEvent(cMessage* event) {
  return event == updateTimer;
}

map<int, int[2]> Observables::getInvervals() {
  map<int, int[2]> intervals;
  int j = 1;
  string info("Intervals: ");
  for (int i = windowIndx.size() - 1; i > 0; --i) {
    intervals[j][1] = windowIndx.at(i);
    intervals[j][0] = windowIndx.at(i - 1);
    info += "(" + to_string(intervals[j][0]) + ", " + to_string(intervals[j][1]) + ") ";
    j++;
  }
//  controller->log(info);
  return intervals;
}

void Observables::initForWeightedAvg() {
  // XXX this procedure works ONLY when the window size is at most 10
  // FIXME fetch sequence from "indexSequence" (see InteroperableBroadcast.ned) when
  //  such parameter is defined as a string
  int seqSize = 0;
  int denom = 1;
  int indexSequence = controller->par("indexSequence").longValue();
  while (indexSequence / denom > 0) {
    seqSize++;
    denom *= 10;
  }
  denom /= 10;
  int item;
  for (int i = 0; i < seqSize; ++i) {
    item = indexSequence / denom;
    windowIndx.push_back(item);
    indexSequence -= item * denom;
    denom /= 10;
  }
  if (controller->par("withLastMeasure").boolValue())
    windowIndx.push_back(controller->par("windowSize").longValue());
}

void Observables::initForRateOfChange() {
  int n = controller->par("windowSize").longValue();
  for (int i = 0; i < n; ++i) {
    windowIndx.push_back(i + 1);
  }
}

void Observables::handleEvent(cMessage* event) {
  switch (event->getKind()) {
    case UPDATE_WINDOW: {
      updateTimeWindow();
      neighbors.clear();
      double t = controller->par("getObsInterval").doubleValue();
      controller->scheduleEvent(UPDATE_WINDOW, t, updateTimer);
    }
      break;
    default:
      throw cRuntimeError("Unknown event [%d] in Observable.handleEvent()", (int) event->getKind());
      break;
  }
}

void Observables::cancelSelfEvents() {
  if (updateTimer)
    controller->cancelAndDelete(updateTimer);
}

int Observables::getLatestNeigsNo() {
  return densityApprox[indx];
}
