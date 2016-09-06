// AGS Variable Declarations
// Set up variables for use in launch script
@LAZYGLOBAL OFF.

// Set program version number
LOCAL verNum IS "0.3.9".

// Declare Variable for Launch Script
LOCAL incomplete IS 0.
LOCAL count_mode IS 1.
LOCAL lift_mode IS 2.
LOCAL passive_mode IS 3.
LOCAL active_mode IS 4.
LOCAL complete IS 5.
GLOBAL launchStatus IS incomplete.

// Set Variables for display
GLOBAL shipName IS SHIP:NAME.
GLOBAL mTime IS "".


// Set TWR function variables
LOCAL current IS "current".
LOCAL maximum IS "maximum".

// Function for determining launch prograde vector
LOCK progradePitch TO navPitch(SRFPROGRADE:VECTOR).
LOCK pitch TO 90 - vectorangle(UP:FOREVECTOR, FACING:FOREVECTOR).


// Determine Tower Height
LOCAL towerHeight IS shipHeight() + ALT:RADAR.

LOCAL targetLaunch IS 0.
LOCAL launchTgt IS "".
LOCAL relInc IS "".

GLOBAL maxQ IS 0.
GLOBAL maxQ_found IS 0.

GLOBAL g IS 0.
