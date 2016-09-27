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
  // Remove comment while using Omnet IDE
   //startTransmission(macFrame);

  // Remove comment to compile at InfoCom repository
  inet::physicallayer::Radio::startTransmission(macFrame);
  if (energyStorage->getResidualCapacity().get() <= 0) {
    // there is no energy to send the frame
    // cancelEvent(endSwitchTimer);
    // completeRadioModeSwitch(RADIO_MODE_OFF);
    delete macFrame;
    return;
  }
}

void EnergyAwareIdealRadio::startReception(inet::physicallayer::RadioFrame *radioFrame)
{
  // Remove comment while using Omnet IDE
   //startReception(radioFrame);
  // Remove comment to compile at InfoCom repository
  inet::physicallayer::Radio::startReception(radioFrame);
  if (energyStorage->getResidualCapacity().get() <= 0) {
    // there is no energy to receive a message
    // cancelEvent(endSwitchTimer);
    // completeRadioModeSwitch(RADIO_MODE_OFF);
    delete radioFrame;
    return;
  }
}

} // namespace broadcasting
