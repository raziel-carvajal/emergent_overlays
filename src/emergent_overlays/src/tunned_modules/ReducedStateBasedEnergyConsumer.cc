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

#include <tunned_modules/ReducedStateBasedEnergyConsumer.h>
#include <inet/common/ModuleAccess.h>

Define_Module(ReducedStateBasedEnergyConsumer);

void ReducedStateBasedEnergyConsumer::receiveSignal(cComponent* source, simsignal_t signalID, long value) {
	energySource->setPowerConsumption(energyConsumerId, getPowerConsumption());
}

ReducedStateBasedEnergyConsumer::ReducedStateBasedEnergyConsumer() {
	offPowerConsumption = W(NaN);
	sleepPowerConsumption = W(NaN);
	switchingPowerConsumption = W(NaN);

	receiverIdlePowerConsumption = W(NaN);
	receiverBusyPowerConsumption = W(NaN);
	receiverReceivingPowerConsumption = W(NaN);

	transmitterIdlePowerConsumption = W(NaN);
	transmitterTransmittingPowerConsumption = W(NaN);

	radio = nullptr;
	energySource = nullptr;
	energyConsumerId = -1;
}

void ReducedStateBasedEnergyConsumer::initialize(int stage) {
	cSimpleModule::initialize(stage);
	EV << "Initializing StateBasedEnergyConsumer, stage = " << stage << endl;
	if (stage == inet::INITSTAGE_LOCAL) {
		offPowerConsumption = W(par("offPowerConsumption"));
		sleepPowerConsumption = W(par("sleepPowerConsumption"));
		switchingPowerConsumption = W(par("switchingPowerConsumption"));

		receiverIdlePowerConsumption = W(par("receiverIdlePowerConsumption"));
		receiverBusyPowerConsumption = W(par("receiverBusyPowerConsumption"));
		receiverReceivingPowerConsumption = W(par("receiverReceivingPowerConsumption"));

		transmitterIdlePowerConsumption = W(par("transmitterIdlePowerConsumption"));
		transmitterTransmittingPowerConsumption = W(par("transmitterTransmittingPowerConsumption"));

		cModule *radioModule = getParentModule();
		radioModule->subscribe(IRadio::radioModeChangedSignal, this);
		radioModule->subscribe(IRadio::receptionStateChangedSignal, this);
		radioModule->subscribe(IRadio::transmissionStateChangedSignal, this);
//		radioModule->subscribe(IRadio::receivedSignalPartChangedSignal, this);
//		radioModule->subscribe(IRadio::transmittedSignalPartChangedSignal, this);
		radio = check_and_cast<IRadio *>(radioModule);
		const char *energySourceModule = par("energySourceModule");
		energySource = dynamic_cast<IEnergySource *>(getModuleByPath(energySourceModule));
		if (!energySource)
			throw cRuntimeError("Cannot find power source");
		energyConsumerId = energySource->addEnergyConsumer(this);
	}

}

W ReducedStateBasedEnergyConsumer::getPowerConsumption() const {
	inet::physicallayer::IRadio::RadioMode radioMode = radio->getRadioMode();

	if (radioMode == inet::physicallayer::IRadio::RADIO_MODE_OFF)
		return offPowerConsumption;
	else if (radioMode == inet::physicallayer::IRadio::RADIO_MODE_SLEEP)
		return sleepPowerConsumption;
	else if (radioMode == inet::physicallayer::IRadio::RADIO_MODE_SWITCHING)
		return switchingPowerConsumption;

	inet::W powerConsumption = inet::W(0);
	inet::physicallayer::IRadio::ReceptionState receptionState = radio->getReceptionState();
	inet::physicallayer::IRadio::TransmissionState transmissionState = radio->getTransmissionState();
	if (radioMode == inet::physicallayer::IRadio::RADIO_MODE_RECEIVER) {
		if (receptionState == inet::physicallayer::IRadio::RECEPTION_STATE_IDLE)
			powerConsumption += receiverIdlePowerConsumption;
		else if (receptionState == inet::physicallayer::IRadio::RECEPTION_STATE_BUSY)
			powerConsumption += receiverBusyPowerConsumption;
		else if (receptionState == inet::physicallayer::IRadio::RECEPTION_STATE_RECEIVING) {
			auto part = radio->getReceivedSignalPart();
			if (part == IRadioSignal::SIGNAL_PART_NONE) {
//				;
//			else if (part == inet::physicallayer::IRadioSignal::SIGNAL_PART_WHOLE)
//				;
//			else if (part == inet::physicallayer::IRadioSignal::SIGNAL_PART_PREAMBLE)
//				;
//			else if (part == inet::physicallayer::IRadioSignal::SIGNAL_PART_HEADER)
//				;
			}
			else if (part == IRadioSignal::SIGNAL_PART_DATA)
				powerConsumption += receiverReceivingPowerConsumption;
			else
				throw cRuntimeError("Unknown received signal part");
		}
		else if (receptionState != inet::physicallayer::IRadio::RECEPTION_STATE_UNDEFINED)
			throw cRuntimeError("Unknown radio reception state");
	}
	else if (radioMode == inet::physicallayer::IRadio::RADIO_MODE_TRANSMITTER) {
		if (transmissionState == inet::physicallayer::IRadio::TRANSMISSION_STATE_IDLE)
			powerConsumption += transmitterIdlePowerConsumption;
		else if (transmissionState == inet::physicallayer::IRadio::TRANSMISSION_STATE_TRANSMITTING) {
			auto part = radio->getTransmittedSignalPart();
			if (part == IRadioSignal::SIGNAL_PART_NONE){
//				;
//			else if (part == inet::physicallayer::IRadioSignal::SIGNAL_PART_WHOLE)
//				;
//			else if (part == inet::physicallayer::IRadioSignal::SIGNAL_PART_PREAMBLE)
//				;
//			else if (part == inet::physicallayer::IRadioSignal::SIGNAL_PART_HEADER)
//				;
			}else if (part == IRadioSignal::SIGNAL_PART_DATA)
				powerConsumption += transmitterTransmittingPowerConsumption;
			else
				throw cRuntimeError("Unknown transmitted signal part");
		}
		else if (transmissionState != inet::physicallayer::IRadio::TRANSMISSION_STATE_UNDEFINED)
			throw cRuntimeError("Unknown radio transmission state");
	}
	return powerConsumption;
}
