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

#ifndef SINGLEPOLICY_H_
#define SINGLEPOLICY_H_

#include <IPolicy.h>
#include <common/InteroperableBroadcast.h>

class SinglePolicy : public IPolicy {
  public:
    double densityKeep;
    double densityEmerge;
    double stabilityMin;

    InteroperableBroadcast* controller = nullptr;

  public:
    SinglePolicy(InteroperableBroadcast* c);
    int choseAlgorithm(double density, double stability);
    bool emerge(double density, double stability);
    bool keep(double density, double stability);
};

#endif /* SINGLEPOLICY_H_ */
