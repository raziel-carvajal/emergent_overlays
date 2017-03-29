#ifndef __INET_BROADCASTING_BASE_H_
#define __INET_BROADCASTING_BASE_H_

#include <omnetpp.h>

#include <map>
#include <vector>
#include <string>
#include <queue>
#include <set>
#include <functional>

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
    //Unique (there aren't two nodes with the same delta) number of milliseconds that every node
    //set (according to its node identifier) to send control messages
    double delta;
    // how many hello messages I must send
    int nr_hello_msg;
    class Neighbor {
      public:
          std::string name;
          L3Address addr;
          Coord pos;
          double w;
    };

    std::string getLogHeader();

    enum ControlMessageTypes {
        IDLE,
        START,
        SAY_HELLO,
        WAKEUP,
        DISPLAY_TIME,
        BROADCAST_DELAY,
        HALT_SIMULATION_DELAY,
        PRINT_POS_NEIGS,
        TRANSFORMATION_TIMEOUT,
        LAST_POWER_REPORT,

        First = IDLE,
        Last = LAST_POWER_REPORT
    };

  protected:

    // is the source of a broadcast
    bool is_source;

    // number of broadcast message to send
    double nr_broadcast_msg;

    // when to send broadcast messages
    std::set<int> msgs;
    std::set<int>::iterator next_to_send;

    // my direct edges (neighbors)
    std::map<std::string, Neighbor> neighbors;

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

    double adaptationMax;
    bool withAdaptation;
    std::string protocolId;

    //Payloads
    std::map<std::string, std::string> adaptForeigsMsgs;
    std::map<std::string, std::string> adaptMyProtoMsgs;
    std::map<std::string, cMessage*> timeoutMsgs;

  private:

    // control messages
    cMessage* ctrlDisplayTime = nullptr;


    /* signals used to record statistics */
    simsignal_t signal_received_id;
    simsignal_t signal_sent_id;
    simsignal_t signal_power_level;
    simsignal_t signal_broadcast_msg_received;

    bool already_configured = false;



    bool allowing_control_messages = true;

  protected:

    virtual void configure_neighbors();

    virtual int numInitStages() const override { return NUM_INIT_STAGES; }
    virtual void initialize(int stage) override;
    virtual void handleMessageWhenUp(cMessage *msg) override;
    virtual void on_hello_received(const broadcasting::Hello* msg);

    virtual bool handleNodeStart(IDoneCallback *doneCallback) override;

    virtual void processStart();

    virtual void broadcast(std::string key, broadcasting::Broadcast* msg);

    template <typename T> bool
  	processMessage(cPacket* pkt, std::function<void(const T*)> action)
  	{
  		T* t = check_and_cast_nullable<T*>(dynamic_cast<T*>(pkt));
  		if (t != nullptr) {
  			action(t);
  		    return true;
  		}
  		else {
  		    return false;
  		}
  	}


    virtual inet::broadcasting::Hello* build_hello_message();
    virtual void on_payload_received(const broadcasting::Broadcast* m); // you must ALWAYS redefine (overwrite) this one
    virtual bool on_network_message_received(cPacket* pkt); // This nasty one must be defined if your protocol is using other type of messages (percolator)

    virtual void time_to_broadcast_payload(void* user_data); // it is called sometime after you call delayed_broadcast

    void emitSent(std::string value); // important. you should use it. log data (statistics in vector)
    void emitReceived(); // this is automatic (don't call it)
    void emitPowerLevel(double value); // (don't call it)
    void emitBroadcastMsgReceived(std::string value); // important. you should use it. log data (statistics in vector)

    L3Address getAddr(std::string id);

    void delay_broadcast(void* user_data);
    cMessage* delayed_broadcast(const std::string& key, double delay); // call this one in the implementation of on_payload_received. it is like a Timer that will be called after 'delay' seconds
    cMessage* delayed_event(int type, const std::string& key, double delay);
    void delayed_event_with_strict_time(int type, const std::string& key, double delay);


    int get_next_id_for_msg();
    int get_last_id_for_msg();
    std::string createUniqueBroadcastingSessionId();

    void send_package(cPacket* m, std::string dst); // send a package to a particular devices given its host name

    void send_package(cPacket* m); // send a package to all nearby devices

    void forbid_control_messages() { allowing_control_messages = false; }
    bool are_control_messages_allowed() { return allowing_control_messages; }

    double get_random_delay() { return uniform(0.03, 0.1); }

    void log_status_for_animation(std::string status);

    void updatePosition();
    void printBroadcastingLog (std::string key);

    double computeAdaptTimeout();

    bool msgReceived(const broadcasting::Broadcast* m);

  public:
    BroadcastingAppBase();

};

} //namespace

#endif
