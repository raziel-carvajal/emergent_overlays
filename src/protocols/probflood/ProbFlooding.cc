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

Define_Module(ProbFlooding);

void ProbFlooding::on_payload_received(const broadcasting::Broadcast* m) {
    double probability = 0.0; bool doRetransmission = false;
    NeigsMap toDel;
    std::string key = string(m->getPayload());
    if (string(m->getSender()) == myself) return;
    cout << getLogHeader() << "KEY_RECEPTION " << key << " FROM_PEER " << string(m->getSender()) << endl;
    emitBroadcastMsgReceived(key);
    if (alreadyDispatched.find(key) != alreadyDispatched.end()) return;
    probflood::ProbFlooBroadcast* msg = (probflood::ProbFlooBroadcast*) m;
    mtx.lock();
    for (auto& n: neighbors) {
        if (n.second.w > 0.0)
            toDel[n.first] = n.first;
    }
    for (auto& old: toDel)
        neighbors.erase(old.first);
    mtx.unlock();
    switch(scheme) {
    case DENSITY_AWARE:
        if (neighbors.size() == 0.0) {
            doRetransmission = false;
        } else {
            probability = k / neighbors.size();
            cout << getLogHeader() << "Probability: " << probability << endl;
            doRetransmission = probability >= probLim ? true : false;
        }
        break;
    case BORDER_AWARE:
        doRetransmission = doDensityAndBorderAwareScheme(msg->getSenderNeigs(), false);
        break;
    case DENSITY_BORDER_AWARE:
        doRetransmission = doDensityAndBorderAwareScheme(msg->getSenderNeigs(), true);
        break;
    case DENSITY_BORDER_AWARE_NEIGS_ELIMINATION:
        mtx.lock();
        if (broadcastTable.find(key) == broadcastTable.end())
            broadcastTable[key] = msg->getSenderNeigs();
        else {
            for (auto &n: msg->getSenderNeigs()) {
                if (broadcastTable[key].find(n.first) != broadcastTable[key].end())
                    broadcastTable[key].erase(n.first);
            }
        }
        mtx.unlock();
        doRetransmission = doDensityAndBorderAwareScheme(msg->getSenderNeigs(), true);
        if (!doRetransmission) {
//            cout << getLogHeader() << "Doing delayed broadcast for key " << key << " and T: " << T << endl;
            delayed_broadcast(key, T);
        }
        break;
    }
    mtx.lock();
    for (auto& n: neighbors) n.second.w = n.second.w + 1.0;
    mtx.unlock();
    if (doRetransmission) {
        NeigsMap myNeigs;
        mtx.lock();
        for (auto& n1: neighbors) myNeigs[n1.first] = n1.first;
        mtx.unlock();
        probflood::ProbFlooBroadcast* newMsg = new probflood::ProbFlooBroadcast("payload");
        newMsg->setSenderNeigs(myNeigs);
        alreadyDispatched[key] = key;
        broadcast(key, newMsg);
    }
}

void inet::ProbFlooding::time_to_broadcast_payload(void* user_data) {
    string key;
    NeigsMap myNeigs;
    mtx.lock();
    for (auto& n: neighbors) myNeigs[n.first] = n.first;
    mtx.unlock();
    probflood::ProbFlooBroadcast* msg = new probflood::ProbFlooBroadcast("payload");
    msg->setSenderNeigs(myNeigs);
    if (is_source) {
        key = createUniqueBroadcastingSessionId();
        alreadyDispatched[key] = key;
        broadcast(key, msg);
    } else {
        key = string((char*) user_data);
        if (!broadcastTable[key].empty() && alreadyDispatched.find(key) == alreadyDispatched.end()) {
//            cout << getLogHeader() << "Broadcasting with neigs elim for key: " << key << endl;
            alreadyDispatched[key] = key;
            broadcast(key, msg);
        } else
            cout << getLogHeader() << "broadcast table is empty or key already dispatched: " << key  << endl;
    }
}

