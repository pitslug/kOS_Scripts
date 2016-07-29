// ALGS Display Setup
// Sets up the terminal for info display

SET rCount To 16.

PRINT "=============================================="  AT (0,1).
PRINT "ALGS - Active Launch Guidance System (Ver 0.2)"  AT (0,2).
PRINT "=============================================="  AT (0,3).
PRINT " "                                               AT (0,4).
PRINT "Mission Name:     " + shipName                   AT (0,5).
PRINT "Status:           " + vesselStatus               AT (0,6).
PRINT "MET:              " + mTime                      AT (0,7).
PRINT " "                                               AT (0,8).
PRINT "Launch Parameters:"                              AT (0,9).
PRINT "Heading           " + azimuth + " deg"           AT (0,10).
PRINT "Apoapsis:         " + tgtApo/1000 + " km"        AT (0,11).
PRINT " "                                               AT (0,12).
PRINT "                  EVENT LOG                   "  AT (0,13).
PRINT "=============================================="  AT (0,14).
PRINT "  TIME       MESSAGE                          "  AT (0,15).
PRINT " "                                               AT (0,16).

  //IF targetLaunch = 1
    //PRINT "Rel. Inclination: " + vang(normalvector(ship),normalvector(target)) at (0,11).


FUNCTION addMessage{
  PARAMETER msgTime.
  PARAMETER msg.

  SET rCount TO rCount + 1.

  PRINT msgTime AT (0,rCount).
  PRINT msg AT (10,rCount).
  RETURN.
}

FUNCTION statusUpdate{
  PARAMETER newStatus.
  PRINT "Status:                                           "  AT (0,6).
  PRINT "Status:           " + newStatus AT (0,6).
}

FUNCTION timerUpdate{
  PARAMETER newTime.
  PRINT "MET:                                          "  AT (0,7).
  PRINT "MET:              " + newTime AT (0,7).
}
