// AGS Variable Declarations
// Set up variables for use in launch script
@LAZYGLOBAL OFF.

// Set program version number
LOCAL verNum IS "0.3.4".

// Declare Variable for Launch Script
LOCAL incomplete IS 0.
LOCAL count_mode IS 1.
LOCAL lift_mode IS 2.
LOCAL passive_mode IS 3.
LOCAL active_mode IS 4.
LOCAL complete TO 5.
GLOBAL launchStatus IS incomplete.

// Set Variables for display
GLOBAL shipName TO SHIP:NAME.


// Set TWR function variables
LOCAL current TO "current".
LOCAL maximum TO "maximum".

// Function for determining launch prograde vector
LOCK progradePitch TO navPitch(SRFPROGRADE:VECTOR).

// Determine Tower Height
LOCAL towerHeight IS shipHeight() + ALT:RADAR.

LOCAL targetLaunch TO 0.
LOCAL launchTgt to "".
LOCAL relInc to "".
