CLEARSCREEN.
SET TERMINAL:BRIGHTNESS TO 0.85.

RUN ONCE ALGS_nav.
RUN ONCE ALGS_func.
RUN ONCE ALGS_vars.
RUN ONCE ALGS_settings.

RUN ALGS_display.

RUN ONCE ALGS_launch.

WAIT 1.

addMessage(mTime, "Launch Program Complete").
updateStatus("Program Complete").
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
WAIT 30.
