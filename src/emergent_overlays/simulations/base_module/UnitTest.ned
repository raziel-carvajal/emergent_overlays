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

package emergent_overlays.simulations.base_module;

import inet.physicallayer.idealradio.IdealRadioMedium;
//import inet.physicallayer.ieee80211.packetlevel.Ieee80211RadioMedium;
//import inet.physicallayer.ieee80211.packetlevel.Ieee80211ScalarRadioMedium;
import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import emergent_overlays.tunned_modules.Cellphone;

import inet.common.lifecycle.LifecycleController;


network UnitTest
{
    @display("bgb=500,500");
    submodules:
        lifecycleController: LifecycleController;
        radioMedium: IdealRadioMedium;
        //        radioMedium: Ieee80211ScalarRadioMedium;
        //        radioMedium: Ieee80211RadioMedium;
        configurator: IPv4NetworkConfigurator;
        host1: Cellphone {
            @display("p=123,293;r=75");
        }
        host2: Cellphone {
            @display("p=186,286;r=75");
        }
}
