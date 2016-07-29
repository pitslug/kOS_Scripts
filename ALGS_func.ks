// ALGS Standard Functions Library
// Additional functions used to run launch and guidance


// Determine height of the current craft
FUNCTION shipHeight {
  LIST PARTS IN partList.
  LOCK r3 TO FACING:FOREVECTOR.
  SET highestPart to 0.
  SET lowestPart to 0.
  FOR part in partList{
      SET v TO part:position.
      SET currentPart to r3:x*v:x + r3:y*v:y + r3:z*v:z.
      IF currentPart > highestPart
          SET highestPart to currentPart.
      ELSE IF currentPart < lowestPart
          SET lowestPart to currentPart.
  }
  SET height TO highestPart - lowestPart.
  RETURN height.
}


// Determine the current and maximum available thrust
FUNCTION TWRCalc {
  PARAMETER twr.
  LOCAL currentThrust is 0.
  LOCAL maximumThrust is 0.
  LOCAL availableThrust is 0.

  // Determine local Gravity
  LOCK g TO EARTH:MU / (ALTITUDE + EARTH:RADIUS)^2.

  LIST ENGINES IN engList.
  FOR eng in engList {
    SET currentThrust TO currentThrust + eng:THRUST.
    IF eng:IGNITION = TRUE AND eng:FLAMEOUT = FALSE {
      SET maximumThrust TO maximumThrust + eng:MAXTHRUST.
    }
  }
  IF twr = "current"
    RETURN (currentThrust/(SHIP:MASS*g)).
  IF twr = "maximum"
    RETURN (maximumThrust/(SHIP:MASS*g)).
}




//declare local function flightreadout{
//	print "==============================="  at (0,1).
//	print "========Flight Computer========"  at (0,2).
//	print "==============================="  at (0,3).
//	print "Vessel Status: " + status + "                             " at (0,4).
//	print "Vessel Statistics:"               at (0,5).
//	print "Current TWR:    "+ currentTWR     at (0,6).
//	print "Current Mass:   "+ ship:mass      at (0,7).
//	print "Heading:        " + azimuth       at (0,8).
//	print "Current Vel:    " + ship:airspeed at (0,9).
//}

declare function flameout{
	LIST ENGINES IN mylist.
	FOR eng IN mylist {
		if eng:flameout{
			local curstage to eng:stage.
			local parentpart to eng:parent.

			until not parentpart:hasparent{
				if parentpart:modules:contains("ModuleAnchoredDecoupler") {
					parentpart:getmodule("ModuleAnchoredDecoupler"):doevent("Decouple").
					break.
				}
				else
					set parentpart to parentpart:parent.
			}
		}
	}
  thrustCalc().
  if maxTWR < 0.2 {
    print "NEED TO STAGE".
  }
}
