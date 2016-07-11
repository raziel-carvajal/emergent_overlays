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
cplusplus{{
    #include "broadcasting/BroadcastingAppBase.h"
    typedef inet::BroadcastingAppBase::Neighbor *NePo; 
}};

namespace inet::mpr_t2;

class noncobject NePo;

packet Neighbors {
	string neighbors[];
	int hopLevels[];
	double xs[];
	double ys[];
	int maxHopLevel;
	string sender;
	double x;
	double y;
}

// Used to request the hops of a node
// the max_hop_value must be >= 0
packet RequestNeighbors {
	string sender;
	int maxHopLevel;
	double x;
	double y;
}

packet MprFound {
	string sender;
	string inMpr[];
}
