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

#include <utils/DensityMetrics.h>

float DensityMetrics::getTriangles() {
  if (oneHopNeigs.size() == 0)
    return 0.0;

  int t = 0;
  set<string> others;
  for (set<string>::iterator i = oneHopNeigs.begin(); i != oneHopNeigs.end(); ++i) {
    others = twoHopNeigs[*i];
    for (set<string>::iterator j = others.begin(); j != others.end(); ++j) {
      if (nodeId != *j && oneHopNeigs.find(*j) != oneHopNeigs.end()) {
        t += 1;
      }
    }
  }
  return t * 1.0;
}

float DensityMetrics::getCluCoefDenominator() {
  return oneHopNeigs.size() * (oneHopNeigs.size() - 1);
}

float DensityMetrics::getCloCordDenominator() {
  int d = 0;
  for (auto i = twoHopNeigs.begin(); i != twoHopNeigs.end(); ++i) {
    d += (i->second.size() - 1);
  }
  return d*1.0;
}
