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

#include <probflood/ProbFlooding.h>
namespace inet {

Register_Class(ProbFlooding);


bool
ProbFlooding::handle(const cMessage *msg)
{
	if (msg->getKind() == refresh_hops_message) {
		erase_old_hops();
		return true;
	}
	return false;
}


void
ProbFlooding::on_saying_hello()
{
	gateway->delayed_event(refresh_hops_message, "", get_random_delay());
}


void
ProbFlooding::erase_old_hops()
{
  for (auto& n : neighbors)
    n.second.w++;

  set<string> to_del;
  int rounds_to_wait = 3;
  for (const auto& n: neighbors)
    if (n.second.w >= rounds_to_wait)
      to_del.insert(n.first);

  for (auto& old: to_del)
    neighbors.erase(old);

  // cout << getLogHeader() << "trying to erase" << endl;
}



void ProbFlooding::process_payload(const broadcasting::Broadcast* m) {
		if (string(m->getSender()) == myself) return;
    double probability = 0.0;
    bool doRetransmission = false;
    NeigsMap toDel;
    std::string key = string(m->getPayload());
    // cout << getLogHeader() << "KEY_RECEPTION " << key << " FROM_PEER " << string(m->getSender()) << endl;
    gateway->emitBroadcastMsgReceived(key);
    if (alreadyDispatched.find(key) != alreadyDispatched.end()) return;
    probflood::ProbFlooBroadcast* msg = (probflood::ProbFlooBroadcast*) m;
    switch(scheme) {
    case DENSITY_AWARE:
        if (neighbors.size() == 0.0) {
            doRetransmission = false;
            // cout << getLogHeader() << "NOOOOOOOOOOOOOOOOOOOOOOO=============================: " << endl;
        } else {
            probability = k / neighbors.size();
            // cout << getLogHeader() << "Probability 111: " << probability << endl;
            doRetransmission = probability >= probLim;
        }
        break;
    case BORDER_AWARE:
        doRetransmission = doDensityAndBorderAwareScheme(msg->getSenderNeigs(), false);
        break;
    case DENSITY_BORDER_AWARE:
        doRetransmission = doDensityAndBorderAwareScheme(msg->getSenderNeigs(), true);
        break;
    case DENSITY_BORDER_AWARE_NEIGS_ELIMINATION:
        if (broadcastTable.find(key) == broadcastTable.end())
            broadcastTable[key] = msg->getSenderNeigs();
        else {
            for (auto &n: msg->getSenderNeigs()) {
                if (broadcastTable[key].find(n.first) != broadcastTable[key].end())
                    broadcastTable[key].erase(n.first);
            }
        }
        doRetransmission = doDensityAndBorderAwareScheme(msg->getSenderNeigs(), true);
        if (!doRetransmission) {
//            cout << getLogHeader() << "Doing delayed broadcast for key " << key << " and T: " << T << endl;
            gateway->delayed_broadcast(key, T);
        }
        break;
    }
    for (auto& n: neighbors) n.second.w = n.second.w + 1.0;
    if (doRetransmission) {
        NeigsMap myNeigs;
        for (auto& n1: neighbors) myNeigs[n1.first] = n1.first;
        probflood::ProbFlooBroadcast* newMsg = new probflood::ProbFlooBroadcast("payload");
        newMsg->setSenderNeigs(myNeigs);
        alreadyDispatched.insert(key);
        gateway->broadcast(key, newMsg);
    }
}

void ProbFlooding::time_to_broadcast_payload(void* user_data) {
    string key;
    NeigsMap myNeigs;
    for (auto& n: neighbors) myNeigs[n.first] = n.first;
    probflood::ProbFlooBroadcast* msg = new probflood::ProbFlooBroadcast("payload");
    msg->setSenderNeigs(myNeigs);
    if (!user_data) {
        key = gateway->createUniqueBroadcastingSessionId();
        alreadyDispatched.insert(key);
        gateway->broadcast(key, msg);
    } else {
        key = string((char*) user_data);
        if (!broadcastTable[key].empty() && alreadyDispatched.find(key) == alreadyDispatched.end()) {
//            cout << getLogHeader() << "Broadcasting with neigs elim for key: " << key << endl;
            alreadyDispatched.insert(key);
            gateway->broadcast(key, msg);
        } else {
					// cout << getLogHeader() << "broadcast table is empty or key already dispatched: " << key  << endl;

				}
    }
}

void ProbFlooding::process_hello(const broadcasting::Hello* msg) {
    if (myself == msg->getSender())
        return;
//    cout << getLogHeader() << "HELLO from: " << msg->getSender() << endl;
    string senderStr = msg->getSender();
    if (neighbors.find(senderStr) == neighbors.end()) {
        Neighbor node;
        node.name = senderStr;
        node.addr = gateway->getAddr(msg->getSender());
        node.pos.x = msg->getX();
        node.pos.y = msg->getY();
        node.w = 0.0;
        neighbors[node.name] = node;
    } else {
        neighbors[senderStr].addr = gateway->getAddr(msg->getSender());
        neighbors[senderStr].pos.x= msg->getX();
        neighbors[senderStr].pos.y= msg->getY();
        neighbors[senderStr].w = 0.0;
    }
}

bool ProbFlooding::doDensityAndBorderAwareScheme(NeigsMap senderNeigs, bool both) {
    int neigSize = neighbors.size();
    set<string> src;
    set<string> dest;
   for (auto& n: senderNeigs) {
		 dest.insert(n.first);
   }
   for (auto& n: neighbors) {
		 src.insert(n.first);
   }
  //  cout << getLogHeader() << "SRC neighbrs:" << endl;
    double Na, Nb, Nc = 0.0;
    vector<string> v;
    set_difference(src.begin(), src.end(), dest.begin(), dest.end(), inserter(v, v.begin()));
    Na = v.size();
    v.clear();
  //  cout << getLogHeader() << "SRC / DST size: " << Na << endl;
    set_difference(dest.begin(), dest.end(), src.begin(), src.end(), inserter(v, v.begin()));
    Nb = v.size();
    v.clear();
  //  cout << getLogHeader() << "DST / SRC size: " << Nb << endl;
    set_intersection(src.begin(), src.end(), dest.begin(), dest.end(), inserter(v, v.begin()));
    Nc = v.size();
    v.clear();
  //  cout << getLogHeader() << "DST intersection SRC size: " << Nc << endl;
    double mu = Nb / (Na + Nc);
  //  cout << getLogHeader() << "Mu: " << mu << endl;
    double probability;
    if (both)
        probability = pow(mu, sigma)*(k/neigSize - alpha)/(pow(M, sigma)) + alpha;
    else
        probability = pow(mu, sigma)*(A - alpha)/(pow(M, sigma)) + alpha;

		cout << pow(mu, sigma)*(A - alpha)/(pow(M, sigma)) << pow(mu, sigma) << pow(M, sigma) << endl;
    // cout << getLogHeader() << "Probability: " << probability << " probLim=" << probLim << endl;
    return probability >= probLim;
}


void ProbFlooding::initialize(const std::string& node_name, const std::shared_ptr<IBroadcastGateway> gateway)
{
	BroadcastProtocolAdapter::initialize(node_name, gateway);
	map<string, int> enumMap;
	enumMap["DENSITY_AWARE"] = DENSITY_AWARE;
	enumMap["BORDER_AWARE"] = BORDER_AWARE;
	enumMap["DENSITY_BORDER_AWARE"] = DENSITY_BORDER_AWARE;
	enumMap["DENSITY_BORDER_AWARE_NEIGS_ELIMINATION"] = DENSITY_BORDER_AWARE_NEIGS_ELIMINATION;
	if (enumMap.find(gateway->get_parameter<string>(protocol_name, "scheme")) == enumMap.end()) {
		throw std::runtime_error("Unknown scheme policy, stopping simulation.");
	}
	scheme= enumMap[gateway->get_parameter<string>(protocol_name, "scheme")];
	A     = gateway->get_parameter<double>(protocol_name, "A");
	k     = gateway->get_parameter<double>(protocol_name, "k");
	alpha = gateway->get_parameter<double>(protocol_name, "alpha");
	sigma = gateway->get_parameter<double>(protocol_name, "sigma");
	miTreb= gateway->get_parameter<double>(protocol_name, "miTreb");
	maTreb= gateway->get_parameter<double>(protocol_name, "maTreb");
	probLim=gateway->get_parameter<double>(protocol_name, "probLi");
	T = miTreb + maTreb * uniform(0.0, 1.0);

	refresh_hops_message = gateway->register_new_control_message();
}

}
