## Energy consumption model

To model the power consumption we are using a mechanism provided in *INET/OMNET++*. In this model, the different physical elements involved in wireless communication are represented. As explained in the [INET tutorial](https://omnetpp.org/doc/inet/api-current/tutorials/wireless/step8.html):

> In a real system, there are energy consumers like the radio, and energy sources like a battery or the mains. In the INET model of the radio, energy consumption is represented by a separate component. This **energy consumption model maps the activity of the core parts of the radio (the transmitter and the receiver) to power (energy) consumption. The core parts of the radio themselves do not contain anything about power consumption, they only expose their state variables**. This allows one to switch to arbitrarily complex (or simple) power consumption models, without affecting the operation of the radio. The energy consumption model can be specified in the *energyConsumerType* parameter of the Radio module.

So each node has three components:
1. A radio that is the entity consuming energy
2. A model of how the radio consumes energy
3. A model of how energy source

In our experiments, we are using a consumption model called *StateBasedEnergyConsumer*. As energy source model we use an *IdealEnergyStorage* that has infinite amount of energy and provides a value representing the energy consumed during a period of time (in joules).

> *StateBasedEnergyConsumer* models radio power consumption based on states like radio mode, transmitter and receiver state. Each state has a constant power consumption that can be set by a parameter. Energy use depends on how much time the radio spends in a particular state.

In other words, the radio consumes energy due to two electronic components: the receiver and the transmitter. So the power consumption is represented by the following function:

C(t) = C_receiver(t) + C_transmitter(t)         (1)

Below we describe how are computed the functions *C_receiver* and *C_transmitter*.

The radio model has two variables representing the working state of each electronic component. The transmission state changes over time and it can be:

- TRANSMISSION_STATE_UNDEFINED: the transmission state is undefined or meaningless. (e.g. the radio mode is off, sleep or receiver).
- TRANSMISSION_STATE_IDLE: the radio is not transmitting a signal on the radio medium. (e.g. the last transmission has been completed).
- TRANSMISSION_STATE_TRANSMITTING: the radio medium is busy, the radio is currently transmitting a signal.

while the reception state, which also change over time, can be:

- RECEPTION_STATE_UNDEFINED: the radio medium state is unknown, reception state is meaningless, signal detection is not possible.
- RECEPTION_STATE_IDLE: the radio medium is free, no signal is detected.
- RECEPTION_STATE_BUSY: the radio medium is busy, a signal is detected but it is not strong enough to receive.
- RECEPTION_STATE_SYNCHRONIZING: he radio medium is busy, a signal strong enough to evaluate is detected, whether the signal is noise or not is not yet decided.
- RECEPTION_STATE_RECEIVING: the radio medium is busy, a signal strong enough to receive is detected.

In using *StateBasedEnergyConsumer*, we must specify what is the consumption, in watts, when the radio receiver and transmitter are in different states. For instance:

State|Consumption
-----|-----------
RECEPTION_STATE_IDLE | 1 mW
RECEPTION_STATE_BUSY | 5 mW
RECEPTION_STATE_SYNCHRONIZING | 10 mW
RECEPTION_STATE_RECEIVING | 40 mW
TRANSMISSION_STATE_IDLE | 1 mW
TRANSMISSION_STATE_TRANSMITTING | 70 mW

The values of *C_receiver* and *C_transmitter* at time *t0* is equal to the power consumption of receiver and transmitter of the state they were at *t0*.
For instance, let's use the previous table and say that the receiver is in RECEPTION_STATE_IDLE during 3 seconds, from 0s to 3s, and in RECEPTION_STATE_RECEIVING from 3s to 4s. Then:

C_receiver(2.5) = 1mW

C_receiver(3.4) = 40mW

That's why we must know the state of both the receiver and transmitter all the time.

To compute the energy consumption (in joules) during the whole experiment we simply integrate (1) over time.

Example (four seconds scenario):

State| Time in the state
---- | -----------------
RECEPTION_STATE_IDLE | 3s
RECEPTION_STATE_RECEIVING | 1s
TRANSMISSION_STATE_IDLE | 1s
TRANSMISSION_STATE_TRANSMITTING | 3s

EnergyConsumed = 3s * 1mW + 1s * 40mW + 1s * 1mW + 3s * 70mW

EnergyConsumed = 0.003 + 0.040 + 0.001 + 0.21 J = 0.254 J

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

## Why there is only a tiny difference among protocols?

In the experiments we have been executing we noticed that the number of nodes retransmitting broadcast messages has "*little*" impact on the chart of energy consumed.
To investigate the cause of this, we performed the following experiment: we measure for how long the radio of a relay node is on each state and we compare such values to a non relay node.

These measurements were collected using the log system of OMNET++. For each node, it creates two vectors that indicate when the state of receiver and transmitter changed their state. (see [relay's receiver](), [relay's transmitter](), [non-relay's receiver]() and [non-relay's transmitter]()).

Some parameters of this experiment are shown below:

```
**.energyConsumerType = "StateBasedEnergyConsumer"
*.host*.wlan[0].radio.energyConsumer.offPowerConsumption = 0mW
*.host*.wlan[0].radio.energyConsumer.sleepPowerConsumption = 1mW
*.host*.wlan[0].radio.energyConsumer.switchingPowerConsumption = 1mW
*.host*.wlan[0].radio.energyConsumer.receiverIdlePowerConsumption = 2mW
*.host*.wlan[0].radio.energyConsumer.receiverBusyPowerConsumption = 5mW
*.host*.wlan[0].radio.energyConsumer.receiverReceivingPowerConsumption = 10mW
*.host*.wlan[0].radio.energyConsumer transmitterIdlePowerConsumption = 2mW
*.host*.wlan[0].radio.energyConsumer.transmitterTransmittingPowerConsumption = 350mW

*.host*.udpApp[0].nr_broadcast_msg = 300

*.host*.udpApp[0].intervalBroadcastTime = 0.1s
```

Notice that we are using 300 broadcast sessions, and sending them at a periodic interval of 0.1s. You may also notice that the power consumption during transmission is relatively high (350 mW).

The results are as follow for the relay node:

State | Time in State | Energy used
------|---------------|-------------
RECEPTION_STATE_IDLE | 56.2502s | 0.1125 J
RECEPTION_STATE_RECEIVING | 0.1635s | 0.0016 J
TRANSMISSION_STATE_IDLE | 56.3183s | 0.1126 J
TRANSMISSION_STATE_TRANSMITTING | 0.0721s | 0.0252 J

Total consumption: 0.2520 J

From this table we can conclude a few things:

1. With 300 broadcast messages the time spent retransmitting is a tiny fraction of the total time -- far less than 1 %.
2. Most of the time is spent in idle state, both for receiver and transmitter.
3. Transmission only impacts consumption if it is relatively high.

The results are as follow for the non-relay node:

State | Time in State | Energy used
------|---------------|-------------
RECEPTION_STATE_IDLE | 56.1557s | 0.1123 J
RECEPTION_STATE_RECEIVING | 0.2347s | 0.0023 J
TRANSMISSION_STATE_IDLE | 50.8565s | 0.1017 J
TRANSMISSION_STATE_TRANSMITTING | 0.0063s | 0.0022 J

Total consumption: 0.2186 J

As can be seen, this node consumes less energy. However, the difference with the relay node is really small. 
