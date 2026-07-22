function results = scoreSuspension(simout, roadName) %function pulled from instructions

accelElem = simout.yout.getElement('sprungAccel'); %set accelElem as a variable, then use parameter name with getElement to get sprungAccel elements only
accel = accelElem.Values.Data; %this gives the raw numeric data from sprungAccel

tireElem = simout.yout.getElement('tireDeflection'); %same principle as sprungAccel
tireDefl = tireElem.Values.Data;

suspElem = simout.yout.getElement('suspTravel'); %same principle as sprungAccel
suspTrav = suspElem.Values.Data;

comfortRMS = rms(accel); %use the rms function to get the comfortRMS from accel data
packagingMax = max(abs(suspTrav)); %use the max function to get the max packaging from suspTrav data, and abs to ensure that only positive numbers are taken 
roadHoldingMax = max(abs(tireDefl));%use the max function to get the max road holding from road holding data, and abs to ensure that only positive numbers are taken

%create a struct named results and store all the data in the struct
results.roadName = roadName;
results.comfortRMS = comfortRMS;
results.packagingMax = packagingMax;
results.roadHoldingMax = roadHoldingMax;

%add up the scores from comfortRMS, packagingMax, and roadHoldingMax
score = comfortRMS + packagingMax + roadHoldingMax;
%put score in the results struct as well
results.score = score;

end