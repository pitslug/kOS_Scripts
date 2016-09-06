// AGS Launch Settings
// List variables for launch parameters
// This may need to be ship specific - RENAME TI AGS_VESSEL
@LAZYGLOBAL OFF.

//Countdown Settings
GLOBAL cdTimer IS 20.  //Must be factor of 5.
GLOBAL cdIgnite IS 4.5.

// Set initial launch parameters
GLOBAL tgtRoll IS 180.
GLOBAL azimuth IS 90.

//Set Targets
GLOBAL tgtApo IS 185000.
GLOBAL tgtApoETA IS 90.

GLOBAL aoaLim IS 5.   // Limit Angle of Attack
GLOBAL maxCorrection IS 30.

GLOBAL stageTotal IS 3.
GLOBAL stageGroup IS 1.

//Set Staging Conditions
// 1 = SRBs, 2 = Hot Stage, 3 = RCS
