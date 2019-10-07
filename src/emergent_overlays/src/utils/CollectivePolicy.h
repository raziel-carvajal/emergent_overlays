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

#ifndef COLLECTIVEPOLICY_H_
#define COLLECTIVEPOLICY_H_

#include <IPolicy.h>
#include <common/InteroperableBroadcast.h>

class CollectivePolicy : public IPolicy {
  public:
    double densityThr1;
    double densityThr2;
    double stabilityThr1;
    double stabilityThr2;

    InteroperableBroadcast* controller = nullptr;
  public:
    CollectivePolicy(InteroperableBroadcast* c);
    int choseAlgorithm(double density, double stability);
    bool emerge(double density, double stability);
};

#endif /* COLLECTIVEPOLICY_H_ */
