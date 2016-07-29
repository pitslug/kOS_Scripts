// ALGS Variable Declarations
// Set up variables for use in launch script

// Set mode variables for Launch. Set to 0 when complete
SET count_mode TO 1.
SET lift_mode TO 2.
SET turn_mode TO 3.
SET circ_mode TO 4.
SET complete TO 0.

// Set Variables for display
SET shipName TO SHIP:NAME.
SET vesselStatus TO " ".
SET mTime TO " ".

// Set TWR function variables
SET current TO "current".
SET maximum TO "maximum".

// Function for determining launch prograde vector
LOCK progradePitch TO navPitch(SRFPROGRADE:VECTOR).

// Determine Tower Height
SET towerHeight TO shipHeight() + ALT:RADAR.
