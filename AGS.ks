// AGS Loader Script
// Initializes terminal and all dependencies then starts program.
@LAZYGLOBAL OFF.

CLEARSCREEN.
SET TERMINAL:BRIGHTNESS TO 0.85.
SET TERMINAL:WIDTH TO 54.
SET TERMINAL:HEIGHT TO 54.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

RUN ONCE AGS_nav.
RUN ONCE AGS_func.
RUN ONCE AGS_vars.
RUN ONCE AGS_settings.
RUN ONCE AGS_display.

launchSeqDisplay().
