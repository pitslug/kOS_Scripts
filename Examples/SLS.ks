declare parameter argAscendNode to 0.
declare parameter inclination to 0.
DECLARE GLOBAL lastSteerTime to 0.
DECLARE GLOBAL yawAngle to 0.
DECLARE GLOBAL pitchAngle to 0.
DECLARE GLOBAL rollAngle to 0.
DECLARE GLOBAL initialStageNumber to Stage:NUMBER.
DECLARE GLOBAL fairingMass to 8000.

DECLARE GLOBAL hasFairing to 1.


function getPitch
{
	set pitch to  90 - VANG(SHIP:FACING:FOREVECTOR, (ship:position - body:position)).
	return pitch.
}



function countdown
{
	parameter countdownTimer to 10.

	until countdownTimer < 1
	{
	print countdownTimer.
	set countdownTimer to countdownTimer - 1.

	if  countdownTimer < 8.5 AND countdownTimer > 7.5
	{set SHIP:CONTROL:MAINTHROTTLE to 1.}

	if  countdownTimer < 7.5 AND countdownTimer > 5.5
	{
		RCS OFF.
		SAS OFF.
	}

	if  countdownTimer < 3.5 AND countdownTimer > 2.5
	{activateStage.}
    wait 1.
	}
}.

function activateStage
{
	if initialStageNumber-Stage:NUMBER = 0
	{
		STAGE.
		print "Main engine start".
		return.
	}

	if initialStageNumber-Stage:NUMBER = 1
	{
		STAGE.
		print "Booster ignition and liftoff.".
		return.
	}

	if initialStageNumber-Stage:NUMBER = 2
	{
		SET booster TO SHIP:PARTSTAGGED("booster1")[0].
		set boosterThrust to booster:thrust.
		if boosterThrust < 800
		{
			STAGE.
			print "Booster seperation".
			return.
		}
	}

	if initialStageNumber-Stage:NUMBER  = 3 AND SHIP:ALTITUDE > 95000 AND hasFairing = 1
	{
		STAGE.
		print "Fairing seperation.".
		set fairingMass to 0.
		return.
	}

	if initialStageNumber-Stage:NUMBER  = 4
	{
	SET coreEngine TO SHIP:PARTSTAGGED("coreEngine")[0].
	set coreThrust to coreEngine:thrust.
	if coreThrust < 1
		{
			print "Core burnout".
			wait 3.
			STAGE.
			print "EUS seperation".
			wait 3.
			SET AG1 TO TRUE.
			print "Extending nozzles.".
			wait 3.
			STAGE.
			print "EUS engines activated.".
			return.
		}
	}
}

function getHeadingVec
{
	parameter headingAngle.

	set posVec to ship:position - body:position.
	set posVec:mag to 1.

	set eastVec to velocity:orbit.
	set eastVec:mag to 1.

	set westVec to -eastVec.

	set northVec to -vcrs(posVec,velocity:orbit).

	set southVec to -northVec.

	if headingAngle >= 0 AND headingAngle <= 90
	{
		parameter c to (sin(headingAngle))/(sin(135-headingAngle)).
		set headingVec to (c*eastVec)+((1.4142135-c)*northVec).
		set headingVec:mag to 1.
		return headingVec.
	}

	if headingAngle > 90 AND headingAngle <= 180
	{
		parameter c to (sin(headingAngle-90))/(sin(135-headingAngle+90)).
		set headingVec to (c*southVec)+((1.4142135-c)*eastVec).
		set headingVec:mag to 1.
		return headingVec.
	}

	if headingAngle > 180 AND headingAngle <= 270
	{
		parameter c to (sin(headingAngle-90))/(sin(135-headingAngle+180)).
		set headingVec to (c*westVec)+((1.4142135-c)*southVec).
		set headingVec:mag to 1.
		return headingVec.
	}

	if headingAngle > 180 AND headingAngle <= 270
	{
		parameter c to (sin(headingAngle-270))/(sin(135-headingAngle+270)).
		set headingVec to (c*northVec)+((1.4142135-c)*westVec).
		set headingVec:mag to 1.
		return headingVec.
	}

}

