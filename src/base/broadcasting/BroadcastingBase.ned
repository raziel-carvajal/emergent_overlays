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

package broadcasting;

//
// Some nodes distribute messages in the network using unicast UDP.
//

simple BroadcastingBase
{
    parameters:
        // you know, we are talking about networking here
        int remotePort = default(10000);
        int localPort = default(10000);

        // section defining parameters used to identify my neighbors
        double maximumDelay @unit(s) = default(0.5s);
        double helloTime @unit(s) = default(0.8s); // delay between hello messages
        bool nr_hello_messages = default(false); // how many delay messages

        // say if this node is the source of a broadcast
        bool is_source = default(false);
        bool single_source = default(false);
        int nr_broadcast_msg = default(is_source? 1:0);
        double wakeUpTime @unit(s) = default(3s);
        double intervalBroadcastTime @unit(s) = default(0.5s);

        // maybe there is some information to show
        double display_time @unit(s) = default(5s); // at this point we must show the built MWST

        volatile double delay_test @unit(s) = default(uniform(0s,0.05s));

        xml protocolsConfig; // xml containing the full configuration for every broadcast protocol

        // Adaptation parameters
        double adaptationMax @unit(s) = default(0.15s);
        bool withAdaptation = default(false);
        string protocolId = default("");
        int nr_max_custom_officers = default(1);
        double timeoutCustomOfficer @unit(s) = default(0.2s);

        @statistic[msg_received](title="A node receive a message";record=vector; source=msg_received);
        @statistic[msg_sent](title="The node sends the message";record=vector;source=msg_sent);
		@statistic[broadcast_msg_received](title="a message was received again"; record=vector; source=broadcast_msg_received);

   gates:
        input udpIn @labels(UDPControlInfo/up);
        output udpOut @labels(UDPControlInfo/down);
}
