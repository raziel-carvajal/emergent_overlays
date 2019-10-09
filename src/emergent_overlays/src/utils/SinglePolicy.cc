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

#include <SinglePolicy.h>

SinglePolicy::SinglePolicy(InteroperableBroadcast* c) {
  controller = c;
  densityKeep = controller->par("densityKeep").doubleValue();
  densityEmerge = controller->par("densityEmerge").doubleValue();
  stabilityMin = controller->par("stabilityMin").doubleValue();
}

int SinglePolicy::choseAlgorithm(double density, double stability) {
  controller->log("doIswitch ? " + to_string(density) + " >= " + to_string(densityKeep));
  return density >= densityKeep ? controller->Protocols::MPR : controller->Protocols::CONTROLLED_FLOODING;
}

bool SinglePolicy::emerge(double density, double stability) {
  controller->log("emerge ?" + to_string(stability >= stabilityMin && density >= densityEmerge));
  controller->log(
      to_string(stability) + " >= " + to_string(stabilityMin) + " and " + to_string(density) + " >= "
          + to_string(densityEmerge));
  return stability >= stabilityMin && density >= densityEmerge;
}

bool SinglePolicy::keep(double density, double stability) {
  return stability >= stabilityMin && density >= densityKeep;
}