function getPitchTargetVec
{
	parameter pitchAngle.
	set posVec to ship:position - body:position.
    set vecNormal to vcrs(posVec,velocity:orbit).
    set vecHorizontal to -1 * vcrs(ship:position-body:position, vecNormal).

	set vecHorizontal:mag to 1.
	set posVec:mag to 1.

	parameter c to (sin(pitchAngle))/(sin(135-pitchAngle)).
	set targetVec to (c*posVec)+((1.4142135-c)*vecHorizontal).

	return targetVec.
}

function getVelocityPitch
{
	set posVec to ship:position - body:position.
    set vecNormal to vcrs(posVec,velocity:orbit).
    set vecHorizontal to -1 * vcrs(ship:position-body:position, vecNormal).
	set pitch to vang(headingVec,ship:velocity:surface).
	return pitch.
}

function steer
{
	parameter targetVec.
	parameter normalVec.
	parameter power.
	parameter time to 0.
	parameter yaw to 0.
	parameter pitch to 0.
	parameter roll to 0.

	parameter yawRate to 0.
	parameter pitchRate to 0.
	parameter rollRate to 0.

	set time to MISSIONTIME-lastSteerTime.
	if (time < 0.1)
	{
		wait 0.1-time.
		set time to MISSIONTIME-lastSteerTime.
	}

	set yawRate to (yawAngle - VECTORANGLE(targetVec,SHIP:FACING:STARVECTOR))/time.
	set pitchRate to (pitchAngle - VECTORANGLE(targetVec,SHIP:FACING:TOPVECTOR))/time.
	set rollRate to (rollAngle - VECTORANGLE(normalVec,SHIP:FACING:TOPVECTOR))/time.

	set lastSteerTime to MISSIONTIME.

	set yawAngle to VECTORANGLE(targetVec,SHIP:FACING:STARVECTOR).
	set pitchAngle to VECTORANGLE(targetVec,SHIP:FACING:TOPVECTOR).
	set rollAngle to VECTORANGLE(normalVec,SHIP:FACING:TOPVECTOR).

	set yaw to power*15*COS(yawAngle+(-2*yawRate)).
	set pitch to power*15*COS(pitchAngle+(-2*pitchRate)).
	set roll to power*4*COS(rollAngle+(-4*rollRate)).

	set ship:control:yaw to yaw.
	set ship:control:pitch to pitch.
	set ship:control:roll to roll.



}.

