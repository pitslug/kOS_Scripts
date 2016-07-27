CLEARSCREEN.
SET TERMINAL:BRIGHTNESS TO 0.85.

lock apoeta to max(0,eta:apoapsis).

RUN ONCE ALGS_nav.
RUN ONCE ALGS_func.
RUN ONCE ALGS_vars.
RUN ONCE ALGS_settings.
RUN ONCE ALGS_display.

FUNCTION countdown {

	//flightData().

	SAS off.
	LOCK THROTTLE TO 1.
	PRINT "Commencing Countdown Sequence".
	WAIT 1.
	PRINT "Lift-off in:".
	PRINT "T-15s".
	WAIT 5.

	// Start Countdown Sequence
	FROM {LOCAL x IS 10.} UNTIL x = 0 STEP {SET x TO x - 1.} DO {
		PRINT "T-" + x + "s".

		// Pre-ignition for engine spooling
		IF x = CEILING(cdIgnite) {
			WAIT (CEILING(cdIgnite) - cdIgnite).
			PRINT "IGNITION".
			STAGE.
			WAIT (1 - (CEILING(cdIgnite) - cdIgnite)).
		} ELSE {
			WAIT 1.
		}
	}

	// Check thrust before releasing clamps - abort if engine failure.
	IF TWRCalc(current) > 1 {
		PRINT "Engines are good. Launch is GO!".
		LOCK STEERING TO North + R(-90,0,0). // Keep at initial orientation until guidance active
		STAGE.
	}	ELSE {
		PRINT "Ignition Failure. Launch Aborted".
		LOCK THROTTLE TO 0.
		RETURN.
	}

	WHEN SHIP:AIRSPEED > 1 THEN {
		//PRINT "Lift-off...".
		WAIT UNTIL ALT:RADAR > towerHeight. // Engage active guidance once tower clear
		PRINT "Tower Clear. Engaging Guidance Control".
		WAIT 1.
		SET cdStatus to 1.
		guidance().
	}
}


FUNCTION guidance {

	// Set Pitching Speed
	IF TWRCalc("maximum") > 1.7
		SET pitchStart to 50.
	ELSE IF TWRCalc(maximum) < 1.7 AND TWRCalc(maximum) > 1.3
		SET pitchStart TO 65.
	ELSE
		SET pitchStart TO 80.


	// Start Roll Program
	PRINT "Executing Roll Program".
	LOCK STEERING to HEADING(azimuth,pitch) + R(0,0,roll).

	// Start Pitch Program at correct speed
	WHEN SHIP:AIRSPEED >= pitchStart THEN {
		LOCK STEERING TO HEADING(azimuth,85) + R(0,0,roll).
		PRINT "Executing Pitching Program".
	}

	// Align to Surface Prograde (TEMPORARY)
	WHEN progradePitch() <= 85 and SHIP:AIRSPEED >= pitchStart THEN {
		LOCK STEERING TO HEADING(azimuth,progradePitch()) + R(0,0,roll).
		PRINT "Gravity Turn".
	}


	//PRINT "Current TWR:      " + TWRCalc(current)           AT (0,20).
	//print "Current Apoapsis ETA (seconds): "+apoeta at (0,21).
	
}


FUNCTION main {
		countdown().
}


main().


WAIT UNTIL launchStatus = 1.
PRINT "Launch Program Complete".

WAIT 1.
