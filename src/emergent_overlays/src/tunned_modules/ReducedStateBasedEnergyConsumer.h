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

#ifndef REDUCEDSTATEBASEDENERGYCONSUMER_H_
#define REDUCEDSTATEBASEDENERGYCONSUMER_H_

#include <inet/power/contract/IEnergyConsumer.h>
#include <inet/power/contract/IEnergySource.h>
#include <inet/physicallayer/contract/packetlevel/IRadio.h>

using namespace inet::power;
using namespace inet::physicallayer;

class ReducedStateBasedEnergyConsumer : public cSimpleModule, public IEnergyConsumer, public cListener {

	protected:
		W offPowerConsumption;
		W sleepPowerConsumption;
		W switchingPowerConsumption;

		W receiverIdlePowerConsumption;
		W receiverBusyPowerConsumption;
		W receiverReceivingPowerConsumption;

		W transmitterIdlePowerConsumption;
		W transmitterTransmittingPowerConsumption;

		// environment
		IRadio *radio;
		IEnergySource *energySource;

		// internal state
		int energyConsumerId;

		virtual int numInitStages() const override {
			return inet::NUM_INIT_STAGES;
		}
		virtual void initialize(int stage) override;

		virtual void receiveSignal(cComponent *source, simsignal_t signalID, long value) override;

	public:
		ReducedStateBasedEnergyConsumer();

		virtual W getPowerConsumption() const override;


};

#endif /* REDUCEDSTATEBASEDENERGYCONSUMER_H_ */
