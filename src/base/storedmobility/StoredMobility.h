#ifndef __STORED_MOBILITY__
#define __STORED_MOBILITY__

#include "inet/common/INETDefs.h"
#include "inet/mobility/base/MobilityBase.h"
#include "inet/mobility/base/MovingMobilityBase.h"


#include <string>
#include <vector>

namespace inet {

	class NodeStoredMobility {
	  public:
	    void add_location(double x, double y);
	    std::pair<double, double> get_next_location();
	    bool hasMoreLocations();
	    double get_time_step() { return time_step;  }

	    void done_reading();

	    NodeStoredMobility(double ts) : time_step(ts) {};
			NodeStoredMobility() : time_step(0) {};
	  private:
	    double time_step;
	    std::vector< std::pair<double, double> > locations;
	};

	class INET_API StoredMovingMobility : public MovingMobilityBase {
		public:
			/** @brief Moves according to the mobility model to the current simulation time.
	     *
	     * Subclasses must override and update lastPosition, lastSpeed, lastUpdate, nextChange
	     * and other state according to the mobility model.
	     */
	    void move() override;
		protected:
			void initialize(int stage);
		private:
			bool isMoving = false;
			std::string filename;
			NodeStoredMobility mobility;
	};

} // namespace



#endif
