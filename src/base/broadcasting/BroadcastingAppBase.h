#ifndef __INET_BROADCASTING_BASE_H_
#define __INET_BROADCASTING_BASE_H_

#include <omnetpp.h>

#include <map>
#include <vector>
#include <string>
#include <queue>
#include <set>
#include <functional>
#include <memory>

#include "inet/common/INETDefs.h"
#include "inet/common/ModuleAccess.h"
#include "inet/common/geometry/common/Coord.h"


#include "inet/applications/base/ApplicationBase.h"
#include "inet/transportlayer/contract/udp/UDPSocket.h"

#include "BroadcastingAppBase_m.h"

#include "IBroadcastGateway.h"
#include "IBroadcastProtocol.h"


namespace inet {


class INET_API BroadcastingAppBase : public ApplicationBase , public cListener
{
  public:
    //Unique (there aren't two nodes with the same delta) number of milliseconds that every node
    //set (according to its node identifier) to send control messages
    double delta;
    // how many hello messages I must send
    bool with_hello_msgs;
    enum ControlMessageTypes {
        IDLE,
        START,
        SAY_HELLO,
        WAKEUP,
        DISPLAY_TIME,
        BROADCAST_DELAY,
        HALT_SIMULATION_DELAY,
        TRANSFORMATION_TIMEOUT,
        OFFICER_ELECTION_TIMEOUT,
        LAST_POWER_REPORT,
        APPROXIMATE_DENSITY,
        DO_ADAPTATION,
        BOOTSTRAP_MSG,
        First = IDLE,
        Last = BOOTSTRAP_MSG
    };


  private:

    class OmnetBroadcastGateway: public IBroadcastGateway {
    private:
      BroadcastingAppBase* app;
      double get_double_parameter(const std::string& protocol, const std::string& param) override;
      bool get_bool_parameter(const std::string& protocol, const std::string& param) override;
      std::string get_string_parameter(const std::string& protocol, const std::string& param) override;
      int last_message_assigned;
    public:

      OmnetBroadcastGateway(BroadcastingAppBase* app);

      Coord get_current_position() override ;
      double get_transmission_radius() override ;

      L3Address getAddr(const std::string& id) override;

      void send_package(cPacket* m) override;

      void broadcast(std::string key, broadcasting::Broadcast* msg) override;

      std::string createUniqueBroadcastingSessionId() override;

      void emitBroadcastMsgReceived(const std::string& value) override;

      void emitDensityApproximation(int value) override;

      void emitNodePosition(float x, float y, float density) override;

      void delayed_event(int type, const std::string& key, double delay) override;
      cMessage* delayed_broadcast(const std::string& key, double delay) override;

      bool bridge() override;

      std::string get_name() override {
	      return app->myself;
      }

      void setProtocolId(const std::string& protocol) override {
        app->protocolId = protocol;
      }

      void cancel_message(cMessage* m) override;
      int register_new_control_message() override;
    };

    friend class OmnetBroadcastGateway;
  private:
    // number of broadcast message to send
    int nr_broadcast_msg;


    // when to send broadcast messages
    std::set<int> msgs;
    std::set<int>::iterator next_to_send;

    // my position
    Coord position;
    double radious;

    // communication
    int remote_port = 10000;
    int local_port = 10000;
    UDPSocket socket;


    double adaptationMax;
    double adaptationMin;
    double timeoutCustomOfficer;
    std::string protocolId;
    int nr_max_custom_officers;
    std::set<std::string> lastForeignHelloSenders;

    //Payloads
    std::map<std::string, std::string> adaptForeigsMsgs;
    std::map<std::string, std::string> adaptMyProtoMsgs;
    std::map<std::string, cMessage*> timeoutMsgs;
    std::map<std::string, cMessage*> timeoutBorderDet;

    // custom officer for foreign protocol
    // map from protocol to target
    std::map<std::string, std::set<std::string>> customOfficers;

    bool amIbridge = false;

  private:

    bool contains(const std::string& protocolId, const std::string& nodeId);
    void save_border_node(const std::string& protocolId, const std::string& nodeId);

    // control messages
    cMessage* ctrlDisplayTime = nullptr;

    /* signals used to record statistics */
    simsignal_t signal_received_id;
    simsignal_t signal_sent_id;
    simsignal_t signal_power_level;
    simsignal_t signal_broadcast_msg_received;
    simsignal_t signal_density_approximation;
    simsignal_t signal_node_position_x;
    simsignal_t signal_node_position_y;

    bool already_configured = false;

  protected:

    bool withAdaptation;

    bool use_topology_fix;
    bool optimize_gluing;

    // is the source of a broadcast
    bool is_source;

    L3Address myAddress;

    // my direct edges (neighbors)
    std::map<std::string, Neighbor> neighbors;

    // myself as a module
    std::string myself;

    std::shared_ptr<IBroadcastGateway> gateway;

  public:
    BroadcastingAppBase();

  protected:

    virtual void configure_neighbors();

    virtual int numInitStages() const override { return NUM_INIT_STAGES; }
    virtual void initialize(int stage) override;
    virtual void handleMessageWhenUp(cMessage *msg) override;

    virtual bool handleNodeStart(IDoneCallback *doneCallback) override;

    virtual void processStart();


    template <typename T> bool
  	processMessage(cPacket* pkt, std::function<void(const T*)> action)
  	{
  		// T* t = check_and_cast_nullable<T*>(dynamic_cast<T*>(pkt));
  		T* t = dynamic_cast<T*>(pkt);
  		if (t != nullptr) {
  			action(t);
  		  return true;
  		}
  		else {
  		    return false;
  		}
  	}


    virtual void on_hello_received(const broadcasting::Hello* msg);
    virtual void on_payload_received(const broadcasting::Broadcast* m); // you must ALWAYS redefine (overwrite) this one
    virtual bool on_network_message_received(cPacket* pkt); // This nasty one must be defined if your protocol is using other type of messages (percolator)

    virtual void time_to_broadcast_payload(void* user_data); // it is called sometime after you call delayed_broadcast


  protected:
    // core broadcast protocol
    virtual inet::broadcasting::Hello* build_hello_message();
    double get_random_delay() { return uniform(0.03, 0.1); }

    // optional

    std::string getLogHeader();
    void printBroadcastingLog(std::string key);

  private:

    // core broadcast gateway
    Coord updatePosition();
    double get_radious();
    void send_package(cPacket* m); // send a package to all nearby devices
    void broadcast(std::string key, broadcasting::Broadcast* msg);
    std::string createUniqueBroadcastingSessionId();
    L3Address getAddr(const std::string& id);
    void emitBroadcastMsgReceived(const std::string& value); // important. you should use it. log data (statistics in vector)
    cMessage* delayed_event(int type, const std::string& key, double delay);
    cMessage* delayed_broadcast(const std::string& key, double delay); // call this one in the implementation of on_payload_received. it is like a Timer that will be called after 'delay' seconds

    void emitReceived(); // this is automatic (don't call it)
    void emitPowerLevel(double value); // (don't call it)
    void emitSent(std::string value); // important. you should use it. log data (statistics in vector)

    void delay_broadcast(void* user_data);
    void delayed_event_with_strict_time(int type, const std::string& key, double delay);
    void send_package(cPacket* m, std::string dst); // send a package to a particular devices given its host name
    int get_next_id_for_msg();
    int get_last_id_for_msg();

    double computeAdaptTimeout();

    bool msgReceived(const broadcasting::Broadcast* m);

    bool applyMsgsTransformation(cMessage *msg, bool &fwdMsg);
    bool borderDetector(cMessage *msg);

};

} //namespace

#endif
