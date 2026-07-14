function results = scoreSuspension(simout, roadName)

accelElem = simout.yout.getElement('sprungAccel');
accel = accelElem.Values.Data;

suspElem = simout.yout.getElement('suspTravel');
suspTrav = suspElem.Values.Data;

tireElem = simout.yout.getElement('tireDeflection');
tireDefl = tireElem.Values.Data;

comfortRMS = rms(accel);
packagingMax = max(abs(suspTrav));
roadHoldingMax = max(abs(tireDefl));

results.roadName = roadName;
results.comfortRMS = comfortRMS;
results.packagingMax = packagingMax;
results.roadHoldingMax = roadHoldingMax;

score = (comfortRMS+packagingMax+roadHoldingMax);
results.score = score;

end