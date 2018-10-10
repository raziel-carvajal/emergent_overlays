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

package emergent_overlays.tunned_modules;

import inet.physicallayer.energyconsumer.StateBasedEnergyConsumer;

simple ReducedStateBasedEnergyConsumer extends StateBasedEnergyConsumer
{
    offPowerConsumption @unit(W) = default(0W);
    sleepPowerConsumption @unit(W) = default(0.001W);
    switchingPowerConsumption @unit(W) = default(0W);
    
    receiverIdlePowerConsumption @unit(W) = default(0.001W);
    receiverBusyPowerConsumption @unit(W) = default(0W);
    receiverReceivingPowerConsumption @unit(W) = default(0.010mW);
    
    transmitterIdlePowerConsumption @unit(W) = default(0.001W);
    transmitterTransmittingPowerConsumption @unit(W) = default(0.100W);
    @class(ReducedStateBasedEnergyConsumer);
}
