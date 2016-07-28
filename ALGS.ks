CLEARSCREEN.
SET TERMINAL:BRIGHTNESS TO 0.85.

RUN ONCE ALGS_nav.
RUN ONCE ALGS_func.
RUN ONCE ALGS_vars.
RUN ONCE ALGS_settings.

SET launchStatus TO 0.

UNTIL launchStatus = 1 {

	RUN ALGS_display.
	RUN ONCE ALGS_launch.

}

WAIT 1.

addMessage(mTime, "Launch Program Complete").
updateStatus("Program Complete").
WAIT 30.
