// ALGS Variable Declarations
// Set up variables for use in launch script

// Set Vessel name for display
SET shipName TO SHIP:NAME.

// Launch Status - Set to 1 when guidance complete
SET launchStatus TO 0.
SET status TO "".

// Set initial TWR variables
SET current TO "current".
SET maximum TO "maximum".

// Function for determining launch prograde vector
LOCK progradePitch TO navPitch(SRFPROGRADE:VECTOR).

// Determine Tower Height
SET towerHeight TO shipHeight() + ALT:RADAR.

//Timer Function
SET mTime TO 0.
