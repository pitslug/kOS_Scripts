// ALGS Navigation Functions Library
// Used to determine current ship directions from navball.
// Based on lib_navball.ks by KSLib team, shared under MIT License.

// Get Pitch from input Vector
FUNCTION navPitch {
	PARAMETER vector.
	RETURN 90-VANG(SHIP:UP:VECTOR,VECTOR).
}

FUNCTION normalVector {
	PARAMETER ves.
	LOCAL vel TO VELOCITYAT(ves,TIME:SECONDS):ORBIT.
	LOCAL norm TO VCRS(vel,ves:up:vector).
	RETURN norm:NORMALIZED.
}

// Get East Vector
FUNCTION east {
	RETURN VCRS(SHIP:UP:VECTOR, SHIP:NORTH:VECTOR).
}

// Get current Roll from navball
FUNCTION navRoll {
	IF VANG(SHIP:FACING:VECTOR, SHIP:UP:VECTOR) < 0.2 { RETURN 0. } //	deadzone against gimbal lock (when vehicle is too vertical, roll angle becomes indeterminate)
	ELSE {
		LOCAL raw IS VANG(VXCL(SHIP:FACING:VECTOR, SHIP:UP:VECTOR), SHIP:FACING:STARVECTOR).
		IF VANG(SHIP:UP:VECTOR, SHIP:FACING:TOPVECTOR) > 90 {
			RETURN 270-raw.
		} ELSE {
			RETURN -90-raw.
		}
	}.
}
