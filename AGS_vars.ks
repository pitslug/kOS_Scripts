// AGS Variable Declarations
// Set up variables for use in launch script

// Set program version number
SET verNum TO "0.3.4".

// Set mode variables for Launch. Set to 0 when complete
SET incomplete TO 0.
SET count_mode TO 1.
SET lift_mode TO 2.
SET passive_mode TO 3.
SET active_mode TO 4.
SET complete TO 5.
GLOBAL launchStatus IS incomplete.

// Set Variables for display
SET shipName TO SHIP:NAME.
SET vesselStatus TO " ".
GLOBAL mTime IS " ".

// Set TWR function variables
SET current TO "current".
SET maximum TO "maximum".

// Function for determining launch prograde vector
LOCK progradePitch TO navPitch(SRFPROGRADE:VECTOR).

// Determine Tower Height
SET towerHeight TO shipHeight() + ALT:RADAR.

SET targetLaunch TO 0.
SET launchTgt to "".
SET relInc to "".
