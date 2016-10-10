package storedmobility;

import inet.mobility.base.MovingMobilityBase;

//
//
// @author Inti Gonzalez
//
simple StoredMobility extends MovingMobilityBase
{
    parameters:
      bool isMoving = default(false);
      string filename;

      @class(inet::StoredMovingMobility);
}
