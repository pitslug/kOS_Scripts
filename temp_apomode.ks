// Start active_mode
IF launchStatus = active_mode {

  ///////////////////////////////////
  // Start ACTIVE Guidance Control //
  ///////////////////////////////////

  LOCAL atmoEndAlt IS 140000.  // Was 110000
  LOCAL endturn_altitude IS 160000. //Was ALTITUDE
  LOCAL tolerance IS tgtApoETA * 0.5.
  LOCAL shipangle IS 0.
  LOCAL correctiondamp IS 0.
  LOCAL mx IS 0.
  LOCAL mi IS 0.
  LOCAL tApoEta is tgtApoETA.
  LOCAL ae IS 0.
  LOCAL correction IS 0.

  LOCAL targetorbitspeed IS sqrt(ship:body:mu / (tgtApo+ship:body:radius)).
  LOCAL endturn_orbitspeed IS ship:velocity:orbit:mag.


  lock shipangle to vang(ship:up:vector, ship:srfprograde:vector).
  lock correctiondamp to (altitude - endturn_altitude) / (atmoEndAlt - endturn_altitude).
  lock mx to shipangle + (maxcorrection * correctiondamp).
  lock mi to shipangle - (maxcorrection * correctiondamp).

  lock orbitSpeedFactor to ((targetorbitspeed - ship:velocity:orbit:mag) / (targetorbitspeed - endturn_orbitspeed)).
  lock tApoEta to tgtApoETA * orbitSpeedFactor.
  lock correction to max(-maxcorrection*0.3,((tApoEta - ae) / tolerance) * maxcorrection).

  lock tgtPitch to 90 - max(mi,min(mx, shipangle - correction )).
  LOCK STEERING TO HEADING(azimuth,tgtPitch) + R(0,0,tgtRoll).

  until ALT:periapsis >= tgtApo - 20000 {
      // prevent program to fail if ship is falling down
      // by overriding apoeta
      if ship:verticalspeed > 0 {
          set ae to apoeta.
      } else {
          set ae to 0.
      }

      PRINT ("Target Apo ETA:   " + ROUND(tApoEta,3)) AT (10,iCount).
      PRINT ("Current Apo ETA:  " + ROUND(apoETA,3)) AT (10,iCount + 1).
  }

  LOCK THROTTLE TO 0.
  SAS ON.


  SET launchStatus TO complete. // End Loops
  WAIT 0.001.


} // End active_mode
