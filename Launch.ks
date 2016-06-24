clearscreen.

lock g to earth:mu / (altitude + earth:radius)^2.
lock currentTWR to max(.001, ship:availablethrust/(ship:mass*g)).
lock twr to max(.001, ship:maxthrust/(ship:mass*g)).

set roll to 90.
set pitch to 90.
set azimuth to 90.

declare function countdown{

	SAS on.
	print "Commencing Countdown Sequence".
	wait 1.
	print "Lift-off in:".
	print "T-15s".
	wait 5.

	from{local x is 10.} until x = 0 step{ set x to x-1.} do{
		print "T-" + x + "s".
		if x = 5{
			lock throttle to 1.
			print "IGNITION".
			stage.
		}
		wait 1.
	}

	when currentTWR > 1 then {
		print "Engines are good. Launch is GO!".
		LOCK STEERING TO UP.
		stage.
	}

	when ALT:RADAR > 200 then {
		Print "Tower Clear. Engaging Guidance Control".
		wait 2.
	}
}


declare function guidance{

	print "Executing Roll Program".
	LOCK STEERING TO R(0,0,roll) + HEADING(azimuth,pitch).

}


function main{
	countdown().
	guidance().
}

main().
print "Program Complete".

wait 60.
