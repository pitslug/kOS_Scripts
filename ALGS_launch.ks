// ALGS Countdown and Guidance Script
// Run the countdown and switch to active guidance once tower clear

SET launchStatus TO count_mode.
UNTIL launchStatus = complete {

  SAS off.
  LOCK THROTTLE TO 1.

  IF launchStatus = count_mode {

    //////////////////////////////
    // Start Countdown Sequence //
    //////////////////////////////

    statusUpdate("Commencing Countdown Sequence").
    WAIT 1.

    //Pre-launch Countdown Sequence
    FROM {LOCAL y IS cdTimer.} UNTIL y = 10 STEP {SET y TO y - 5.} DO {

      IF y = 15 addMessage("T-15s", "All systems are Go!").
      timerUpdate("T-"+y+"s").
      WAIT 5.
    }

    // Final Countdown Sequence
    FROM {LOCAL x IS 10.} UNTIL x = 0 STEP {SET x TO x - 1.} DO {

      IF x = 10 addMessage("T-10s", "Guidance is internal").
    	SET mTime TO "T-" + x + "s".
      timerUpdate(mTime).

    	// Pre-ignition for engine spooling
    	IF x = CEILING(cdIgnite) {
    		WAIT (CEILING(cdIgnite) - cdIgnite).
    		addMessage("T-" + ROUND(cdIgnite,1) + "s", "Ignition Sequence Start").
        statusUpdate("Ignition Sequence").

        STAGE.
    		WAIT (1 - (CEILING(cdIgnite) - cdIgnite)).
    	} ELSE {
    		WAIT 1.
    	}
    }

    addMessage("T+"+ROUND(MISSIONTIME)+"s", "TWR is "+ROUND(TWRCalc(current),2)). //TEMPORARY CHECK
    // Check thrust before releasing clamps - abort if engine failure.
    IF TWRCalc(current) > 1 {

      //addMessage("T+"+ROUND(MISSIONTIME)+"s", "All Engines Running - Releasing Clamps").
      addMessage(" ", "All Engines Running - Releasing Clamps").
    	LOCK STEERING TO North + R(-90,0,0). // Keep at initial orientation until guidance active
    	STAGE.

      WAIT 0.001.
      SET launchStatus TO lift_mode. // Next Loop

    }	ELSE {

    	//addMessage("T+"+ROUND(MISSIONTIME)+"s", "Engine Failure. Launch Aborted").
      addMessage(" ", "Engine Failure. Launch Aborted").
    	LOCK THROTTLE TO 0.
    }
  } // End count_mode

  // Start lift_mode
  IF launchStatus = lift_mode {

    LOCK mTime to "T+"+ROUND(MISSIONTIME)+"s".

    WHEN SHIP:AIRSPEED > 5 THEN {
      addMessage(mTime, "LIFT-OFF of "+shipName).
      statusUpdate("Lift-off").

      // Engage active guidance once tower clear
      WAIT UNTIL ALT:RADAR > towerHeight.
      addMessage(mTime, "Tower Clear. Engaging Guidance Control").
      statusUpdate("Active Guidance Initiated").

      WAIT 1.
      SET launchStatus TO turn_mode. // Next Loop
    }
  } // End lift_mode

  // Start turn_mode
  IF launchStatus = turn_mode {

    LOCK mTime to "T+"+ROUND(MISSIONTIME)+"s".

    ///////////////////////////////////
    // Start Active Guidance Control //
    ///////////////////////////////////

    // Set Pitching Start Speed
    IF TWRCalc(maximum) > 1.7
      SET pitchStart to 50.
    ELSE IF TWRCalc(maximum) < 1.7 AND TWRCalc(maximum) > 1.3
      SET pitchStart TO 65.
    ELSE
      SET pitchStart TO 80.

    // Start Roll Program once Tower Clear
    addMessage(mTime, "Executing Roll Program").
    LOCK STEERING to HEADING(azimuth,pitch) + R(0,0,roll).

    // Start Pitch Program at correct speed
    WHEN SHIP:AIRSPEED >= pitchStart THEN {
      LOCK STEERING TO HEADING(azimuth,85) + R(0,0,roll).
      addMessage(mTime, "Executing Pitch Program").
    }

    // Align to Surface Prograde (TEMPORARY)
    WHEN progradePitch() <= 85 and SHIP:AIRSPEED >= pitchStart THEN {
      LOCK STEERING TO HEADING(azimuth,progradePitch()) + R(0,0,roll).
      addMessage(mTime, "Gravity Turn - TEMPORARY").
    }

    WAIT UNTIL APOAPSIS >= tgtApo.
    SET launchStatus TO complete. // End Loops

  } // End turn_mode


  PRINT "MET:              " + mTime  + "              "  AT (0,7).

} // End Main Loop




//UNTIL cdStatus = 1 {

//  PRINT "MET:              " + mTime  + "              "  AT (0,7).

//}



//WAIT UNTIL cdStatus = 1. // To ensure Guidance doesn't start early
