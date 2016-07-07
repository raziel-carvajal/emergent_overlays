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

#include "ewma2.h"
#include "ewmaMsgs_m.h"


#include "inet/networklayer/common/L3AddressResolver.h"
#include "inet/transportlayer/contract/udp/UDPControlInfo.h"
#include "inet/mobility/contract/IMobility.h"

#include <algorithm>
#include <climits>
#include <iostream>
#include <fstream>

using namespace std;
using inet::broadcasting::Broadcast;



namespace inet {

Define_Module(EWMA2);

using namespace ewma;

#define oo INT_MAX
#define nil nil_edge

static fstream log_file;

enum ControlMessageMWST {
    REPEAT_TEST_MSG = 100,
    DISPLAY_TIME_MWST = 101,
    TEST_DELAY = 102,
    CONNECT_DELAY = 103,
    INITIATE_DEALY = 104,
    ACCEPT_DELAY = 105,
    AWAKE_UP_DELAY = 106
};

string
EWMA2::header() {
  return myself + "(" + info_mwst.FN + ", "+ SIMTIME_STR(simTime()) + ")";
}

void
EWMA2::processStart()
{
    BroadcastingAppBase::processStart();
}


void
EWMA2::initialize(int stage)
{
    BroadcastingAppBase::initialize(stage);

    if (! log_file.is_open()) {
      log_file.open("log_file_mwst.txt", fstream::out);
    }

    switch (stage) {
        case INITSTAGE_LAST:
          {
            if (par("spontaneously_awaken").boolValue()) {
              delayed_event(AWAKE_UP_DELAY, "", par("spontaneously_awake_time").doubleValue());
            }

            delayed_event(DISPLAY_TIME_MWST, "", par("mwst_display_time").doubleValue());
          }
          break;
        default:
            break;
    }
}

void
EWMA2::handleMessageWhenUp(cMessage *msg)
{

    if (msg->isSelfMessage()) {
        switch (msg->getKind()) {
          case AWAKE_UP_DELAY:
              if (info_mwst.SN == States::Sleeping ) {
                wakeup();
              }
              cancelAndDelete(msg);
              break;
          case DISPLAY_TIME_MWST:
              {
                  cerr << "Fragment for " << myself << ": FN " << info_mwst.FN << ", SN " << info_mwst.SN << ", test_edge " << info_mwst.test_edge << ", find_count " << info_mwst.find_count << ", connecting_with " << info_mwst.connecting_with << endl;
                  for (auto& n : neighbors) {
                      if (info_mwst.SE[n.first] == EdgeStates::Branch) {
                          cerr << "\t" << n.first << " with weight " << n.second.w << endl;
                      }
                  }
                  cancelAndDelete(msg);
              }
              break;
          case REPEAT_TEST_MSG:
            {
              if (info_mwst.test_edge != nil) {
                send_test(info_mwst.FN, info_mwst.test_edge, true);
              }
            }
            break;
          case TEST_DELAY:
              {
                string dst = string((char*)msg->getContextPointer());
                send_test(info_mwst.FN, dst, true);
                cancelAndDelete(msg);
              }
              break;
          case CONNECT_DELAY:
              {
                  string dst = string((char*)msg->getContextPointer());
                  send_connect(dst, true);
                  cancelAndDelete(msg);
              }
              break;
          case ACCEPT_DELAY:
              {
                  string dst = string((char*)msg->getContextPointer());
                  send_accept(dst, true);
                  cancelAndDelete(msg);
              }
              break;
          case INITIATE_DEALY:
              {
                  string dst = string((char*)msg->getContextPointer());
                  send_initiate(info_mwst.FN, dst, true);
                  cancelAndDelete(msg);
              }
              break;
            default:
              BroadcastingAppBase::handleMessageWhenUp(msg);
            break;
        }
    }
    else BroadcastingAppBase::handleMessageWhenUp(msg);
}


bool
EWMA2::on_network_message_received(cPacket* pkt)
{
  return BroadcastingAppBase::on_network_message_received(pkt) ||
      processMessage2<ConnectMWST>(pkt, &EWMA2::on_connect_received) ||
      processMessage2<InitiateMWST>(pkt, &EWMA2::on_initiate_received) ||
      processMessage2<TestMWST>(pkt, &EWMA2::on_test_received) ||
      processMessage2<AcceptMWST>(pkt, &EWMA2::on_accept_received) ||
      processMessage2<RejectMWST>(pkt, &EWMA2::on_reject_received) ||
      processMessage2<ReportMWST>(pkt, &EWMA2::on_report_received) ||
      processMessage2<ChangeRootMWST>(pkt, &EWMA2::on_change_root_received);
}


template <typename T> bool
EWMA2::processMessage2(cPacket* pkt, void (EWMA2::*action)(const T* msg))
{
    T* t = check_and_cast_nullable<T*>(dynamic_cast<T*>(pkt));
    if (t != nullptr) {
        (this->*action)(t);
        return true;
    }
    else {
        return false;
    }
}



void
EWMA2::on_payload_received(const Broadcast* m) {

    string key = string(m->getId());

    emitBroadcastMsgReceived(key);

    if (!payloads[key].empty()) {
        return;
    }

    // if there is nothing in the mst, fill it
    if (local_mst.size() == 0) {
      for (auto& n : neighbors) {
          if (info_mwst.SE[n.first] == EdgeStates::Branch) {
              local_mst.push_back(n.first);
          }
      }
    }

    payloads[key] = string(m->getPayload());

    // cerr << header() << ": received broadcast message with id " << key << endl;

    emitReceived();

    if (isForwardingNode()) {
        ewma::EWMABroadcast* mmm = (ewma::EWMABroadcast*)m;
        for (uint32_t k = 0 ; k < mmm->getCoveredArraySize() ; ++k) {
            covered[key].insert(string(mmm->getCovered(k)));
        }
        delay_broadcast(strdup(key.c_str()));

    }
}


bool
EWMA2::isForwardingNode()
{
    return is_source || (local_mst.size() > 0);
}


void
EWMA2::send_message(const vector<string>& dst, string& key)
{
    set<string> previous;
    for (auto& d: covered[key]) previous.insert(d);
    for (auto& d : neighbors) {
        covered[key].insert(d.first);
    }

    if (dst.size() > 0 || uniform(0,1) > 0.7) {
        //EV_DEBUG << "====================== Sending in " << myself << "\n";
        //cerr << "====================== Sending in " << myself << "\n";
        vector<string> v;
        for (auto& c : covered[key]) {
            // EV_DEBUG << "\t The following is covered: " << c << "\n";
            // cerr << "\t The following is covered: " << c << "\n";
            v.push_back(c);
        }
        emitSent(key);

        /*only send if some children in the mst are not covered, but send to all uncovered*/
        ewma::EWMABroadcast* m = new ewma::EWMABroadcast("payload");
        m->setSender(myself.c_str());
        m->setId(key.c_str());
        m->setPayload(payloads[key].c_str());
        m->setCoveredArraySize(covered[key].size());

        for (uint32_t i = 0 ; i < v.size() ; i++) {
            m->setCovered(i, v[i].c_str());
        }


        // cerr << header() << ": is retransmiting broadcast message with id " << key << endl;
        send_package(m);
    }
}


void
EWMA2::send_to_uncovered(string& key)
{
    /* send to members of (local_mst - covered) */
    vector<string> v;
    for (auto& d: local_mst) {
        if (covered[key].find(d) == covered[key].end()) {
            v.push_back(d);
        }
    }
    send_message(v, key);
}


void
EWMA2::time_to_broadcast_payload(void* user_data)
{
    BroadcastingAppBase::time_to_broadcast_payload(user_data);

    // if there is nothing in the mst, fill it
    if (local_mst.size() == 0) {
      for (auto& n : neighbors) {
          if (info_mwst.SE[n.first] == EdgeStates::Branch) {
              local_mst.push_back(n.first);
          }
      }
    }

    if (is_source) {
        string key = createUniqueBroadcastingSessionId();
        //cerr << "Broadcasting " <<  key << " in " << myself << " at " << simTime() << endl;
        payloads[key] = " this is the payload, initially sent from " + myself;
        covered[key].insert(myself);
        send_message(local_mst, key);
    }
    else {
        char* s = (char*)user_data;
        string key = string(s);
        //cerr << "Broadcasting key: " << s  << " in " << myself << " at " << simTime() << endl;
        delete s;

        send_to_uncovered(key);
    }
}

void
EWMA2::send_connect(const std::string& j, bool now)
{

    auto it = info_mwst.requesting.find(j);
    if (it != info_mwst.requesting.end()) {
        /*connecting with someone who already sent me connect request */
        info_mwst.SE[j] = EdgeStates::Branch; // no sure
        /* I'm the root */
        info_mwst.parent = nil;
        string new_fragment = info_mwst.create_unique_name(j, myself);
        initiate(new_fragment);

        info_mwst.requesting.erase(it);
    }
    else {
        if (now) {
            info_mwst.SN = States::Connecting;
            info_mwst.connecting_with = j;
            ConnectMWST* pkt = new ConnectMWST("connect");
            pkt->setSender(myself.c_str());
            send_package(pkt, j);
            log_file << "Sending Connect " << myself << " " << j << " " << simTime() <<
                        " " << info_mwst.FN << endl;
        }
        else {
            delayed_event(CONNECT_DELAY, j, uniform(0.01, 0.1));
        }
    }

}


void
EWMA2::send_initiate(const std::string& fragmentId, const std::string& j, bool now)
{
    if (now) {
      InitiateMWST* pkt = new InitiateMWST("initiate");
      pkt->setSender(myself.c_str());
      pkt->setFragmentId(fragmentId.c_str());
      EV_TRACE << "Sending initiate to " << j << "(" << getAddr(j) <<  ") \n";
      send_package(pkt, j);
      log_file << "Sending Initiate " << myself << " " << j << " " << simTime() <<
                  " " << info_mwst.FN << endl;
    }
    else {
        delayed_event(INITIATE_DEALY, j, uniform(0.01, 0.1));
    }
}

void
EWMA2::send_test(const std::string& framentId, const std::string& j, bool now)
{
    if (now) {
      TestMWST* m = new TestMWST((myself + "test").c_str());
      m->setSender(myself.c_str());
      m->setFragmentId(framentId.c_str());
      send_package(m, j);
      // cancelEvent(repeat_test_message);
      // scheduleAt(simTime() + 0.1, repeat_test_message);
      log_file << "Sending Test " << myself << " " << j << " " << simTime() <<
                  " " << info_mwst.FN << endl;
    }
    else {
        delayed_event(TEST_DELAY, j, uniform(0.5, 1.5));
    }
    /* cerr << header() << ": Sending Test message from " << myself << " to " << j << "(" << addresses[j] << "), now = " << now <<  "[" << myself << "[" << simTime() << "[" << j << endl; */

}

void
EWMA2::send_accept(const std::string& j, bool now)
{
    if (now) {
      AcceptMWST* a = new AcceptMWST((string("accept") + myself).c_str());
      a->setSender(myself.c_str());
      send_package(a, j);
      log_file << "Sending Accept " << myself << " " << j << " " << simTime() <<
                    " " << info_mwst.FN << endl;
    }
    else {
        delayed_event(ACCEPT_DELAY, j, uniform(0.1, 0.3));
    }
}


void
EWMA2::wakeup()
{

    cerr << myself << ": This is wakeup in ewma-mwst \n";

    if (info_mwst.SN == States::Sleeping) {
      for (auto& n : neighbors) {
        info_mwst.SE[n.first] = EdgeStates::Basic;
      }
    }

    string m_name = nil;
    double min_value = 10000000.0;
    for (auto& n : neighbors) {
      auto v = n.second;
      if (v.name != myself && v.w < min_value) {
        m_name = v.name;
        min_value = v.w;
      }
    }

    info_mwst.FN = myself;

    if (m_name != nil) {
      info_mwst.SE[m_name] = EdgeStates::Branch;
      info_mwst.SN = States::Found;
      info_mwst.find_count = 0;
      send_connect(m_name, false);
    }
}


void
EWMA2::on_connect_received(const ConnectMWST* msg)
{
    string j = msg->getSender();

    log_file << "Received Connect " << myself << " " << msg->getSender() <<
                " " << simTime() << " " << info_mwst.FN << endl;

    if (info_mwst.SN == States::Sleeping) {
        wakeup();
    }

    if (info_mwst.SN == States::Connecting) {
        if (info_mwst.connecting_with == j) {
            /* perfect, I am connecting with someone who also want to connect with me */
            info_mwst.SE[j] = EdgeStates::Branch; // no sure
            if (myself < j) {
                info_mwst.parent = nil;
                /* I'm the root if my name is smaller */
                string new_fragment = info_mwst.create_unique_name(j, myself);
                initiate(new_fragment);
            }
            info_mwst.connecting_with = nil;

        }
        else {
            /* I am connecting, but someone unexpected want to connect with me */
            /* put it in queue until I am available */
            info_mwst.requesting.insert(j);
        }
    }
    else {
        info_mwst.requesting.insert(j);
    }
}


void
EWMA2::initiate(const std::string& new_fragment_name)
{
    info_mwst.FN = new_fragment_name;

    info_mwst.SN = States::Find;
    info_mwst.bw = oo;
    info_mwst.best_edge = nil;


    for (auto& n : neighbors) {
        auto i = n.first;
        if (info_mwst.parent != i &&
                info_mwst.SE[i] == EdgeStates::Branch) {

            send_initiate( info_mwst.FN , i, false);
            info_mwst.find_count++; // count of children being tested
            info_mwst.finding.insert(i);
        }
    }

    // TODO: we should only send test messages once we have received the response to all initiate message
    // For instance, in the on_report handler
    if (info_mwst.find_count == 0) {
      test();
    }
    else {
      info_mwst.test_step_must_be_called = true;
    }

}


void
EWMA2::on_initiate_received(const InitiateMWST* msg)
{
    /* cerr << header() << ": Initiate Received from " << msg->getSender() << "\n"; */
    log_file << "Received Initiate " << myself << " " << msg->getSender() <<
                " " << simTime() << " " << info_mwst.FN << endl;

    string j = msg->getSender();

    /*
     * When you receive the initiate message you must:
     * 1 - change you fragment name if needed
     * 3 - record my parent in in_branch
     * 4 - go to find state
     * 5 - best-weight = oo
     * 6 - best-edge = nil_edge
     * 7 - be sure that the connection to my parent is a branch
     * 2 - forward the initiate message to all the neighbors in the tree
     * 8 - start testing neighbors that don't belong to the tree to get the shortest edge
     * */

    info_mwst.connecting_with = nil;
    info_mwst.parent = j;
    info_mwst.SE[j] = EdgeStates::Branch;


    initiate(msg->getFragmentId());

}


void
EWMA2::test()
{
    int min_w = oo;
    info_mwst.test_edge = nil;
    for (auto& n : neighbors) {
        auto i = n.first;
        if (info_mwst.SE[i] == EdgeStates::Basic
                && n.second.w < min_w && info_mwst.tested.find(i) == info_mwst.tested.end()) {
            min_w = n.second.w;
            info_mwst.test_edge = i;
        }
    }

    info_mwst.test_step_must_be_called = false;

    if (info_mwst.test_edge != nil_edge) {
            info_mwst.tested.insert(info_mwst.test_edge);
            send_test(info_mwst.FN, info_mwst.test_edge, false);
    }
    else {
        // there is no more neighbors to try. Report to parent
        report();
    }
}


void
EWMA2::on_test_received(const TestMWST* m)
{
    string j = m->getSender();
    /*cerr  << header() << ": Test Received from " << j  << " and id " << m->getFragmentId() << "  [" << myself << "[" << j << "[" << simTime() << endl; */
    log_file << "Received Test " << myself << " " << m->getSender() << " " << simTime() << " " << info_mwst.FN << endl;
    if (info_mwst.SN == States::Sleeping) {
        wakeup();
    }

    if (info_mwst.FN != m->getFragmentId()) {
        // it is a different fragment
        // AcceptMWST* a = new AcceptMWST((string("accept") + myself).c_str());
        // a->setSender(myself.c_str());
        // send_package(a, j);
        send_accept(j, true);
        // log_file << "Sending Accept " << myself << " " << j << " " << simTime() << endl;
    }
    else {
        if (info_mwst.SE[j] == EdgeStates::Basic) {
            info_mwst.SE[j] = EdgeStates::Rejected;
        }

        RejectMWST* a = new RejectMWST("reject");
        a->setSender(myself.c_str());
        send_package(a, j);
        log_file << "Sending Reject " << myself << " " << j << " " << simTime() << " " << info_mwst.FN << endl;
    }
}


void
EWMA2::on_accept_received(const AcceptMWST* m)
{
    string j = m->getSender();

    if (neighbors[j].w < info_mwst.bw) {
        info_mwst.best_edge = j;
        info_mwst.bw = neighbors[j].w;
    }
    /* cerr << header() << ": Accept Received from j = " << j << " best-w: " << bw << "(" << best_edge << ")" << " w[j]: " << w[j] << " find_count: " << find_count<< " in_branch: " << parent <<  "\n"; */
    log_file << "Received Accept " << myself << " " << m->getSender() << " " << simTime() << " " << info_mwst.FN << endl;
    if (info_mwst.find_count) {
      for (auto f : info_mwst.finding) {
        cerr << "\t" << f << endl;
      }
    }
    // if (j == info_mwst.test_edge) cancelEvent(repeat_test_message);
    test(); // TODO: try this change in the previous version
}


void
EWMA2::on_reject_received(const RejectMWST* m)
{
    string j = m->getSender();
    /* cerr << header() << ": Reject Received from " << j << "\n"; */
    log_file << "Received Reject " << myself << " " << m->getSender() << " " << simTime() << " " << info_mwst.FN << endl;

    if (info_mwst.SE[j] == EdgeStates::Basic) {

        info_mwst.SE[j] = EdgeStates::Rejected;
    }
    // if (j == info_mwst.test_edge) cancelEvent(repeat_test_message);
    test();
}


void
EWMA2::report()
{
    if (info_mwst.find_count) {
        for (auto n: info_mwst.finding) {
            EV_TRACE << "\t\t\t" << n << "\n";
        }
    }
    if (info_mwst.parent != nil_edge) {
        if (info_mwst.find_count == 0 && info_mwst.test_step_must_be_called) {
          test();
        }
        else if (info_mwst.find_count == 0 && info_mwst.test_edge == nil) {
            info_mwst.tested.clear();
            info_mwst.SN = States::Found;
            ReportMWST* a = new ReportMWST("report");
            a->setSender(myself.c_str());
            a->setWeight(info_mwst.bw);
            send_package(a, info_mwst.parent);
            log_file << "Sending Report " << myself << " " << info_mwst.parent <<
                        " " << simTime() << " " << info_mwst.FN << endl;
        }
    }
    else {
      if (info_mwst.find_count == 0 && info_mwst.test_step_must_be_called) {
        test();
      }
      else if (info_mwst.find_count == 0 && info_mwst.test_edge == nil_edge) {
        /* it is the root */
        info_mwst.tested.clear();
        if (info_mwst.bw < oo)
            change_root();
        else {
            cerr << header() << ": HALTTTTTT "  << "\n";
        }
      }
    }
}


void
EWMA2::on_report_received(const ReportMWST* m)
{
    double ww = m->getWeight();
    string j = m->getSender();

    log_file << "Received Report " << myself << " " << m->getSender() << " " << simTime() << " " << info_mwst.FN << endl;

    info_mwst.find_count --;
    info_mwst.finding.erase(j);
    if (ww < info_mwst.bw) {
        info_mwst.bw = ww;
        info_mwst.best_edge = j;
    }
    report();
}


void
EWMA2::change_root()
{
    if (info_mwst.SE[info_mwst.best_edge] == EdgeStates::Branch) {
        ChangeRootMWST* m = new ChangeRootMWST("change root");
        m->setSender(myself.c_str());
        send_package(m, info_mwst.best_edge);
        log_file << "Sending ChangeRoot " << myself << " " << info_mwst.best_edge <<
                " " << simTime() << " " << info_mwst.FN << endl;
    }
    else {
        cerr << header() << " : Connecting to " << info_mwst.best_edge << ", SE[best_edge] = " <<
                  info_mwst.SE[info_mwst.best_edge] << endl;
        send_connect(info_mwst.best_edge, false);
    }
}


void
EWMA2::on_change_root_received(const ChangeRootMWST* msg)
{
    cerr << header() << ": change root Received from " << msg->getSender() << "\n";
    log_file << "Received ChangeRoot " << myself << " " << msg->getSender() <<
                " " << simTime() << " " << info_mwst.FN << endl;
    change_root();
}


} //namespace
