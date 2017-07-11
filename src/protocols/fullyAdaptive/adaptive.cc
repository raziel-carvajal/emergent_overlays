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

#include "adaptive.h"


#include "inet/mobility/contract/IMobility.h"

#include <algorithm>
#include <cmath>
#include <vector>

using namespace std;
using inet::broadcasting::Broadcast;

namespace inet {

Define_Module(FullyAdaptive);


void
FullyAdaptive::handleMessageWhenUp(cMessage *msg)
{
  if (monitor) {
    // TO RAZIEL: Ok, no entiendo por que no te gusta esta linea.
    // O quizas si lo entiendo, es que el return no estaba explicito
    // mi idea es la siguiente: el monitor devuelve verdadero si
    // consume el mensaje. Ponerlo aqui es util porque asi el monitor puede
    // usar self-messages para controlar su funcionamiento interno.
    // Por ejemplo, al mover esta linea, haces que el sniffer monitor deje
    // de funcionar.

    bool result = monitor->handle_messages(msg);
    if (result) return;
  }
  if (msg->isSelfMessage()) {
    // detect if the message is handled by the protocols
    switch (msg->getKind()) {
      case START:
        BroadcastingAppBase::handleMessageWhenUp(msg);
        break;
      case SAY_HELLO:
        {
          //XXX this variable is not declared in any other scope, I comment it!
          // temporary_check --;
          //if (temporary_check > 0 && gateway->get_parameter<bool>(current_protocol_name, "nr_hello_messages")) {
          if (gateway->get_parameter<bool>(current_protocol_name, "nr_hello_messages")) {
            auto p = build_hello_message();
            if (packet_to_piggybag) {
              p->encapsulate(packet_to_piggybag);
              packet_to_piggybag = nullptr;
            }
            gateway->send_package(p);
            gateway->delayed_event(SAY_HELLO, "helloTime", gateway->get_parameter<double>(current_protocol_name, "helloTime"));
            knownProtocols[current_protocol_name]->on_saying_hello();
          }
          cancelAndDelete(msg);
        }
      break;
      case HALT_SIMULATION_DELAY:
        emit(signal_protocol_change, 'E');
        BroadcastingAppBase::handleMessageWhenUp(msg);
      break;
      // TO RAZIEL: Esto es lo que de verdad no me gusta.
      // No me gusta proque tiene un problema conceptual:
      // Estas guardando la posicion del nodo en el instance de tiempo T,
      // y la densidad aproximada en el instante de tiempo T + deltaApprox.
      // Observa que eso es un problema con movilidad: simplemente porque es imposible decir
      // si la diferencia entre la densidad observada (la que calculamos con el monitor)
      // y la densidad esperada (la que calculamos usando la posicion) se debe a:
      // un error en el monitor o a que los nodos se movieron y por tanto la densidad cambio.
      // En otras palabras, tenemos que guardar las posiciones y la aproximacion de la densidad exactamente
      // en el mismo instante de tiempo. Y tenemos que hacerlo en el instante de tiempo en que
      // la densidad aproximada se usa para hacer algo (adaptacion)

      // case PRINT_POSITION:
      // {
      //     Coord p = gateway->get_current_position();
      //     gateway->emitNodePosition(p.x, p.y);
      //     cancelAndDelete(msg);
      //     gateway->delayed_event(PRINT_POSITION, "useful to compute nodes' density", par("intervalBroadcastTime").doubleValue());
      //     gateway->delayed_event(APPROXIMATE_DENSITY, "density approximation", deltaApprox);
      // }
      // break;
      // case APPROXIMATE_DENSITY:
      // {
      //     monitor->compute_density_approx();
      //     gateway->emitDensityApproximation(monitor->get_density_approx());
      // }
      // break;
      default:
      	{
          auto initialProtocol = par("initialProtocol").stdstringValue();
          if (/*withAdaptation  &&*/ msg->getKind() == DO_ADAPTATION && initialProtocol != "middleware") {
            adaptation();
            cancelAndDelete(msg);
          }
      		else if (!knownProtocols[current_protocol_name]->handle(msg)) {
	          BroadcastingAppBase::handleMessageWhenUp(msg);
	        }
	        else {
	          cancelAndDelete(msg);
	        }
        }
      break;
    }
  }
  else if (msg->getKind() == UDP_I_DATA) {
    // TO RAZIEL, como te decia, esta linea debe ir al principio para que
    // todos los tipos de monitoreo funcionen.
    // Por supuesto, eso complica un poco el monitoreo, pero no demasiado
    // monitor->handle_messages(msg);

    auto pkt = PK(msg);
    auto initialProtocol = par("initialProtocol").stdstringValue();
  	if (initialProtocol != "middleware") {
	    if (pkt->hasEncapsulatedPacket()) {
	      pkt = pkt->getEncapsulatedPacket();
	    }
	    auto willing = dynamic_cast<inet::WillingToChange*>(pkt);
	    if (willing) {
	      if (willingToChange &&
	          willing->getTargetProtocol() == willingToChangeToProtocol &&
	          willingToChangeToProtocol != current_protocol_name) {

	        change_current_protocol(willingToChangeToProtocol);
	        std::cerr << "CHANGING PROTOCOL TO\t\t\t" << willingToChangeToProtocol << '\n';

	        if (!packet_to_piggybag) {
	          packet_to_piggybag = new inet::WillingToChange("willing to change");
	          packet_to_piggybag->setSender(myself.c_str());
	          packet_to_piggybag->setTargetProtocol(willingToChangeToProtocol.c_str());
	          if (!gateway->get_parameter<bool>(current_protocol_name, "nr_hello_messages")) {
	            gateway->send_package(packet_to_piggybag);
	            packet_to_piggybag = nullptr;
	          }
	        }
	        willingToChangeToProtocol = "";
	        willingToChange = false;
	        willing = nullptr;
	      }
	    }
    }
    BroadcastingAppBase::handleMessageWhenUp(msg);
  }

}


void
FullyAdaptive::adaptation()
{
  // TO RAZIEL: aqui es donde creo se debe guardar todo, porque aqui es donde usamos la densidad para algo
  // (ademas, esto facilita muchisimo el script R)
  monitor->compute_density_approx();
  auto density = monitor->get_density_approx();
  Coord p = gateway->get_current_position();

  gateway->emitDensityApproximation(density);
  gateway->emitNodePosition(p.x, p.y);

  gateway->delayed_event(DO_ADAPTATION, "adaptation self message", 0.1);
  if (!withAdaptation) return;

  const string dense_region_protocol = gateway->get_parameter<string>("AdaptiveBase", "dense_region");
  const string sparse_region_protocol = gateway->get_parameter<string>("AdaptiveBase", "sparse_region");
  if (policy == AdaptationPolicy::LOCAL) {
    if (density > density_threshold_upper && current_protocol_name != dense_region_protocol) {
      change_current_protocol(dense_region_protocol);
    }
    else if (density < density_threshold_lower && current_protocol_name != sparse_region_protocol) {
      change_current_protocol(sparse_region_protocol);
    }
  }
  else if (policy == AdaptationPolicy::SWSP) {
    bool change = false;
    if (density > density_threshold_upper && current_protocol_name != dense_region_protocol) {
      willingToChange = true;
      willingToChangeToProtocol = dense_region_protocol;
      change = true;
    }
    else if (density < density_threshold_lower && current_protocol_name != sparse_region_protocol) {
      willingToChange = true;
      willingToChangeToProtocol = sparse_region_protocol;
      change = true;
    }
    if (change && !packet_to_piggybag) {
      packet_to_piggybag = new inet::WillingToChange("willing to change");
      packet_to_piggybag->setSender(myself.c_str());
      packet_to_piggybag->setTargetProtocol(willingToChangeToProtocol.c_str());
      if (!gateway->get_parameter<bool>(current_protocol_name, "nr_hello_messages")) {
        gateway->send_package(packet_to_piggybag);
        packet_to_piggybag = nullptr;
      }
    }
  }
}


void
FullyAdaptive::on_payload_received(const Broadcast* m) {
  knownProtocols[current_protocol_name]->process_payload(m);
}

void
FullyAdaptive::time_to_broadcast_payload(void* user_data)
{
  knownProtocols[current_protocol_name]->time_to_broadcast_payload(user_data);
}


void
FullyAdaptive::on_hello_received(const broadcasting::Hello* msg)
{
  knownProtocols[current_protocol_name]->process_hello(msg);
}


void
FullyAdaptive::change_current_protocol(const std::string& protocol)
{
  current_protocol_name = protocol;
  gateway->setProtocolId(current_protocol_name);

  emit(signal_protocol_change, current_protocol_name[0]);

  if (gateway->get_parameter<bool>(current_protocol_name, "nr_hello_messages")) {
    int n = std::stoi (myself.substr(5, myself.size()));
    auto delta = (n % 50 == 0)? 0.003 : ((n % 50) * 0.002);
    auto t = gateway->get_parameter<double>(current_protocol_name, "helloTime") + delta;
    gateway->delayed_event(SAY_HELLO, "helloTime", t);
  }
}


void
FullyAdaptive::processStart()
{
  BroadcastingAppBase::processStart();

  signal_protocol_change = this->registerSignal("protocol_change");

  // DO_ADAPTATION = gateway->register_new_control_message();
  gateway->delayed_event(DO_ADAPTATION, "adaptation self message", 0.1);
  std::string monitoring_class("inet::SnifferBasedMonitoring");
  monitor = std::unique_ptr<IMonitoringMechanism>(dynamic_cast<IMonitoringMechanism*>(createOne(monitoring_class.c_str())));
  monitor->initialise(gateway);

  auto initialProtocol = par("initialProtocol").stdstringValue();
  if (withAdaptation && initialProtocol != "middleware") {
//    DO_ADAPTATION = gateway->register_new_control_message();
    // TO RAZIEL: esta linea la habia movido, cuidado al resolver los conflictos
    // gateway->delayed_event(DO_ADAPTATION, "adaptation self message", 0.1);


    density_threshold_lower = par("density_threshold_lower").longValue();
    density_threshold_upper = par("density_threshold_upper").longValue();

    // TO RAZIEL: no creo que sea necesario
    // deltaApprox = par("deltaApprox").doubleValue();

    policy = AdaptationPolicy::LOCAL;
    if (par("adaptation_policy").stdstringValue() == "swsp") {
      policy = AdaptationPolicy::SWSP;
    }
  }

  auto protocols = { "Flooding2", "Mpr_t2", "Abba2" };
  for (const auto& p: protocols) {
    current_protocol_name = p;
    auto current_protocol = dynamic_cast<IBroadcastProtocol*>(createOne(std::string("inet::" + current_protocol_name).c_str()));
    if (!current_protocol) {
      throw std::runtime_error("Couldn't create instance of class inet::" + current_protocol_name);
    }
    current_protocol->set_protocol_name(current_protocol_name);
    // initialize protocol
    current_protocol->initialize(myself, gateway);
    knownProtocols.emplace(current_protocol_name, std::unique_ptr<IBroadcastProtocol>(current_protocol));
  }

  if (initialProtocol == "middleware") {
  	auto pos = gateway->get_current_position();
    if (pos.x >= 81 && pos.x <= 169 && pos.y >= 81 && pos.y <= 169) {
      initialProtocol = "Mpr_t2";
    }
    else {
      initialProtocol = "Flooding2";
    }
  }

  change_current_protocol(initialProtocol);
}


inet::broadcasting::Hello*
FullyAdaptive::build_hello_message()
{
  auto m = knownProtocols[current_protocol_name]->build_hello_message();
  m->setX(gateway->get_current_position().x);
  m->setY(gateway->get_current_position().y);
  m->setProtocolId (current_protocol_name.c_str());
  return m;
}

} //namespace
