## Energy consumption model

> In a real system, there are energy consumers like the radio, and energy sources like a battery or the mains. In the INET model of the radio, energy consumption is represented by a separate component. This energy consumption model maps the activity of the core parts of the radio (the transmitter and the receiver) to power (energy) consumption. The core parts of the radio themselves do not contain anything about power consumption, they only expose their state variables. This allows one to switch to arbitrarily complex (or simple) power consumption models, without affecting the operation of the radio. The energy consumption model can be specified in the *energyConsumerType* parameter of the Radio module.

> Here, we set the energy consumption model in the node radios to *StateBasedEnergyConsumer*. *StateBasedEnergyConsumer* models radio power consumption based on states like radio mode, transmitter and receiver state. Each state has a constant power consumption that can be set by a parameter. Energy use depends on how much time the radio spends in a particular state.

> To go into a little bit more detail: the radio maintains two state variables, receive state and transmit state. At any given time, the radio mode (one of off, sleep, switching, receiver, transmitter and transciever) decides which of the two state variables are valid. The receive state may be idle, busy, or receiving, the former two referring to the channel state. When it is receiving, a sub-state stores which part of the signal it is receiving: the preamble, the (physical layer) header, the data, or any (we don't know/care). Similarly, the transmit state may be idle or transmitting, and a sub-state stores which part of the signal is being transmitted (if any).

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
