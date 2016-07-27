@LAZYGLOBAL OFF.
ClearScreen.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

FUNCTION Clamp
{
        PARAMETER input, minVal, maxVal.
        RETURN MIN(maxVal, MAX(minVal, input)).
}
FUNCTION Deadzone
{
        PARAMETER input, minVal, maxVal, dead.
        IF minVal <= input AND input <= maxVal
        {
                return dead.
        }
        return input.
}

copy launch from 0.
RUN Launch(false, true).

LOCAL engine IS SHIP:PartsTagged("mainEngine")[0].
LOCAL engineModule IS engine:GetModule("ModuleEnginesRF").
FOR resource IN SHIP:Resources
{
    IF resource:Name = "Ethanol75" GLOBAL mainFuelRes TO resource.
    IF resource:Name = "LqdOxygen" GLOBAL mainOxRes TO resource.
}
LOCK mainFuel TO mainFuelRes:Amount * mainFuelRes:Density * 1000.
LOCK mainOx TO mainOxRes:Amount * mainOxRes:Density * 1000.
LOCK fuelRate TO engineModule:GetField("fuel flow").
LOCK dtBurnout TO (mainFuel+mainOx) / fuelRate.
LOCAL meco IS False.


clearscreen.
LOCAL alt0 TO ALT:RADAR.
LOCK tE TO TIME:SECONDS - t0.
LOCAL tLast IS tE.
LOCAL tMeco IS tE.
LOCAL dT IS 0.
LOCAL az IS 90.
LOCAL turnAltScale IS 100000.
LOCAL azNrm IS vcrs(SHIP:UP:FOREVECTOR,HEADING(az,0):FOREVECTOR):NORMALIZED.
LOCAL sumRErr IS 0.
LOCAL sumYErr IS 0.
LOCAL sumPErr IS 0.
LOCAL r2d IS (180/CONSTANT():PI).
LOCK rRate TO SHIP:ANGULARVEL*SHIP:FACING:FOREVECTOR * r2d.
LOCK yRate TO SHIP:ANGULARVEL*SHIP:FACING:TOPVECTOR * r2d.
LOCK pRate TO SHIP:ANGULARVEL*SHIP:FACING:STARVECTOR * r2d.

LOCAL kyP IS 0.15.
LOCAL kyI IS 0.0125.
LOCAL kyD IS -0.06.

LOCAL kpP IS 0.15.
LOCAL kpI IS 0.0125.
LOCAL kpD IS 0.06.

LOCAL krP IS 0.1.
LOCAL krI IS 0.
LOCAL krD IS 0.35.

LOCAL rcsMaxD IS 0.2.

LOCAL decayFactor IS 0.5.
LOCAL damp IS 1.
LOCAL tvec IS SHIP:UP:FOREVECTOR.

LOCAL controlYaw IS True.
LOCAL controlPitch IS True.
LOCAL controlRoll IS True.



SAS OFF.

LOCK orbitvec to VCRS(SHIP:UP:FOREVECTOR, azNrm).
LOCK curprograde to vxcl(SHIP:UP:FOREVECTOR, SHIP:PROGRADE:FOREVECTOR):NORMALIZED.
LOCK progradecorrect to (2*orbitvec*curprograde)*orbitvec - curprograde.

LOCAL render IS TRUE.

LOCAL mode IS 0.

WHEN SURFACESPEED >= 80 THEN
{
    HUDTEXT("Roll Complete", 2, 2, 50, green, false).
    SET mode TO 1.
    SET krP TO 0.075.
    SET krI TO 0.02.
    SET krD TO 0.03.
    SET sumRErr TO 0.
}

LOCAL etaAp IS 1000000.
WHEN fuelRate <> 0 AND dtBurnout < 5 THEN
{
    HUDTEXT("Terminal Guidance", 0.9, 2, 50, green, false).
    STAGE. // fairings
    SET damp TO 1.
    // stop any rolling
    SET krP TO 0.
    SET krI TO 0.
    SET krD TO krD * 2.

    WHEN dtBurnout <= dT THEN
    {
        HUDTEXT("MECO", 2, 2, 50, green, false).
        SET mode TO 2.
        SET meco TO True.
        SET controlRoll TO False.
        LOCK Throttle TO 0.
        engineModule:DoAction("shutdown engine", true).
        STAGE.  // discard booster

        SET tMeco TO tE.
        WHEN tE > tMeco + 2 THEN
        {
            RCS ON.
            SET kyP TO 0.05.
            SET kyI TO 0.
            SET kyD TO -0.3.

            SET kpP TO 0.05.
            SET kpI TO 0.
            SET kpD TO 0.3.

            SET etaAp TO tE + ETA:APOAPSIS.
            WHEN tE > (etaAp - 1) THEN
            {
                RCS OFF.
                STAGE.  // spin up
                WHEN tE > (etaAp + 3) THEN
                {
                    STAGE.  // fire 11x
                    WHEN tE > (etaAp + 19) THEN
                    {
                        STAGE.  // fire 3x
                        WHEN tE > (etaAp + 26) THEN
                        {
                            STAGE.  // fire 1x
                            SET mode to 9999.
                        }
                    }
                }
            }
        }
    }
}
LOCAL maxQ IS 0.

