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

package mpr_t2;

import inet.applications.contract.IUDPApp;
import broadcasting.BroadcastingBase;

//
//
// Some nodes distribute messages in the network using unicast UDP.
//
simple Mpr_t2 extends BroadcastingBase like IUDPApp
{
    parameters:
        @class(inet::Mpr_t2);
        int buildMprCounter = default(10);
        double builtMprTimeout @unit(s) = default(3.0s);

		double wakeup_time_to_build_hops @unit(s) = default(5s);
		bool build_hops = default(false);

		double display_time_hops @unit(s) = default(100s);

		int hops_required = default(1);

}
