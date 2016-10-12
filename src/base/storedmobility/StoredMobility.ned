package storedmobility;

import inet.mobility.base.MovingMobilityBase;
import inet.mobility.single.LinearMobility;

//
//
// @author Inti Gonzalez
//
simple StoredMobility extends MovingMobilityBase
{
    parameters:
      double initialX @unit(m) = default(uniform(this.constraintAreaMinX, this.constraintAreaMaxX));
      double initialY @unit(m) = default(uniform(this.constraintAreaMinY, this.constraintAreaMaxY));
      double initialZ @unit(m) = default(uniform(this.constraintAreaMinZ, this.constraintAreaMaxZ));
      bool initFromDisplayString = default(true);
      bool isMoving = default(false);
      string filename;


      @class(inet::StoredMovingMobility);
}