function simulateTrajectory
{
	parameter initialAltitude.
	parameter initialVelocity.
	parameter initialVelocityOrbit.
	parameter orbSrfDifference.
	parameter initialPitch.
	parameter initialPitchOrbit.
	parameter initialStage.
	parameter timestepBase.
	parameter stagePropellant.
	parameter stageThrust.
	parameter stageMass.
	parameter stageVe.
	parameter targetPitch1.
	parameter targetPitch2.

	parameter steerVec.
	parameter normalvec.
	parameter steerLockPitch.
	parameter steerTargetPitch.
	parameter hasFairing to 1.
	parameter coreDryMass to 115000.
	parameter currentStage to initialStage.


	parameter timestep to timestepBase.
	parameter time to 0.
	parameter EusStartTime to 9999.

	parameter accX to 0.
	parameter accY to 0.

	parameter posX to 0.
	parameter posY to initialAltitude.
	parameter radius to initialAltitude.
	parameter posXold to 0.
	parameter posYold to 0.
	parameter triggerstage to -1.

	parameter velX to Cos(initialPitchOrbit)*initialVelocityOrbit.
	parameter velY to Sin(initialPitchOrbit)*initialVelocityOrbit.
	parameter speed to 0.
	parameter velocityPitch to initialPitch.
	parameter srfOrbDifVelX to orbSrfDifference.
	parameter srfOrbDifVelY to 0.
	parameter surfaceVelX to Cos(initialPitch)*initialVelocity.
	parameter surfaceVelY to velY.

	parameter rocketDirX to 0.
	parameter rocketDirY to 0.
	parameter rocketPitch to -600.


	parameter GM to Body:MU.
	parameter orbitalEnergy to 0.
	parameter orbitalEnergyDif to 0.
	parameter potentialEnergy to 0.
	parameter printInfo to 0.
	parameter karmanline to 0.
	parameter finalStep to 0.
	until false
	{
		set timestep to timestepBase.
		if currentStage = 1 and stageThrust*timestep/stageVe > stagePropellant
		{
			set timestep to stageVe*stagePropellant/stageThrust.
			set EusStartTime to time+timestep+9.
			set triggerStage to 1.
		}
		if  currentStage = 1 and triggerStage > 0 AND EusStartTime < time+timestep
		{
			set timestep to EusStartTime-time.
			set triggerStage to 2.

		}
		if initialStage = 1 and currentStage = 2
		{
			set timestep to timestepBase*1.5.
		}
		if (speed+cos(rocketPitch)*stageVe*LN(stageMass/(stageMass-stageThrust*timestep/stageVe))) > SQRT(GM/radius)
		{

			set timestep to stageMass*stageVe*constant:e^(-(SQRT(GM)/(SQRT(radius)*stageVe)))*(constant:e^((SQRT(GM)/(SQRT(radius)*stageVe)))-constant:e^(speed/stageVe))/stageThrust*cos(rocketPitch).
			set finalStep to 1.
		}

		set accX to GM*(-posX-0.5*timestep*velX)/((posX^2+posY^2)^1.5).
		set accY to GM*(-posY-0.5*timestep*velY)/((posX^2+posY^2)^1.5).

		set orbitalEnergy to (velX^2+velY^2)/2-GM/radius.

		set posXold to (posX-0.5*timestep*velX).
		set posYold to (posY-0.5*timestep*velY).
		set posX to posX + VelX*timestep + accX*timestep^2.
		set posY to posY + VelY*timestep + accY*timestep^2.

		set velX to velX + accX*timestep.
		set velY to velY + accY*timestep.
		if timestep > 1
		{
		set orbitalEnergyDif to orbitalEnergy - ((velX^2+velY^2)/2-GM/SQRT(posX^2+posY^2)).
		set potentialEnergy to orbitalEnergyDif -GM/SQRT(posX^2+posY^2).
		set radius to -GM/potentialEnergy.
		set posX to posX*(radius/SQRT(posX^2+posY^2)).
		set posY to posY*(radius/SQRT(posX^2+posY^2)).
		}
		set velocityPitch to (posX*velX)+(posY*velY).
		set velocityPitch to velocityPitch/((posX^2 + posY^2)^0.5 * (velX^2 + velY^2)^0.5).
		set velocityPitch to ARCCOS(velocityPitch).

		if currentStage < 1.5 AND velocityPitch > 90-targetPitch1
		{
			set rocketPitch to targetPitch1.
		}
		else
		{
			set rocketPitch to targetPitch2.
		}

		if stageThrust > 0
		{
			if rocketPitch < -500
			{
				set radius to SQRT(posXold^2+posYold^2).
				set srfOrbDifVelX to orbSrfDifference*(posXold*cos(-90)+posYold*sin(-90))/radius.
				set sfrOrbDifVelY to orbSrfDifference*(-posXold*sin(-90)+posYold*cos(-90))/radius.

				set surfaceVelX to velX-srfOrbDifVelX.
				set surfaceVelY to velY-srfOrbDifVelY.


				set speed to SQRT(velX^2+velY^2).
				set rocketDirX to surfaceVelX / SQRT(surfaceVelX^2 + surfaceVelY^2).
				set rocketDirY to surfaceVelY / SQRT(surfaceVelX^2 + surfaceVelY^2).
			}
			else
			{
				set radius to SQRT(posXold^2+posYold^2).
				set rocketDirX to (posXold*cos(90-rocketPitch)+posYold*sin(90-rocketPitch))/radius.
				set rocketDirY to (-posXold*sin(90-rocketPitch)+posYold*cos(90-rocketPitch))/radius.
			}
			set posX to posX + rocketDirX*stageVe*((timestep-stageMass*stageVe/stageThrust)*LN(stageVe*stageMass/(stageVe*stageMass-stageThrust*timestep))+timestep).
			set posY to posY + rocketDirY*stageVe*((timestep-stageMass*stageVe/stageThrust)*LN(stageVe*stageMass/(stageVe*stageMass-stageThrust*timestep))+timestep).

			set velX to velX + rocketDirX*stageVe*LN(stageMass/(stageMass-stageThrust*timestep/stageVe)).
			set velY to velY + rocketDirY*stageVe*LN(stageMass/(stageMass-stageThrust*timestep/stageVe)).

			set stagemass to stagemass - (stageThrust*timestep/stageVe).
			set stagePropellant to stagePropellant - (stageThrust*timestep/stageVe).

			if triggerStage > 0
			{
				set stageMass to stageMass - coreDryMass.
				set stageVe to 462*9.81.
				set stagePropellant to 125190.
				set stageThrust to -1.
			}
		}
		if currentStage = 1 and triggerStage > 1.5 and triggerStage < 2.5
		{
			set stageThrust to 444000.
			set velX to velX + rocketDirX*200*9.81*LN((stageMass+6000)/(stageMass+5000)).
			set velY to velY + rocketDirY*200*9.81*LN((stageMass+6000)/(stageMass+5000)).
			set triggerStage to -1.
			set currentStage to 2.
			set EusStartTime to 99999.
			set rocketPitch to targetPitch2.
		}

		set radius to SQRT(posX^2+posY^2).
		if hasFairing > 0 AND radius > 646600
		{
			set stagemass to stagemass-fairingMass.
			set hasFairing to -1.
		}
		set speed to SQRT(velX^2+velY^2).
		set time to time+timestep.
		set printInfo to printInfo + 1.
		if printInfo > 20
		{

			if steerLockPitch = 1 {set steerVec to getPitchTargetVec(steerTargetPitch).} ELSE {set steerVec to ship:velocity:surface.}
			steer (steerVec,normalVec,0.25).
			set printInfo to 0.
		}
		if finalStep = 1 or speed >= SQRT(GM/radius)
		{
			set velocityPitch to (posX*velX)+(posY*velY).
			set velocityPitch to velocityPitch/((posX^2 + posY^2)^0.5 * (velX^2 + velY^2)^0.5).
			set velocityPitch to ARCCOS(velocityPitch).
			set speedVertical to sin(90-velocityPitch)*speed.
			break.
		}
		if time > 3600
		{
			print "time limit reached".
			break.
		}
		if radius/1000-6371 > 100 {set karmanline to 1.}
		if radius/1000-6371 < 95 and karmanline > 0.5
		{
			print "crashed".
			set speedVertical to sin(90-velocityPitch)*speed.
			break.
		}

	}
	parameter result to v(radius/1000-6371,speedVertical,stageMass).
	return result.
}

