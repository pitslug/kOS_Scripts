clearscreen.
set seekAlt to 15.
set done to false.
on ag9 { set done to true. }.

print "Does a hover script at " + seekAlt + "m AGL.".
print " ".
print "  Keys:".
print "     Action Group 1 : lower altitude by 1".
print "     Action Group 2 : raise altitude by 1".
print "     Action Group 3 : lower altitude by 10".
print "     Action Group 4 : raise altitude by 10".
print "     Action Group 5 : lower altitude by 100".
print "     Action Group 6 : raise altitude by 100".
print "     LANDING LEGS   : Deploy to exit script".
print " ".
print " Seek ALT_RADAR = ".
print "  Cur ALT_RADAR = ".


// load the functions I'm using:
run lib_pid.

on ag1 { set seekAlt to seekAlt - 1. preserve. }.
on ag2 { set seekAlt to seekAlt + 1. preserve. }.
on ag3 { set seekAlt to seekAlt - 10. preserve. }.
on ag4 { set seekAlt to seekAlt + 10. preserve. }.
on ag5 { set seekAlt to seekAlt - 100. preserve. }.
on ag6 { set seekAlt to seekAlt + 100. preserve. }.

set ship:control:pilotmainthrottle to 0.

// hit "stage" until there's an active engine:
until ship:availablethrust > 0 {
  wait 0.5.
  stage.
}.

// Call to update the display of numbers:
declare function display_block {
  declare parameter
    startCol, startRow. // define where the block of text should be positioned

	print round(seekAlt,2) + "m    " at (startCol,startRow).
	print round(alt_radar,2) + "m    " at (startCol,startRow+1).
}.

// hover against gravity:
lock Fg to ship:mass * body:mu /((ship:altitude + body:radius)^2).
lock am to vang(up:vector, ship:facing:vector).
lock alt_radar to alt:radar.
set T_star to 0.
lock throttle to T_star / ship:availablethrust.

// calculate initial hover PID gains
set wn to 1.
set zeta to 1.
set Kp to wn^2 * ship:mass.
set Kd to 2 * ship:mass * zeta * wn.
set Ki to 0.

set hoverPID to pid_init( Kp, Ki, Kd, -Fg, Fg ). // Kp, Ki, Kd vals.

gear on.  gear off. // on then off because of the weird KSP 'have to hit g twice' bug.

until gear {

	// update hover pid and thrust
	set Kp to wn^2 * ship:mass.
	set Kd to 2 * ship:mass * zeta * wn.
	set hoverPID to PID_update(hoverPID, Kp, Ki, Kd, -Fg, Fg ).
	set T_star to (pid_seek( hoverPID, seekAlt, alt_radar ) + Fg)/ cos(am).
	
	display_block(18,11).
	wait 0.001.
}.

set ship:control:pilotmainthrottle to throttle.
print "------------------------------".
print "Releasing control back to you.".
print "------------------------------".

