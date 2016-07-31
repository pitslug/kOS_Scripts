// AGS Loader Script
// Initializes terminal and all dependencies then starts program.
@LAZYGLOBAL OFF.

CLEARSCREEN.
SET TERMINAL:BRIGHTNESS TO 0.85.
SET TERMINAL:WIDTH TO 50.
SET TERMINAL:HEIGHT TO 36.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

RUN ONCE AGS_nav.
RUN ONCE AGS_func.
RUN ONCE AGS_vars.
RUN ONCE AGS_settings.
RUN ONCE AGS_display.

launchSeqDisplay().

WAIT 1.

addMessage(mTime, "Launch Program Complete").
updateStatus("Program Complete").
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
WAIT 30.