function analyseSimulation
{
	parameter corePitch.
	parameter EUSpitch.
	parameter result.
	parameter stepSize.
	parameter tweakSize.
	parameter success to 1.
	parameter newPitch to v(corePitch,EUSpitch,0).
	if result:x < 160
	{
		set newPitch:x to corePitch + stepSize.
		set success to 0.
	}
	if result:x > 200
	{
		set newPitch:x to corePitch - stepSize.
		set success to 0.
	}

	if result:y > 40
	{
		set newPitch:y to EUSpitch - stepSize.
		set success to 0.
	}
	if result:y < -40
	{
		set newPitch.y to EUSpitch + stepSize.
		set success to 0.
	}

	if success > 0.5
	{
		set newPitch:x to corePitch + tweakSize*(180-result:x)/150.
		set newPitch:y to EUSpitch + tweakSize*(-result:y)/100.
		set newPitch:z to 1.
		if abs(180-result:x) < 3 and abs(result:y) < 3
		{set newPitch:z to 2.}
	}
	return newPitch.
}

countdown.


set headingVec to getHeadingVec(90).
set steerVec to ship:position - body:position.
set steerVec:MAG to 1.
set normalVec to vcrs(headingVec,steerVec).
set headingVec:MAG to 0.16.
set pitchVec to steerVec + headingVec.