void ProbFlooding::on_hello_received(const broadcasting::Hello* msg) {
    if (myself == msg->getSender())
        return;
//    cout << getLogHeader() << "HELLO from: " << msg->getSender() << endl;
    string senderStr = msg->getSender();
    mtx.lock();
    if (neighbors.find(senderStr) == neighbors.end()) {
        Neighbor node;
        node.name = senderStr;
        node.addr = getAddr(msg->getSender());
        node.pos.x = msg->getX();
        node.pos.y = msg->getY();
        node.w = 0.0;
        neighbors[node.name] = node;
    } else {
        neighbors[senderStr].addr = getAddr(msg->getSender());
        neighbors[senderStr].pos.x= msg->getX();
        neighbors[senderStr].pos.y= msg->getY();
        neighbors[senderStr].w = 0.0;
    }
    mtx.unlock();
}

bool ProbFlooding::doDensityAndBorderAwareScheme(NeigsMap senderNeigs, bool both) {
    mtx.lock();
    int neigSize = neighbors.size();
    mtx.unlock();
    string src[neigSize];
    string dest[senderNeigs.size()];
//    string tmp = "";
//    for (auto& n: senderNeigs) {
//        dest[i] = n.first;
//        tmp += n.first + ", ";
//        i++;
//    }
//    cout << getLogHeader() << "DST neighbrs: " << tmp << endl;
//    tmp = "";
//    i = 0;
//    mtx.lock();
//    for (auto& n: neighbors) {
//        src[i] = n.first;
//        tmp += n.first + ", ";
//        i++;
//    }
//    mtx.unlock();
//    cout << getLogHeader() << "SRC neighbrs: " << tmp << endl;
    double Na, Nb, Nc = 0.0;
    vector<string> v( math::max(senderNeigs.size(), neigSize) );
    vector<string>::iterator it = set_difference(
            src, src + neigSize, dest, dest + senderNeigs.size(), v.begin());
    v.resize(it - v.begin());
    Na = v.size(); v.empty();
//    cout << getLogHeader() << "SRC / DST size: " << Na << endl;
    it = set_difference(
            dest, dest + senderNeigs.size(), src, src + neigSize, v.begin());
    v.resize(it - v.begin());
    Nb = v.size(); v.empty();
//    cout << getLogHeader() << "DST / SRC size: " << Nb << endl;
    it = set_intersection(
            src, src + neigSize, dest, dest + senderNeigs.size(), v.begin());
    v.resize(it - v.begin());
    Nc = v.size();
//    cout << getLogHeader() << "DST intersection SRC size: " << Nc << endl;
    double mu = Nb / (Na + Nc);
//    cout << getLogHeader() << "Mu: " << mu << endl;
    double probability;
    if (both)
        probability = pow(mu, sigma)*(k/neigSize - alpha)/(pow(M, sigma)) + alpha;
    else
        probability = pow(mu, sigma)*(A - alpha)/(pow(M, sigma)) + alpha;
    cout << getLogHeader() << "Probability: " << probability << endl;
    return probability >= probLim ? true : false;
}

bool ProbFlooding::handleNodeStart(IDoneCallback* doneCallback) {
    map<string, int> enumMap;
    enumMap["DENSITY_AWARE"] = DENSITY_AWARE;
    enumMap["BORDER_AWARE"] = BORDER_AWARE;
    enumMap["DENSITY_BORDER_AWARE"] = DENSITY_BORDER_AWARE;
    enumMap["DENSITY_BORDER_AWARE_NEIGS_ELIMINATION"] = DENSITY_BORDER_AWARE_NEIGS_ELIMINATION;
    if (enumMap.find(par("scheme").stdstringValue()) == enumMap.end()) {
        cerr << getLogHeader() << "Unknown scheme policy, stopping simulation.";
        endSimulation();
    }
    scheme= enumMap[par("scheme").stdstringValue()];
    A     = par("A").doubleValue();
    k     = par("k").doubleValue();
    alpha = par("alpha").doubleValue();
    sigma = par("sigma").doubleValue();
    miTreb= par("miTreb").doubleValue();
    maTreb= par("maTreb").doubleValue();
    probLim=par("probLi").doubleValue();
    T = miTreb + maTreb * uniform(0.0, 1.0);
    return BroadcastingAppBase::handleNodeStart(doneCallback);
}

}
