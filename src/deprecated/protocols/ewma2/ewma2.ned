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

package ewma2;

import inet.applications.contract.IUDPApp;

import broadcasting.BroadcastingBase;

//
// This module is an application that implement the EWMA protocol
// to disseminate messages.
//
// Some nodes distribute messages in the network using unicast/broadcast UDP.
//
simple EWMA2 extends BroadcastingBase like IUDPApp
{
    parameters:

        // parameters describing a round
        int T_max @unit(s) = default(0.6s);
        int T_prob @unit(s) = default(T_max/3);
        int T_corr @unit(s) = default(T_max/3);
        int T_act @unit(s) = default(T_max/3);

        bool spontaneously_awaken = default(true);

        double spontaneously_awake_time @unit(s) = default(maximumDelay*(nr_hello_messages + 1));

        double mwst_display_time @unit(s) = default(80s); // at this point we must show the built MWST

        @class(inet::EWMA2);
}