print "0".
activateStage.
until ship:velocity:surface:MAG > 20
{
steer(steerVec,-velocity:orbit,1).
wait 0.1.
}

Print "Roll and pitch.".
until ship:velocity:surface:MAG > 80
{
steer(steerVec,normalVec,1).
wait 0.1.
}

set p to 90.
until p < 83
{
	set p to vang(headingVec,ship:velocity:surface).
	steer(pitchVec,normalVec,1).
	wait 0.1.
}

print "Roll complete.".
print "Performing gravity turn.".

until initialStageNumber-Stage:NUMBER > 2
{
	set steerVec to ship:velocity:surface.
	steer(steerVec,normalVec,1).
	activateStage.
	wait 0.1.
}

print "Gravity turn complete, searching for optimal pitch.".
parameter lockPitch to 0.
set stageThrust to 9116000.
set corePitch to 25.
set EUSpitch to 25.
set targetPitch to 25.
set targetPitchEUS to 25.
set currentBestInfo to v(0,0,0).
set currentBest to 0.
parameter timestep to 10.
set propellantMass to 1.141*stage:lqdOxygen+0.07085*stage:lqdHydrogen.
until propellantMass < 1000
{
	set currentPitch to 90-VANG(ship:velocity:surface,(ship:position - body:position)).
	set currentPitchOrbit to 90-VANG(ship:velocity:orbit,(ship:position - body:position)).
	if lockPitch < 1 AND currentPitch < targetPitch
	{set lockPitch to 1.}
	if lockPitch = 1 {set steerVec to getPitchTargetVec(targetPitch).} ELSE {set steerVec to ship:velocity:surface.}



	steer(steerVec,normalVec,0.25).

	activateStage.
	set velocityPitch to getVelocityPitch.
	set currentRadius to ship:position - body:position.
	set propellantMass to 1.141*stage:lqdOxygen+0.07085*stage:lqdHydrogen.
	if propellantMass > 20514
	{
	set orbSrfDif to ship:velocity:orbit:mag - ship:velocity:surface:mag.
	print "==================".
	print "Trying pitch".
	print corePitch.
	print EUSpitch.
	print "==================".
	set trajectoryResult to simulateTrajectory(currentRadius:mag,ship:velocity:surface:mag,ship:velocity:orbit:mag,orbSrfDif,currentPitch,currentPitchOrbit,1,timestep,propellantMass,stageThrust,SHIP:MASS*1000,453*9.81,corePitch,EUSpitch, steerVec,NormalVec, lockPitch, targetPitch).
	set newPitch to analyseSimulation(corePitch,EUSpitch,trajectoryResult,0.75,1).
	if newPitch:z > 0.5
	{
		if trajectoryResult:z+2*missiontime > currentBest
		{
			clearScreen.
			print "New Solution found!".
			print "Core pitch: " + corePitch.
			print "EUS pitch: " + EUSpitch.
			print " ".
			print "Projected altitude:   " + trajectoryResult:x.
			print "Projected V-velocity: " + trajectoryResult:y.
			print "Projected IMLEO:      " + trajectoryResult:z.
			print " ".
			set currentBest to trajectoryResult:z+missiontime.
			set currentBestInfo to trajectoryResult.
			set targetPitch to newPitch:x.
			set targetPitchEUS to newPitch:y.
			set timestep to 4.
			if newPitch:z = 2 or timestep = 2.5
			{set timestep to 2.5.}
		}

	}
	set corePitch to newPitch:x.
	set EUSpitch to newPitch:y.
	}
	else
	{
		clearscreen.
		set burnOutTime to round(propellantMass*453*9.81/9116000).
		print "Core burnout in " + burnOutTime + " seconds!".
		print "Core pitch: " + targetPitch.
		print "EUS pitch: " + targetPitchEUS.
		print " ".
		print "Projected altitude:   " + currentBestInfo:x.
		print "Projected V-speed:    " + currentBestInfo:y.
		print "Projected IMLEO:      " + currentBestInfo:z.
	}
}

