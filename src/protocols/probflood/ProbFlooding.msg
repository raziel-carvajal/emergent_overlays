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
cplusplus{{
	#include "broadcasting/BroadcastingAppBase_m.h"
	typedef std::map<std::string, std::string> NeigsMap;
}}

packet inet::broadcasting::Broadcast;
namespace inet::probflood;
class noncobject NeigsMap;
//
// TODO generated message class
//
packet ProbFlooBroadcast extends broadcasting::Broadcast {
    NeigsMap senderNeigs;
}
