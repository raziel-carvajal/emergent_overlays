////
//// This program is free software: you can redistribute it and/or modify
//// it under the terms of the GNU Lesser General Public License as published by
//// the Free Software Foundation, either version 3 of the License, or
//// (at your option) any later version.
////
//// This program is distributed in the hope that it will be useful,
//// but WITHOUT ANY WARRANTY; without even the implied warranty of
//// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//// GNU Lesser General Public License for more details.
////
//// You should have received a copy of the GNU Lesser General Public License
//// along with this program.  If not, see http://www.gnu.org/licenses/.
////
//
//#ifndef DENSITYMETRICS_H_
//#define DENSITYMETRICS_H_
//
//#include <iostream>
//#include <set>
//#include <map>
//
//using namespace std;
//
//class DensityMetrics {
//
//  private:
//    int density;
//
//    float clusteringCoef;
//    float closureCoef;
//
//    string nodeId;
//
//    set<string> oneHopNeigs;
//
//    map<string, set<string>> twoHopNeigs;
//
//  private:
//    float getTriangles();
//    float getCluCoefDenominator();
//    float getCloCordDenominator();
//
//  public:
//    enum Level {
//      LOW, MEDIUM, HIGH
//    };
//    virtual ~DensityMetrics() {
//    }
//    DensityMetrics() {
//    }
//
//    void setNeighbors(const set<string>& oneHopNeigs, const map<string, set<string> >& twoHopNeigs) {
//      this->oneHopNeigs = oneHopNeigs;
//      this->twoHopNeigs = twoHopNeigs;
//      float t = getTriangles();
//      if (t == 0) {
//        clusteringCoef = closureCoef = 0.0;
//        density = LOW;
//      } else {
//        float cluCoefDenom = getCluCoefDenominator();
//        float cloCoefDenom = getCloCordDenominator();
//        // when any of the denominators, is zero, the correspondent
//        // coefficient remains undetermined; instead, we report zero
//        clusteringCoef = cluCoefDenom != 0 ? t / cluCoefDenom : 0;
//        closureCoef = cloCoefDenom != 0 ? t / cloCoefDenom : 0;
//        if (closureCoef <= 1.0 / 3.0) {
//          density = LOW;
//        } else if(closureCoef <= 2.0 / 3.0) {
//          density = MEDIUM;
//        } else {
//          density = HIGH;
//        }
//      }
//    }
//    // getters
//    float getClosureCoef() const {
//      return closureCoef;
//    }
//    float getClusteringCoef() const {
//      return clusteringCoef;
//    }
//    int getDensity() {
//      return density;
//    }
//    void setNodeId(const string& nodeId) {
//      this->nodeId = nodeId;
//    }
//};
//
//#endif /* DENSITYMETRICS_H_ */