SET EUSengine TO SHIP:PARTSTAGGED("EUSengine")[0].
set EUSthrust to EUSengine:thrust.
until EUSthrust > 50
{
activateStage.
set EUSthrust to EUSengine:thrust.
wait 0.1.
}
wait 5.

until ship:velocity:orbit:mag > SQRT(BODY:MU/(ship:position - body:position):mag)-600
{
set steerVec to getPitchTargetVec(targetPitchEUS).
steer(steerVec,normalVec,0.25).
wait 0.1.
}
parameter firstEUSsim to 1.
parameter tweakSize to 2.
set stageThrust to 444000.
set timestep to 2.
until ship:velocity:orbit:mag > SQRT(BODY:MU/(ship:position - body:position):mag)-60
{
	set currentPitch to 90-VANG(ship:velocity:surface,(ship:position - body:position)).
	set currentPitchOrbit to 90-VANG(ship:velocity:orbit,(ship:position - body:position)).
	{set lockPitch to 1.}
	set steerVec to getPitchTargetVec(targetPitchEUS).
	if timestep = 1 and ship:velocity:orbit:mag > SQRT(BODY:MU/(ship:position - body:position):mag)-200
	{
		set timestep to 0.5.
		set tweakSize to 0.5.
		set currentBest to 0.3.
	}


	steer(steerVec,normalVec,0.25).
	set currentRadius to ship:position - body:position.
	set propellantMass to 1.141*stage:lqdOxygen+0.07085*stage:lqdHydrogen.

	set orbSrfDif to ship:velocity:orbit:mag - ship:velocity:surface:mag.
	print "==================".
	print "Trying pitch".
	print EUSpitch.
	print "==================".

	set trajectoryResult to simulateTrajectory(currentRadius:mag,ship:velocity:surface:mag,ship:velocity:orbit:mag,orbSrfDif,currentPitch,currentPitchOrbit,2,timestep,propellantMass,stageThrust,SHIP:MASS*1000,462*9.81,EUSpitch,EUSpitch, steerVec,NormalVec, lockPitch, targetPitchEUS).
	set newPitch to analyseSimulation(corePitch,EUSpitch,trajectoryResult,0.75,tweakSize).
	if firstEUSsim = 1
	{
		set firstEUSsim to 0.
		set currentBest to trajectoryResult:y.
	}

	if abs(trajectoryResult:y) < abs(currentBest)
	{
		clearScreen.
		print "New Solution found!".
		print "EUS pitch: " + EUSpitch.
		print " ".
		print "Projected altitude:   " + trajectoryResult:x.
		print "Projected V-velocity: " + trajectoryResult:y.
		print "Projected IMLEO:      " + trajectoryResult:z.
		print " ".
		set currentBest to trajectoryResult:y.
		set currentBestInfo to trajectoryResult.
		set targetPitch to newPitch:x.
		set targetPitchEUS to newPitch:y.
	}
	if abs(currentBest) < 0.05
	{set currentBest to 0.05.}

	set EUSpitch to newPitch:y.
}

clearScreen.
print "Final simulation complete.".
print " ".
Print "Final orbit projection".
print " ".
print "Projected altitude:   " + currentBestInfo:x.
print "Projected V-speed:    " + currentBestInfo:y.
print "Projected IMLEO:      " + currentBestInfo:z.
print " ".
print "EUS pitch locked too " + targetPitchEUS.

until ship:velocity:orbit:mag > SQRT(BODY:MU/(ship:position - body:position):mag)-5
{
set steerVec to getPitchTargetVec(targetPitchEUS).
steer(steerVec,normalVec,0.25).
}
SAS ON.
until ship:velocity:orbit:mag > SQRT(BODY:MU/(ship:position - body:position):mag)-0.05
{
}

set SHIP:CONTROL:MAINTHROTTLE to 0.
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
set SHIP:CONTROL:NEUTRALIZE to True.
print "Orbit acheived".
