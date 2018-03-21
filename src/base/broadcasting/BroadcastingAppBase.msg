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

namespace inet::broadcasting;


cplusplus{{
  #include <set>
  typedef std::set<std::string> TargetSet;
}}

class noncobject TargetSet;

packet Hello {
  string sender;
	double x;
	double y;
	string protocolId;	//protocol ID
}

packet Broadcast {
  string id;			// this is broadcast message ID
  string sender;
  string payload;
  string protocolId;	//protocol ID
}

packet Border {
  string sender;
  // QUESTION: is it important to keep track of the decider?
  // string decider;      // node that chose the border node
  string srcProtocol;  // protocol of the sender
  string chosenNode;   // border node
  string foreignProtocol;
  int hopTL;
}
