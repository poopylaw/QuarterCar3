function results = scoreSuspension(simout, roadName)
% SCORESUSPENSION Compute objective metrics from a quarter-car sim run.
%
%   results = scoreSuspension(simout, roadName) pulls the logged
%   sprung-mass acceleration, suspension travel, and tire deflection
%   signals out of simout, computes comfort/packaging/road-holding
%   metrics, and returns them along with a combined score.

% Pull sprung-mass acceleration signal out of the sim output
accelElem = simout.yout.getElement('sprungAccel');
accel = accelElem.Values.Data;

% Pull suspension travel signal out of the sim output
suspElem = simout.yout.getElement('suspTravel');
suspTrav = suspElem.Values.Data;

% Pull tire deflection signal out of the sim output
tireElem = simout.yout.getElement('tireDeflection');
tireDefl = tireElem.Values.Data;

% Comfort metric: RMS of sprung-mass acceleration
comfortRMS = rms(accel);
% Packaging metric: max suspension travel (absolute value)
packagingMax = max(abs(suspTrav));
% Road-holding metric: max tire deflection (absolute value)
roadHoldingMax = max(abs(tireDefl));

% Package everything into the output struct
results.roadName = roadName;
results.comfortRMS = comfortRMS;
results.packagingMax = packagingMax;
results.roadHoldingMax = roadHoldingMax;

% Combined score: lower is better, sum of all three metrics
score = (comfortRMS+packagingMax+roadHoldingMax);
results.score = score;
end