#ifndef __INET_BROADCASTING_BASE_H_
#define __INET_BROADCASTING_BASE_H_

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

#include "BroadcastingAppBase_m.h"


namespace inet {


class INET_API BroadcastingAppBase : public ApplicationBase , public cListener
{
  public:

  // how many hello messages I must send
  int nr_hello_msg;
  cMessage* ctrlMsg0 = nullptr;
  class Neighbor {
    public:
        std::string name;
        L3Address addr;
        Coord pos;
        double w;
    };
  protected:
    enum ControlMessageTypes {
        IDLE,
        START,
        SAY_HELLO,
        WAKEUP,
        DISPLAY_TIME,
        BROADCAST_DELAY,
        FLOODING_DELAY
    };


    // is the source of a broadcast
    bool is_source;

    // number of broadcast message to send
    double nr_broadcast_msg;

    // my direct edges (neighbors)
    std::map<std::string, Neighbor> neighbors;

    /* a hack to avoid the problem of two messages being lost when they are send at the same time to the same device */
    std::queue<cMessage*> old_msgs;

    // communication
    int remote_port = 10000;
    int local_port = 10000;
    UDPSocket socket;

    // myself as a module
    std::string myself;
    L3Address myAddress;
    // my position
    Coord position;
    double radious;

    // counter to assign ids to broadcast messages
    int last_id = 0;

    // keep all the payloads for flooding
    std::map<std::string, std::string> payload_in_flooding;

  private:

    // control messages
    cMessage* ctrlDisplayTime = nullptr;


    /* signals used to record statistics */
    simsignal_t signal_received_id;
    simsignal_t signal_sent_id;
    simsignal_t signal_power_level;
    simsignal_t signal_broadcast_msg_received;

    bool already_configured = false;

    void configure_neighbors();

    void on_hello_received(const broadcasting::Hello* msg);

  protected:

    /* dond't touch these */
    virtual int numInitStages() const override { return NUM_INIT_STAGES; }
    virtual void initialize(int stage) override;
    virtual void handleMessageWhenUp(cMessage *msg) override;
    virtual void finish() override;

    virtual bool handleNodeStart(IDoneCallback *doneCallback) override;
    virtual bool handleNodeShutdown(IDoneCallback *doneCallback) override;
    virtual void handleNodeCrash() override;

    virtual void processStart();

    template <typename K>
    class Action {
      void task(BroadcastingAppBase*, K*);
    };
    template <typename T> bool processMessage(cPacket* pkt, void (BroadcastingAppBase::*action)(const T* msg));

    virtual void on_payload_received(const broadcasting::Broadcast* m); // you must ALWAYS redefine (overwrite) this one
    virtual void on_flooding_received(const broadcasting::FloodingMessage* m);
    virtual bool on_network_message_received(cPacket* pkt); // This nasty one must be defined if your protocol is using other type of messages (percolator)

    virtual void time_to_broadcast_payload(void* user_data); // it is called sometime after you call delayed_broadcast

    void emitSent(std::string value); // important. you should use it. log data (statistics in vector)
    void emitReceived(); // this is automatic (don't call it)
    void emitPowerLevel(double value); // (don't call it)
    void emitBroadcastMsgReceived(std::string value); // important. you should use it. log data (statistics in vector)
    virtual void receiveSignal(cComponent *source, simsignal_t signalID, double value) override;

    L3Address getAddr(std::string id);

    void delay_broadcast(void* user_data);
    void delayed_broadcast(const std::string& key, double delay); // call this one in the implementation of on_payload_received. it is like a Timer that will be called after 'delay' seconds
    void delayed_event(ControlMessageTypes type, const std::string& key, double delay);

    int get_next_id_for_msg();
    int get_last_id_for_msg();
    std::string createUniqueBroadcastingSessionId();

    void initiateFlooding(std::string payload);

    void send_package(cPacket* m, std::string dst); // send a package to a particular devices given its host name

    void send_package(cPacket* m); // send a package to all neirby devices

  public:
    BroadcastingAppBase();

};

} //namespace

#endif
