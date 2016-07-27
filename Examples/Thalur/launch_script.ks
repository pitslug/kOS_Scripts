@LAZYGLOBAL OFF.
PARAMETER launchTime.
PARAMETER enginePreStart.

IF launchTime=FALSE SET launchTime TO TIME:SECONDS + 6.
LOCAL LOCK dT TO launchTime-TIME:SECONDS.
LIGHTS ON.
LOG "" TO launchTime.ks.
DELETE launchTime.ks.
WAIT UNTIL dT <= 5.
HUDTEXT("5", 0.9, 2, 200, red, false).
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

WAIT UNTIL dT <= 4. HUDTEXT("4", 0.9, 2, 200, red, false).
WAIT UNTIL dT <= 3. HUDTEXT("3", 0.9, 2, 200, red, false).
SAS ON.
LOCK THROTTLE TO 1.
WAIT UNTIL dT <= 2. HUDTEXT("2", 0.9, 2, 200, red, false).
WAIT UNTIL dT <= 1. HUDTEXT("1", 0.9, 2, 200, red, false).

IF enginePreStart
{
        WAIT UNTIL dT <= 0.8.
        STAGE.
        WAIT UNTIL dT <= 0.2.
        LOCAL g IS SHIP:BODY:MU / SHIP:BODY:RADIUS^2.
        IF SHIP:MAXTHRUST < SHIP:MASS * g
        {
                print "Insufficient thrust "+round(SHIP:MAXTHRUST,2)+" vs "+round(SHIP:MASS*g,2).
                LOCK THROTTLE TO 0.
                LOCAL x IS 1/0.
        }
}
WAIT UNTIL dT <= 0.
GLOBAL t0 IS TIME:SECONDS.
STAGE.
Wait 0.0001.
DELETE launch.
LOG "GLOBAL t0 IS " + t0 + "." TO launchTime.ks.
