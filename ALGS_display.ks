// ALGS Display Setup
// Sets up the terminal for info display

FUNCTION flightData {
  CLEARSCREEN.
  PRINT "=============================================="  AT (0,1).
  PRINT "ALGS - Active Launch Guidance System (Ver 0.1)"  AT (0,2).
  PRINT "=============================================="  AT (0,3).
  PRINT "Vessel:           " + shipName                   AT (0,4).
  PRINT " "                                               AT (0,5).
  PRINT "Status:           " + status + "              "  AT (0,6).
  PRINT "Mission Time:     " + mTimer + "s             "  AT (0,7).
  PRINT " "                                               AT (0,8).
  PRINT "Vessel Statistics:"                              AT (0,9).
  PRINT "Current TWR:      " + TWRCalc(current)           AT (0,10).
  PRINT "Heading:          " + azimuth                    AT (0,11).
  PRINT "Current Vel:      " + ROUND(SHIP:AIRSPEED,2)     AT (0,12).

  //IF targetLaunch = 1
    //PRINT "Rel. Inclination: " + vang(normalvector(ship),normalvector(target)) at (0,11).

}
