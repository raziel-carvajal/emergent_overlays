## Energy consumption model

To model the power consumption we are using a model provided by the developers of *INET/OMNET++*. In this model, the different physical elements involved in wireless communication are represented. This short explanation is based on the [INET tutorial](https://omnetpp.org/doc/inet/api-current/tutorials/wireless/step8.html). I will quote some paragraphs.

> In a real system, there are energy consumers like the radio, and energy sources like a battery or the mains. In the INET model of the radio, energy consumption is represented by a separate component. This **energy consumption model maps the activity of the core parts of the radio (the transmitter and the receiver) to power (energy) consumption. The core parts of the radio themselves do not contain anything about power consumption, they only expose their state variables**. This allows one to switch to arbitrarily complex (or simple) power consumption models, without affecting the operation of the radio. The energy consumption model can be specified in the *energyConsumerType* parameter of the Radio module.

In our experiments, we are using a consumption model called *StateBasedEnergyConsumer*.

> *StateBasedEnergyConsumer* models radio power consumption based on states like radio mode, transmitter and receiver state. Each state has a constant power consumption that can be set by a parameter. Energy use depends on how much time the radio spends in a particular state.

In other words, the radio consumes energy due to two electronic components: the receiver and the transmitter. The radio model has two variables representing the working state of each electronic component. For instance, the transmission state can be:

- TRANSMISSION_STATE_UNDEFINED: the transmission state is undefined or meaningless. (e.g. the radio mode is off, sleep or receiver).
- TRANSMISSION_STATE_IDLE: the radio is not transmitting a signal on the radio medium. (e.g. the last transmission has been completed).
- TRANSMISSION_STATE_TRANSMITTING: the radio medium is busy, the radio is currently transmitting a signal.

while the reception state can be:

- RECEPTION_STATE_UNDEFINED: the radio medium state is unknown, reception state is meaningless, signal detection is not possible.
- RECEPTION_STATE_IDLE: the radio medium is free, no signal is detected.
- RECEPTION_STATE_BUSY: the radio medium is busy, a signal is detected but it is not strong enough to receive.
- RECEPTION_STATE_SYNCHRONIZING: he radio medium is busy, a signal strong enough to evaluate is detected, whether the signal is noise or not is not yet decided.
- RECEPTION_STATE_RECEIVING: the radio medium is busy, a signal strong enough to receive is detected.

> *StateBasedEnergyConsumer* expects the consumption in various states to be specified in watts in parameters like sleep­PowerConsumption, receiverBusy­PowerConsumption, transmitterTransmitting­PreamblePowerConsumption and so on.

## How we use the model?

No source code, just configuration:

```
# Set up a model for the energy consumption of the nodes
**.energyConsumerType = "StateBasedEnergyConsumer"
*.host*.wlan[0].radio.energyConsumer.offPowerConsumption = 0mW
*.host*.wlan[0].radio.energyConsumer.sleepPowerConsumption = 1mW
*.host*.wlan[0].radio.energyConsumer.switchingPowerConsumption = 1mW
*.host*.wlan[0].radio.energyConsumer.receiverIdlePowerConsumption = 2mW
*.host*.wlan[0].radio.energyConsumer.receiverBusyPowerConsumption = 5mW
*.host*.wlan[0].radio.energyConsumer.receiverReceivingPowerConsumption = 10mW
*.host*.wlan[0].radio.energyConsumer transmitterIdlePowerConsumption = 2mW
*.host*.wlan[0].radio.energyConsumer.transmitterTransmittingPowerConsumption = 350mW

# model of energy storage (we don't care)
*.host*.energyStorageType = "IdealEnergyStorage"
```
