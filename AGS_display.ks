// AGS Display Setup
// Sets up the terminal for info display
@LAZYGLOBAL OFF.

LOCAL mCount IS TERMINAL:HEIGHT - 2.
LOCAL rCount IS 19.
LOCAL iCount IS 19.

FUNCTION mainMenuDisplay {

  CLEARSCREEN.

  PRINT "===================================================="     AT (0,0).
  PRINT "      AGS - Active Guidance System (Ver "+verNum+")    "  AT (0,1).
  PRINT "                    Main Menu                       "     AT (0,2).
  PRINT "===================================================="     AT (0,3).
  PRINT " "                                                    AT (0,4).
  PRINT " [1]     Launch Menu "                                AT (0,5).
  PRINT " [2]     Maneuver Menu "                              AT (0,6).
  PRINT " [3]     Rendezvous Menu "                            AT (0,7).
  PRINT " [4]     Landing Menu "                               AT (0,8).
  PRINT " "                                                    AT (0,9).
  PRINT " "                                                    AT (0,10).
  PRINT "===================================================="     AT (0,11).

  UNTIL FALSE {

    ON AG1 {launchMenuDisplay().}
    ON AG2 {}
    ON AG3 {}
    ON AG4 {}

  }
}


FUNCTION launchMenuDisplay {

  CLEARSCREEN.

  PRINT "===================================================="     AT (0,0).
  PRINT "      AGS - Active Guidance System (Ver "+verNum+")    "  AT (0,1).
  PRINT "                    Launch Menu                     "     AT (0,2).
  PRINT "===================================================="     AT (0,3).
  PRINT " "                                                    AT (0,4).
  PRINT " [1]     Determine Launch Window "                    AT (0,5).
  PRINT " [2]     Set Launch Parameters "                      AT (0,6).
  PRINT " [3]     Warp to Launch Window "                      AT (0,7).
  PRINT " [4]     Execute Launch Sequence "                    AT (0,8).
  PRINT " "                                                    AT (0,9).
  PRINT " "                                                    AT (0,10).
  PRINT " [0]     Return to Main Menu "                        AT (0,11).
  PRINT " "                                                    AT (0,12).
  PRINT " "                                                    AT (0,13).
  PRINT "===================================================="     AT (0,14).

  UNTIL FALSE {

    ON AG1 {}
    ON AG2 {}
    ON AG3 {}
    ON AG4 {launchSeqDisplay().}
    ON AG10 {mainMenuDisplay().}

  }
}

FUNCTION launchSeqDisplay {

  CLEARSCREEN.

  IF launchStatus = complete {
    PRINT "===================================================="     AT (0,0).
    PRINT "      AGS - Active Guidance System (Ver "+verNum+")    "  AT (0,1).
    PRINT "                 Launch Sequence                    "     AT (0,2).
    PRINT "===================================================="     AT (0,3).
    PRINT " "                                                    AT (0,4).
    PRINT "         LAUNCH NOT POSSIBLE AT THIS TIME           "     AT (0,5).
    PRINT " "                                                    AT (0,6).
    PRINT "              RETURNING TO MAIN MENU                "     AT (0,7).

    WAIT 3.

    mainMenuDisplay().

  } ELSE {

  //IF targetLaunch = 1 { SET relInc to VANG(normalvector(SHIP),normalvector(TARGET)). }

    PRINT "===================================================="     AT (0,0).
    PRINT "      AGS - Active Guidance System (Ver "+verNum+")    "  AT (0,1).
    PRINT "                 Launch Sequence                    "     AT (0,2).
    PRINT "===================================================="     AT (0,3).
    PRINT " "                                                    AT (0,4).
    PRINT "Mission Name:     " + shipName                        AT (0,5).
    PRINT "Status:           "                                   AT (0,6).
    PRINT "Countdown:        "                                   AT (0,7).
    PRINT " "                                                    AT (0,8).
    PRINT "Launch Parameters:"                                   AT (0,9).
    PRINT "Heading           " + azimuth + " deg"                AT (0,10).
    PRINT "Apoapsis:         " + tgtApo/1000 + " km"             AT (0,11).
    PRINT "Target:           " + launchTgt                       AT (0,12).
    PRINT "Rel. Inclination: " + relInc                          AT (0,13).
    PRINT " "                                                    AT (0,14).
    PRINT "                     EVENT LOG                      "     AT (0,15).
    PRINT "===================================================="     AT (0,16).
    PRINT " TIME           MESSAGE                             "     AT (0,17).
    PRINT " "                                                    AT (0,18).

    RUN ONCE AGS_launch.

    WHEN launchStatus = complete THEN {mainMenuDisplay().}
  }
}


FUNCTION addMessage {
  PARAMETER msgTime.
  PARAMETER msg.

  IF iCount <= mCount {
    PRINT msgTime AT (0,iCount).
    PRINT msg AT (14,iCount).
    SET iCount TO iCount + 1.
    RETURN.

  } ELSE {

    FROM {LOCAL x IS rCount.} UNTIL x = iCount STEP {SET x TO x + 1.} DO {
      PRINT "                                                    " AT (0,x).
    }
    SET iCount TO rCount.
    PRINT msgTime AT (0,iCount).
    PRINT msg AT (14,iCount).
    SET iCount TO iCount + 1.
    RETURN.
  }
}

FUNCTION statusUpdate {
  PARAMETER newStatus.
  PRINT "                                "  AT (18,6).
  PRINT newStatus AT (18,6).
}

FUNCTION timerUpdate {
  PARAMETER newTime.
  PRINT "                            "  AT (18,7).
  PRINT newTime AT (18,7).
}
