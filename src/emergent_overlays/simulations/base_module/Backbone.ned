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
import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import inet.common.lifecycle.LifecycleController;
import emergent_overlays.tunned_modules.Cellphone;



network Backbone
{
    @display("bgb=500,500");
    submodules:
        lifecycleController: LifecycleController;
        radioMedium: IdealRadioMedium;
        configurator: IPv4NetworkConfigurator;
        host1: Cellphone {
            @display("p=209,213;r=75");
        }
        host2: Cellphone {
            @display("p=269,213;r=75");
        }
        host3: Cellphone {
            @display("p=321,213;r=75");
        }
        host4: Cellphone {
            @display("p=361,159;r=75");
        }
        host5: Cellphone {
            @display("p=351,262;r=75");
        }
        host6: Cellphone {
            @display("p=173,167;r=75;is=s");
        }
        host7: Cellphone {
            @display("p=177,262;r=75");
        }
}
