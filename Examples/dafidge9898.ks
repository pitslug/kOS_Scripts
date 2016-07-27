/Aled 1.x launch coding

//clears the terminal
CLEARSCREEN.

//Launch sequence follows from t-60 seconds
PRINT "Counting down from T-60 Seconds".
Print "T-60 Seconds".
wait 15.
Print "T-45 Seconds".
wait 15.
Print "T-30 Seconds".
wait 15.
Print "T-15 Seconds".
wait 5.
Print "T-10 Seconds".
wait 1.
print "T-9 Seconds".
wait 1.
Print "T-8 Seconds".
wait 1.
print "T-7 Seconds".
wait 1.
Print "T-6 Seconds".
wait 1.
print "T-5 Seconds".
wait 1.
Print "T-4 Seconds".
wait 0.5.
stage.
print "Ignition. Throttling up".
Lock throttle to 1.0. //full throttle is 1.0 and idle is 0.0
wait 0.5.
print "T-3 Seconds".
wait 1.
Print "T-2 Seconds".
wait 1.
print "T-1 Second".
wait 1.
Stage.
print "Full Power".
Print "Liftoff!".

//self explanitory, right?
when ship:lqdoxygen <= 31657 then {
    stage. //jettison boosters
    print "T+"+round(missiontime)+" Seconds. Jettison Boosters".
}.

//also self explanitory?
when ship:lqdoxygen <= 10000 then {
    stage. //jettison LES
    print "T+"+round(missiontime)+" Seconds. Jettison Launch Escape System".
}.



//these next lines will activate staging when thrust is 0
//so the first stage can be jettisoned
when maxthrust = 0 then {
    print "T+"+round(missiontime)+" Seconds. MECO 1".
    wait 1.
    stage.
    print "T+"+round(missiontime)+" Seconds. Stage One Separation".
    print "Ullage and Retro Motors Firing".
}.

//this will ignite the upper stage engine while the ullage motors
//are firing
when ship:pspc <= 3 then {
    stage.
    print "T+"+round(missiontime)+" Seconds. Upper Stage Engine Ignition".
    wait 1.5.
    print "T+"+round(missiontime)+" Seconds. Upper Stage Engine is at Full Power".
}.






//pitch up 90 degrees and heading north (north because thats what the rocket starts out heading)
set mysteer to heading(0,90).
until ship:velocity:surface:mag >= 25 {
    lock steering to mysteer.
}.

//rolls the ship to 90 degrees and maintains the 90 degree attitude
print "T+"+round(missiontime)+" Seconds. Beginning Roll Program".
until ship:velocity:surface:mag >= 60 {
    set mysteer to heading(90,90).
    lock steering to mysteer.
}.

//start of gravity turn heading 90 degrees and pitch attitude of 75 degrees
when ship:velocity:surface:mag >= 60 and ship:velocity:surface:mag < 200 then {
    set mysteer to heading(90,75).
    lock steering to mysteer.
}.
wait 6.5.

print "T+"+round(missiontime)+" Seconds. Roll Program Complete".


//this will make the rocket follow prograde to minimize drag and for a proper ascent profile
//it stops doing this when the apoapsis is over 130k
//I admit, I could just hit lock steering to surface:velocity:prograde, but
//that wouldn't keep the ship pointed at a 90 degree heading
until ship:apoapsis >=130000 {
    lock steering to heading (90,arcsin(verticalspeed/airspeed)).
    if ship:apoapsis >130000 {
        break.
    }.
}.



//between following prograde and this point, the ship has been flying due east and at a pitch
//attidude of 3 degrees to prevent the apoapsis from getting too high. drag is no longer a factor
//at this altitude. it stops flying the 3 degree pitch attitude at kerosene <= 3270 because this is
//the level of fuel at which staging occurs.
until ship:kerosene <= 3270 {
    lock steering to heading (90-arctan(((((-orbit:inclination*constant:pi)/180)*sin(constant:pi*((180/constant:pi)*arccos(ship:latitude/orbit:inclination))/180)))),03).
}.

//rcs of the upper stage
when ship:kerosene <=3270 then{
    rcs on.
}.

//pitch up to increase the amount of time it take to reach the apoapsis, as well as raises it to 200km
until ship:apoapsis >= 200000 {
    lock steering to heading (90-arctan(((((-orbit:inclination*constant:pi)/180)*sin(constant:pi*((180/constant:pi)*arccos(ship:latitude/orbit:inclination))/180)))),30).
    if ship:apoapsis >200000 {
        break.
    }.
}.

//this keeps the spacecraft pointed down enough so that the apoapsis doesn't get too high, and high enough
//(at 3 degrees) to provide some slack to keep the orbit at or above 200km
until verticalspeed <= 3 {
    lock steering to heading (90-arctan(((((-orbit:inclination*constant:pi)/180)*sin(constant:pi*((180/constant:pi)*arccos(ship:latitude/orbit:inclination))/180)))),03).
    if verticalspeed <3 {
        break.
    }.
}.


//Points the ship in such a way that the heading is somewhat close to the prograde vector and the
//pitch attitude is angled up to keep the vertical speed constant
until ship:periapsis >= 140000 {
    lock steering to heading (90-arctan(((((-orbit:inclination*constant:pi)/180)*sin(constant:pi*((180/constant:pi)*arccos(ship:latitude/orbit:inclination))/180)))),-0.07+arcsin((mass/maxthrust)*(((3.986*10^14)/((6371000+ship:altitude)^2))-(orbit:velocity:orbit:mag^2/(6371000+ship:altitude))))).
    if ship:periapsis >= 140000 {
        break.
    }.
}.

//keeps the ship pointing straight down the prograde vector during last few m/s to orbit
lock steering to prograde.

//shuts down the engine at the propper height. there was some kind of glitch where
//the throttle would be at zero, but the engine would still be producing thrust, so
//I added an action group to shut the engine off in addition to locking the throttle to
//zero
when ship:periapsis >= 195000 then {
    lock throttle to 0.0.
    print "T+"+round(missiontime)+" Seconds. MECO 2".
    toggle ag2.
}.
wait 2.
Print "You are now in a "+round(ship:apoapsis)+" by "+round(ship:periapsis)+" meter orbit.".

//ends the program at T+12 minutes.
wait until missiontime>=720.
