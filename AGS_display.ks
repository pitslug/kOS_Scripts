// AGS Display Setup
// Sets up the terminal for info display

SET rCount To 16.
SET mCount to TERMINAL:HEIGHT - 2.

PRINT "================================================"  AT (0,0).
PRINT "    AGS - Active Guidance System (Ver "+verNum+")  "  AT (0,1).
PRINT "================================================"  AT (0,2).
PRINT " "                                                 AT (0,3).
PRINT "Mission Name:     " + shipName                     AT (0,4).
PRINT "Status:           " + vesselStatus                 AT (0,5).
PRINT "MET:              " + mTime                        AT (0,6).
PRINT " "                                                 AT (0,7).
PRINT "Launch Parameters:"                                AT (0,8).
PRINT "Heading           " + azimuth + " deg"             AT (0,9).
PRINT "Apoapsis:         " + tgtApo/1000 + " km"          AT (0,10).
PRINT " "                                                 AT (0,11).
PRINT "                   EVENT LOG                    "  AT (0,12).
PRINT "================================================"  AT (0,13).
PRINT "  TIME       MESSAGE                          "    AT (0,14).
PRINT " "                                                 AT (0,15).

  //IF targetLaunch = 1
    //PRINT "Rel. Inclination: " + vang(normalvector(ship),normalvector(target)) at (0,11).

FUNCTION addMessage {
  PARAMETER msgTime.
  PARAMETER msg.

  IF rCount <= mCount {
    PRINT msgTime AT (0,rCount).
    PRINT msg AT (10,rCount).
    SET rCount TO rCount + 1.
    RETURN.

  } ELSE {

    FROM {LOCAL x IS 16.} UNTIL x = rCount STEP {SET x TO x + 1.} DO {
      PRINT "                                                " AT (0,x).
    }
    SET rCount TO 16.
    PRINT msgTime AT (0,rCount).
    PRINT msg AT (10,rCount).
    SET rCount TO rCount + 1.
    RETURN.
  }
}

FUNCTION statusUpdate {
  PARAMETER newStatus.
  PRINT "                                "  AT (18,5).
  PRINT newStatus AT (18,5).
}

FUNCTION timerUpdate {
  PARAMETER newTime.
  PRINT "                            "  AT (18,6).
  PRINT newTime AT (18,6).
}
