// AGS Countdown and Guidance Script
// Run the countdown and switch to active guidance once tower clear
@LAZYGLOBAL OFF.

//SET launchStatus TO count_mode.
SET launchStatus TO count_mode.

UNTIL launchStatus = complete {

  SAS off.
  LOCK THROTTLE TO 1.
  LOCK mTime to "T+" + convertTime(MISSIONTIME).

  IF launchStatus = count_mode {

    //////////////////////////////
    // Start Countdown Sequence //
    //////////////////////////////

    statusUpdate("Commencing Countdown Sequence").
    WAIT 1.

    //Pre-launch Countdown Sequence
    FROM {LOCAL y IS cdTimer.} UNTIL y = 10 STEP {SET y TO y - 5.} DO {

      IF y = 15 addMessage("T-" + convertTime(y), "All systems are Go!").
      timerUpdate("T-" + convertTime(y)).
      WAIT 5.
    }

    // Final Countdown Sequence
    FROM {LOCAL x IS 10.} UNTIL x = 0 STEP {SET x TO x - 1.} DO {

      IF x = 10 addMessage("T-" + convertTime(x), "Guidance is internal").
    	timerUpdate("T-" + convertTime(x)).

    	// Pre-ignition for engine spooling
    	IF x = CEILING(cdIgnite) {
    		WAIT (CEILING(cdIgnite) - cdIgnite).
    		addMessage("T-" + convertTime(ROUND(cdIgnite,1)), "Ignition Sequence Start").
        statusUpdate("Ignition Sequence").

        STAGE.
    		WAIT (1 - (CEILING(cdIgnite) - cdIgnite)).
    	} ELSE {
    		WAIT 1.
    	}
    }

    addMessage(mTime, "TWR is "+ROUND(TWRCalc(current),2)). //TEMPORARY CHECK

    // Check thrust before releasing clamps - abort if engine failure.
    IF TWRCalc(current) > 1 {
      addMessage(" ", "All Engines Running - Releasing Clamps").
    	LOCK STEERING TO HEADING(0,90).   // Keep at initial orientation until guidance active
    	STAGE.

      SET launchStatus TO lift_mode. // Next Loop
      WAIT 0.001.

    }	ELSE {

      addMessage(" ", "Engine Failure. Launch Aborted").
    	LOCK THROTTLE TO 0.
      BREAK.
    }
  } // End count_mode

  // Start lift_mode
  IF launchStatus = lift_mode {

    PRINT "MET:              "                                   AT (0,7).

    WHEN SHIP:AIRSPEED > 3 THEN {
      addMessage(mTime, "LIFT-OFF of " + shipName).
      statusUpdate("Lift-off").
    }

    UNTIL FALSE {
      timerUpdate(mTime).
      WAIT 0.5.
      IF ALT:RADAR > towerHeight {
        addMessage(mTime, "Tower Clear. Engaging Guidance Control").
        statusUpdate("Passive Guidance Mode").
        WAIT 1.
        SET launchStatus TO passive_mode. // Next Loop
        WAIT 0.001.
        BREAK.
      }
    }
  } // End lift_mode


  // Start passive_mode
  IF launchStatus = passive_mode {

    ////////////////////////////////////
    // Start PASSIVE Guidance Control //
    ////////////////////////////////////

    LOCAL atmp_ground IS SHIP:SENSORS:PRES.
    LOCAL atmp_end IS 0.
    LOCAL atmp_current IS atmp_ground.
    LOCAL atm_density IS 1.
    LOCAL AoA IS 0.
    LOCAL tgtPitch IS 90.
    LOCAL tgtLiftPitch IS 90.
    GLOBAL apoETA IS 0.

    LOCK atmp_current TO SHIP:SENSORS:PRES.
    LOCK atm_density TO atmp_current / atmp_ground.
    LOCK apoETA TO MAX(0,ETA:APOAPSIS).
    LOCK AoA TO progradePitch() - tgtPitch.

    // Minimise AoA to aoaLim
    LOCK tgtPitch TO MIN(90 - (45 * (1 - atm_density)),progradePitch() + aoaLim).
    LOCK tgtLiftPitch TO MIN(88,progradePitch() + aoaLim).


    // Set Pitching Start Speed
    GLOBAL pitchStart IS 0.
    IF TWRCalc(maximum) > 1.7
      SET pitchStart to 50.
    ELSE IF TWRCalc(maximum) < 1.7 AND TWRCalc(maximum) > 1.3
      SET pitchStart TO 60.
    ELSE
      SET pitchStart TO 70.


    // Start Roll Program once Tower Clear
    addMessage(mTime, "Executing Roll Program").
    LOCK STEERING to HEADING(azimuth,tgtLiftPitch) + R(0,0,tgtRoll).
    WHEN abs(navRoll() - tgtRoll) < 1 THEN { addMessage(mTime, "Roll Complete"). }

    // Start Pitch Program at correct speed
    WHEN SHIP:AIRSPEED >= pitchStart THEN {
      addMessage(mTime, "Executing Pitch Program").
      LOCK STEERING TO HEADING(azimuth,tgtPitch) + R(0,0,tgtRoll).
      }

    UNTIL FALSE {
      timerUpdate(mTime).
      WAIT 0.5.
      IF apoETA > tgtApoETA {
        addMessage(mTime, "Passive Pitch Complete").
        WAIT 1.
        addMessage(" ", " ").
        addMessage(mTime, "Switching to Active Guidance").
        statusUpdate("Active Guidance Mode").
        SET launchStatus TO active_mode.  // Next Loop
        BREAK.
      }

      WAIT 0.001.

    }
  } // End passive_mode


  // Start active_mode
  IF launchStatus = active_mode {

    ///////////////////////////////////
    // Start ACTIVE Guidance Control //
    ///////////////////////////////////

    LOCAL atmoEndAlt IS 140000.  // Was 110000
    LOCAL endturn_altitude IS ALTITUDE.
    LOCAL tolerance IS tgtApoETA * 0.5.
    LOCAL shipangle IS 0.
    LOCAL correctiondamp IS 0.
    LOCAL mx IS 0.
    LOCAL mi IS 0.
    LOCAL tApoEta IS tgtApoETA.
    LOCAL ae IS 0.
    LOCAL correction IS 0.

    LOCAL targetorbitspeed IS sqrt(ship:body:mu / (tgtApo+ship:body:radius)).
    LOCAL endturn_orbitspeed IS ship:velocity:orbit:mag.


    lock shipangle to vang(ship:up:vector, ship:srfprograde:vector).
    lock correctiondamp to (altitude - endturn_altitude) / (atmoEndAlt - endturn_altitude).
    lock mx to shipangle + (maxcorrection * correctiondamp).
    lock mi to shipangle - (maxcorrection * correctiondamp).

    lock orbitSpeedFactor to ((targetorbitspeed - ship:velocity:orbit:mag) / (targetorbitspeed - endturn_orbitspeed)).
    lock tApoEta to tgtApoETA * orbitSpeedFactor.
    lock correction to max(-maxcorrection*0.3,((tApoEta - ae) / tolerance) * maxcorrection).

    lock tgtPitch to 90 - max(mi,min(mx, shipangle - correction )).
    LOCK STEERING TO HEADING(azimuth,tgtPitch) + R(0,0,tgtRoll).

    until ALT:periapsis >= tgtApo - 20000 {
        // prevent program to fail if ship is falling down
        // by overriding apoeta
        if ship:verticalspeed > 0 {
            set ae to apoeta.
        } else {
            set ae to 0.
        }

        PRINT ("Target Apo ETA:   " + ROUND(tApoEta,3)) AT (10,iCount).
        PRINT ("Current Apo ETA:  " + ROUND(apoETA,3)) AT (10,iCount + 1).
    }

    LOCK THROTTLE TO 0.
    SAS ON.


    SET launchStatus TO complete. // End Loops
    WAIT 0.001.


  } // End active_mode

} // End Main Loop

UNLOCK THROTTLE.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
RCS ON.
SAS ON.
SET SASMODE TO PROGRADE.
addMessage(mTime, "Launch Program Complete").
updateStatus("Program Complete").

WAIT 5.

mainMenuDisplay().
