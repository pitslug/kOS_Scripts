// ###############
// ---DISCLAIMER--
// ###############
// THIS IS BY NO MEANS A PRECISE ORBIT PLACEMENT SCRIPT
// IT WILL USUALLY PUT YOUR CRAFT IN A 200 BY 140 ORBIT WITH NO POSSIBILITY TO SPECIFY HIGHER / LOWER ORBIT
// YOU _COULD_ ACHIEVE HIGHER ORBIT FIDDLING WITH THE waitpitch AND targetapoeta PARAMETERS THOUGH

// ###############
// -- IMPORTANT --
// ###############
// STAGING IS LEFT IN CONTROL OF THE PLAYER
// STAGE YOUR SECOND STAGE WHEN [CURRENT APOAPSIS] ETA IS EQUAL (OR A BIT MORE) TO [TARGET APOAPSIS] * 2

// -- EXAMPLE --
// TARGET APOPAPSIS ETA: 40
// CURRENT APOAPSIS ETA: 80 (OR A BIT MORE THAN THAT JUST TO BE SURE)

// FAILING TO DO SO AND STAGING TO EARLY WILL PROBABLY RESULT IN A HIGHLY ECCENTRIC ORBIT
// WHICH THE SCRIPT CAN'T COMPENSATE FOR

// ###############
// -- WARNING ---
// ###############
// * SHIP MUST HAVE A PRESMAT BAROMERER
// * SECOND STAGE TWR SHOULD BE AROUND 1 FOR OPTIMAL RESULTS

//@lazyglobal off.
clearscreen.

// in degrees, pitch inclination where craft will sit while waiting to match specified APOAPSIS ETA
// by increasing this value the script will apply a steeper climb
// allowing low TWR craft to reach orbit
// should be modified together with the targetapoeta parameter
parameter waitpitch is 40.
// in degrees, defaulted for Cape Canaveral
parameter targetinclination is 28.5.
// in seconds, APOAPSIS ETA the script will try to mantain (scaling down as orbital speed climbs)
// the default value somehow works for most crafts with a second stage TWR around 1
// increase this if your second stage has troubles to reach orbit precisely at apoapsis
parameter targetapoeta is 90.
// in degrees, Maximum correction the script will apply to surface prograde vector
// this is dampened when craft is in atmosphere to avoid overheating and structural failure
parameter maxcorrection is 30.


// inclination parameters accounting for launch site location
// stolen from another script I don't remember
if abs(targetinclination) < floor(abs(latitude)) or abs(targetinclination) > (180 - ceiling(abs(latitude))) {
    print "desired inclination impossible. ".
    print "magnitude must be larger than or equal to the ".
    print "current latitude of "+round(latitude,1)+" deg".
    print "and less than or equal to "+round(90+latitude)+" deg".
    print "use ctrl+c to cancel program and try again".
    print " ".
    wait until false.
}.

set launchloc to ship:geoposition.
set inertialazimuth to arcsin(max(min(cos(targetinclination) / cos(launchloc:lat),1),-1)).
set targetorbitspeed to sqrt(ship:body:mu / (200000+ship:body:radius)).
set rotvelx to targetorbitspeed*sin(inertialazimuth) - (6.2832*ship:body:radius/ship:body:rotationperiod).
set rotvely to targetorbitspeed*cos(inertialazimuth).
set azimuth to arctan(rotvelx / rotvely).
if targetinclination < 0 {set azimuth to 180-azimuth.}.


// program start
lock throttle to 1.

// clear tower
rcs off.
sas on.
wait until alt:radar > 100.
sas off.


// turn phase, craft will sit at [waitpitch] waiting to reach targetapoeta
set fullysteeredangle to 90 - waitpitch.
set atmp_ground to ship:sensors:pres.
set atmp_end to 0.

lock altitude to alt:radar.
lock atmp to ship:sensors:pres.
lock atmodensity to atmp / atmp_ground.
lock apoeta to max(0,eta:apoapsis).

lock first_phase_pitch to fullysteeredangle - (fullysteeredangle * atmodensity).
lock steering to heading(azimuth, 90 - first_phase_pitch).
// wait for specified apoapsis ETA
until apoeta >= targetapoeta {
    // store some variables for later use
    set endturn_altitude to altitude.
    set endturn_orbitspeed to ship:velocity:orbit:mag.
    set second_phase_pitch to first_phase_pitch.
    print "Target Apoapsis ETA (seconds): "+targetapoeta at (0,0).
    print "Current Apoapsis ETA (seconds): "+apoeta at (0,1).
}

clearscreen.


// APOAPSIS ETA PHASE
unlock first_phase_pitch.
unlock steering.
unlock atmodensity.
unlock atmp.

set atmoendaltitude to 110000.
set tolerance to targetapoeta * 0.5.

// calculate ship pitch based on surface prograde vector
lock shipangle to vang(ship:up:vector, ship:srfprograde:vector).

// this damps the correction based on the distance to the end of the atmosphere
// to prevent oversteering in atmosphere
lock correctiondamp to (altitude - endturn_altitude) / (atmoendaltitude - endturn_altitude).
lock mx to shipangle + (maxcorrection * correctiondamp).
lock mi to shipangle - (maxcorrection * correctiondamp).


// this decreases expected APO eta as orbital speed increases
lock orbitSpeedFactor to ((targetorbitspeed - ship:velocity:orbit:mag) / (targetorbitspeed - endturn_orbitspeed)).
lock tApoEta to targetapoeta * orbitSpeedFactor.

set ae to 0.
// calculate pitch correction
// apply a limit to correction down
// because overshooting is better than undershooting
lock correction to max(-maxcorrection*0.3,((tApoEta - ae) / tolerance) * maxcorrection).
// apply correction dampening
lock second_phase_pitch to max(mi,min(mx, shipangle - correction )).
// apply steering
lock steering to heading(azimuth, 90 - second_phase_pitch).

until alt:periapsis >= 140000 {
    // prevent program to fail if ship is falling down
    // by overriding apoeta
    if ship:verticalspeed > 0 {
        set ae to apoeta.
    } else {
        set ae to 0.
    }
    print "Target Apoapsis ETA (seconds): "+tApoEta at (0,0).
    print "Current Apoapsis ETA (seconds): "+apoeta at (0,1).
}

unlock throttle.
set ship:control:pilotmainthrottle to 0.
clearscreen.
rcs on.
sas on.