UNTIL FALSE
{
        SET dT TO tE - tLast.
        SET tLast TO tE.

    IF mode = 0
    {
        SET tvec TO HEADING(90,90):FOREVECTOR.
    }
    IF mode = 1
    {
        FOR resource IN SHIP:Resources
        {
            IF resource:Name = "Ethanol75" SET mainFuelRes TO resource.
            IF resource:Name = "LqdOxygen" SET mainOxRes TO resource.
        }

        LOCAL approxRho IS (Constant():E ^ (-SHIP:ALTITUDE / 10000)) * 1.22.
        LOCAL approxQ IS 0.5* SURFACESPEED*SURFACESPEED * approxRho / 1000.
        SET damp TO 1+(approxQ / 20).
        IF damp <= 1 SET damp TO 1.

        SET maxQ TO MAX(maxQ,approxQ).
        if render print "approxQ: " + round(approxQ,2)+"/"+round(maxQ,2)+"       " at (20,13).
        print "F: "+round(mainFuel,4)+", O: "+round(mainOx,4)+", rate: "+round(fuelRate,4)+"     " at (0,15).
        IF fuelRate <> 0 print "MECO in "+round(dtBurnout,1)+"s   " at (0,16).

        local fac to MAX(0.001,MIN(1,SQRT(ALTITUDE/turnAltScale))).
        SET tvec TO (1-fac)*UP:FOREVECTOR:NORMALIZED + fac*progradecorrect.
    }
    ELSE IF mode = 2
    {
        SET tvec TO curPrograde.
        PRINT "Time to Ap: " + round(etaAp-tE,1) + "                       " at(0,15).
    }
    ELSE IF mode = 9999
    {
        BREAK.
    }

        LOCAL pErr IS vang(SHIP:FACING:FOREVECTOR,vcrs(tvec,SHIP:FACING:STARVECTOR))-90.
        LOCAL rErr IS 90-vang(-SHIP:FACING:TOPVECTOR,azNrm).
        LOCAL yErr IS 90-vang(SHIP:FACING:FOREVECTOR,vcrs(tvec,SHIP:FACING:TOPVECTOR)).

        local decay is 1-(decayFactor*dT).
        set sumRErr to (sumRErr*decay) + (rErr*dT).
        set sumYErr to (sumYErr*decay) + (yErr*dT).
        set sumPErr to (sumPErr*decay) + (pErr*dT).

        LOCAL actPP IS kpP*pErr.
        LOCAL actPI IS kpI*sumPErr.
        LOCAL actPD IS kpD*pRate.
        LOCAL pInput IS Deadzone(Clamp((actPD+actPP+actPI)/damp,-1,1), -0.001, 0.001, 0).
    IF controlPitch     SET SHIP:CONTROL:PITCH to pInput.

        LOCAL actYP IS kyP*yErr.
        LOCAL actYI IS kyI*sumYErr.
        LOCAL actYD IS kyD*yRate.
        LOCAL yInput IS Deadzone(Clamp((actYD+actYP+actYI)/damp,-1,1), -0.001, 0.001, 0).
        IF controlYaw SET SHIP:CONTROL:YAW to yInput.

        LOCAL actRP IS krP*rErr.
        LOCAL actRI IS krI*sumRErr.
        LOCAL actRD IS krD*rRate.
        LOCAL rInput IS Deadzone(Clamp((actRD+actRP+actRI)/(damp*2),-1,1), -0.001, 0.001, 0).
        IF controlRoll SET SHIP:CONTROL:ROLL to rInput.


        print "T = "+round(tE,2)+"s, dT = "+round(dT,4)+"s    " at (0,0).
        IF render
        {
                print " Yaw P: "+round(yErr,4)+"  I: "+round(sumYErr,4)+"  D: "+round(yRate,4)+"        " at (0,6).
                print "Ptch P: "+round(pErr,4)+"  I: "+round(sumPErr,4)+"  D: "+round(pRate,4)+"        " at (0,7).
                print "Roll P: "+round(rErr,4)+"  I: "+round(sumRErr,4)+"  D: "+round(rRate,4)+"        " at (0,8).

        print "Roll Cmd "+round(rInput,4)+"        " at(0,10).
                print " Yaw Cmd "+round(yInput,4)+"         " at(0,11).
                print "Ptch Cmd "+round(pInput,4)+"        " at(0,12).
        print "Damp: " + round(damp,4)+"        " at (0,13).
        }
        TOGGLE render.

        WAIT 0.00001.
}
DELETE CORE:BootFileName.
