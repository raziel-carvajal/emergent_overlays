//
// Copyright (C) 2013 OpenSim Ltd.
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, see <http://www.gnu.org/licenses/>.
//

#ifndef __INET_ENERGY_AWARE_RADIO_H
#define __INET_ENERGY_AWARE_RADIO_H

#include "inet/power/contract/IEnergyStorage.h"
#include "inet/physicallayer/common/packetlevel/Radio.h"
#include "inet/physicallayer/common/packetlevel/RadioFrame.h"

namespace broadcasting {

/**
 */
class INET_API EnergyAwareIdealRadio : public inet::physicallayer::Radio
{

  protected:
    /**
     * The Energy Storage model.
     */
    inet::power::IEnergyStorage *energyStorage;
    /**
     * The module id of the Energy Storage model.
     */
    int energyStorageId = -1;

  protected:
    virtual void initialize(int stage) override;

    virtual void startTransmission(cPacket *macFrame);

    virtual void startReception(inet::physicallayer::RadioFrame *radioFrame);

  public:
    EnergyAwareIdealRadio();
    virtual ~EnergyAwareIdealRadio();
};

} // namespace broadcasting

#endif // ifndef __INET_ENERGY_AWARE_RADIO_H
