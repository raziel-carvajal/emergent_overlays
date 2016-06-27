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

#include "inet/common/lifecycle/NodeOperations.h"
#include "inet/common/ModuleAccess.h"
#include "inet/physicallayer/common/packetlevel/RadioFrame.h"

#include "EnergyAwareIdealRadio.h"

namespace broadcasting {

Define_Module(EnergyAwareIdealRadio);

EnergyAwareIdealRadio::EnergyAwareIdealRadio() :
    Radio(),
    energyStorage(nullptr)
{
}

EnergyAwareIdealRadio::~EnergyAwareIdealRadio()
{
}

void EnergyAwareIdealRadio::initialize(int stage)
{
  inet::physicallayer::Radio::initialize(stage);
  if (stage == inet::INITSTAGE_LOCAL) {
      energyStorage = inet::getModuleFromPar<inet::power::IEnergyStorage>(par("energySourceModule"), this);
      energyStorageId = check_and_cast<cModule *>(energyStorage)->getId();
  }
}


void EnergyAwareIdealRadio::startTransmission(cPacket *macFrame)
{
  // ASSERT(isOperational);
  if (energyStorage->getResidualCapacity().get() <= 0) {
    // there is no energy to send the frame
    // cancelEvent(endSwitchTimer);
    // completeRadioModeSwitch(RADIO_MODE_OFF);
    return;
  }
  inet::physicallayer::Radio::startTransmission(macFrame);
}

void EnergyAwareIdealRadio::startReception(inet::physicallayer::RadioFrame *radioFrame)
{
  if (energyStorage->getResidualCapacity().get() <= 0) {
    // there is no energy to receive a message
    // cancelEvent(endSwitchTimer);
    // completeRadioModeSwitch(RADIO_MODE_OFF);
    return;
  }
  inet::physicallayer::Radio::startReception(radioFrame);
}

} // namespace broadcasting
