package storedmobility;

import inet.mobility.base.MovingMobilityBase;

//
//
// @author Inti Gonzalez
//
simple StoredMobility extends MovingMobilityBase
{
    parameters:
      bool initFromDisplayString = default(true);
      bool isMoving = default(false);
      string filename;

      @class(inet::StoredMovingMobility);
}
