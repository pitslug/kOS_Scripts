// AGS Standard Functions Library
// Additional functions used to run launch and guidance
@LAZYGLOBAL OFF.

// Determine height of the current craft
FUNCTION shipHeight {
  LOCAL partList IS list().
  LIST PARTS IN partList.
  LOCK r3 TO FACING:FOREVECTOR.
  LOCAL highestPart TO 0.
  LOCAL lowestPart TO 0.
  FOR part in partList{
      LOCAL v TO part:position.
      LOCAL currentPart TO r3:x*v:x + r3:y*v:y + r3:z*v:z.
      IF currentPart > highestPart
          SET highestPart TO currentPart.
      ELSE IF currentPart < lowestPart
          SET lowestPart TO currentPart.
  }
  LOCAL height TO highestPart - lowestPart.
  RETURN height.
}


// Determine the current and maximum available thrust
FUNCTION TWRCalc {
  PARAMETER twr.
  LOCAL engList IS list().
  LOCAL currentThrust IS 0.
  LOCAL maximumThrust IS 0.
  LOCAL availableThrust IS 0.

  // Determine local Gravity
  GLOBAL g IS 0.
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


// CONVERT TIME TO D:HH:MM:SS
// COURTESY OF Farsyte and ElWanderer_KSP
FUNCTION convertTime {
  PARAMETER cTime.

  LOCAL hpd IS KUNIVERSE:HOURSPERDAY.
  LOCAL s TO FLOOR(cTime).
  LOCAL m TO FLOOR(s/60).
  SET s TO MOD(s,60).
  LOCAL h TO FLOOR(m/60).
  SET m TO MOD(m,60).
  LOCAL d TO FLOOR(h/hpd).
  SET h TO MOD(h,hpd).

  IF d = 0 {
    RETURN padZ(h) + ":" + padZ(m) + ":" + padZ(s).
  } ELSE {
    RETURN d + "days " + padZ(h) + ":" + padZ(m) + ":" + padZ(s).
  }

FUNCTION padZ {
  PARAMETER t.
    RETURN (""+t):PADLEFT(2):REPLACE(" ","0").
}




}

//declare function flameout{
//	LIST ENGINES IN mylist.
//	FOR eng IN mylist {
//		if eng:flameout{
//			local curstage to eng:stage.
//			local parentpart to eng:parent.
//
//			until not parentpart:hasparent{
//				if parentpart:modules:contains("ModuleAnchoredDecoupler") {
//					parentpart:getmodule("ModuleAnchoredDecoupler"):doevent("Decouple").
//					break.
//				}
//				else
//					set parentpart to parentpart:parent.
//			}
//		}
//	}
//  thrustCalc().
//  if maxTWR < 0.2 {
//    print "NEED TO STAGE".
//  }
//}
