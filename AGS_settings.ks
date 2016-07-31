// AGS Launch Settings
// List variables for launch parameters
// This may need to be ship specific - RENAME TI AGS_VESSEL
@LAZYGLOBAL OFF.

//Countdown Settings
GLOBAL cdTimer IS 15.  //Must be factor of 5.
GLOBAL cdIgnite IS 3.15.

// Set initial launch parameters
GLOBAL roll IS 180.
GLOBAL pitch IS 90.
GLOBAL azimuth IS 90.

//Set Targets
GLOBAL tgtApo IS 250000.

//Set Staging Conditions
// 1 = SRBs, 2 = Hot Stage, 3 = RCS
