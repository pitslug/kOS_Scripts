// ALGS Countdown and Guidance Script
// Run the countdown and switch to active guidance once tower clear


//////////////////////////////
// Start Countdown Sequence //
//////////////////////////////

SAS off.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
LOCK THROTTLE TO 1.

SET cdStatus TO 0. // Countdown Switch to Incomplete

updateStatus("Commencing Countdown Sequence").

WAIT 1.

addMessage("T-15s", "All systems are Go").
cdUpdate("T-15s").

WAIT 5.

addMessage("T-10s", "Guidance is internal").
cdUpdate("T-10s").

// Final Countdown Sequence
FROM {LOCAL x IS 10.} UNTIL x = 0 STEP {SET x TO x - 1.} DO {

	SET mTime TO "T-" + x + "s".
  cdUpdate(mTime).

	// Pre-ignition for engine spooling
	IF x = CEILING(cdIgnite) {
		WAIT (CEILING(cdIgnite) - cdIgnite).
		addMessage("T-" + ROUND(cdIgnite,1) + "s", "Ignition Sequence Start").
    updateStatus("Ignition Sequence").
		STAGE.
		WAIT (1 - (CEILING(cdIgnite) - cdIgnite)).
	} ELSE {
		WAIT 1.
	}
}

// Check thrust before releasing clamps - abort if engine failure.
IF TWRCalc(current) > 1 {

	addMessage("T+"+ROUND(MISSIONTIME)+"s", "All Engines Running - Releasing Clamps").
	LOCK STEERING TO North + R(-90,0,0). // Keep at initial orientation until guidance active
	STAGE.

}	ELSE {

	addMessage("T+"+ROUND(MISSIONTIME)+"s", "Engine Failure. Launch Aborted").
	LOCK THROTTLE TO 0.
}

LOCK mTime to "T+"+ROUND(MISSIONTIME)+"s".

WHEN SHIP:AIRSPEED > 5 THEN {
	addMessage(mTime, "LIFT-OFF of "+shipName).
  updateStatus("Lift-off").
	WAIT UNTIL ALT:RADAR > towerHeight. // Engage active guidance once tower clear

	addMessage(mTime, "Tower Clear. Engaging Guidance Control").
  updateStatus("Active Guidance Initiated").

  SET cdStatus to 1.
	WAIT 1.
}

WAIT UNTIL cdStatus = 1. // To ensure Guidance doesn't start early


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
SET launchStatus TO 1.
