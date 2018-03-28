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

package fullyAdaptive;

import inet.applications.contract.IUDPApp;
import broadcasting.BroadcastingBase;

simple FullyAdaptive extends BroadcastingBase like IUDPApp
{
    parameters:
        string protocolId = default("");
        bool withAdaptation = default(false);

        // message translation mechanism
        int hop_to_live = default(2);
        int bootstrap_ctrl_msgs_no = default(2);

        // adaptation mechanism
        int density_threshold_lower = default(15);
        int density_threshold_upper = default(15);
        string initialProtocol;
        
        //integer value to define adaptation policy where:
        //	0: LOCAL
        //	1: SWSP
        //	2: DENSITY_AREA
        int adaptation_policy = default(0);
        double centerDensAx = default(50.0);
        double centerDensAy = default(50.0);
        double denseAreaWid = default(100.0);
        double adapTimer @unit(s) = default(0.5s);
        
        //ground truth
        double deltaApprox @unit(s) = default(1.0s);
        
        @class(inet::FullyAdaptive);
        @statistic[protocol_change](title="The protocol has change"; record=vector; source=protocol_change);
}
