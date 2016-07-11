#ifndef __INET_EWMA_H_
#define __INET_EWMA_H_

#include <omnetpp.h>

#include <map>
#include <vector>
#include <string>
#include <queue>
#include <set>

#include "inet/common/INETDefs.h"
#include "inet/common/ModuleAccess.h"
#include "inet/common/geometry/common/Coord.h"


#include "inet/applications/base/ApplicationBase.h"
#include "inet/transportlayer/contract/udp/UDPSocket.h"



#include "broadcasting/BroadcastingAppBase_m.h"
#include "broadcasting/BroadcastingAppBase.h"

#include "ewmaMsgs_m.h"

namespace inet {


class INET_API EWMA2 : public BroadcastingAppBase
{
  private:

    const std::string nil_edge = "";

    enum States {
        Sleeping,
        Find,
        Found,
        Connecting
    };

    enum EdgeStates {
        Basic, Branch, Rejected
    };

    class MWSTInfo {
    public:
      // state of this node in the protocol
      States SN = States::Sleeping;

      // fragment identity
      std::string FN;

      // best weight
      int bw;

      // best edge
      std::string best_edge;

      // test edge
      std::string test_edge;

      // iteration of test
      bool test_step_must_be_called = false;

      // in-branch
      std::string parent = "";

      // find-count
      int find_count;

      // set of nodes were I am finding
      std::set< std::string > finding;

      // list of nodes trying to connect with me
      std::set<std::string> requesting;

      // set of already tested neighbors
      std::set< std::string > tested;

      //
      std::string connecting_with;

      // the state of each edge
      std::map<std::string, EdgeStates> SE;

      // for each neighbor, last fragment name you are aware of
      std::map<std::string, std::string> known_names;

      std::string create_unique_name(const std::string& a1, const std::string& a2)
      {
          if (a1 <= a2) {
              return a1 + " <-> " + a2;
          }
          else {
              return a2 + " <-> " + a1;
          }
      }

    };

    MWSTInfo info_mwst;

    // mst of this node for this broadcast FIXME: use the implementation of MWST
    std::vector<std::string> local_mst;

    std::map< std::string, std::string >  payloads;

    std::map< std::string, std::set<std::string> > covered;

    // apply spontaneously wakeup
    bool spontaneously_awaken;

    virtual void initialize(int stage) override;
    virtual void handleMessageWhenUp(cMessage *msg) override;

    bool isForwardingNode();

    virtual void on_payload_received(const broadcasting::Broadcast* m) override;
    virtual bool on_network_message_received(cPacket* pkt);
    virtual void time_to_broadcast_payload(void* user_data) override;

    void send_message(const std::vector<std::string>& dst, std::string& key);
    void send_to_uncovered(std::string& key);

    /* processing MWST messages */
    void on_connect_received(const ewma::ConnectMWST* msg);
    void on_initiate_received(const ewma::InitiateMWST* msg);
    void on_report_received(const ewma::ReportMWST* msg);
    void on_change_root_received(const ewma::ChangeRootMWST* msg);
    void on_in_new_fragment_received(const ewma::InNewFragment* msg);

    void wakeup();
    void initiate(const std::string& new_fragment_name);
    void test();
    void report();
    void change_root();

    void send_connect(const std::string& j, bool now);
    void send_initiate(const std::string& fragmentId, const std::string& j, bool now);


    // FIXME : this is crap
    template <typename T> bool processMessage2(cPacket* pkt, void (EWMA2::*action)(const T* msg));

    std::string header();

  protected:


    virtual void processStart() override;
};

} //namespace

#endif
