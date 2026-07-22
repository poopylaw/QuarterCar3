function robustResults = robustnessTest()
% ROBUSTNESSTEST Evaluate the tuned suspension design under a +25%
% payload increase, to check whether the design chosen in Task 5 still
% holds up under a heavier sprung mass (e.g. extra passengers/cargo).
%
%   robustResults = robustnessTest() reruns all 5 road cases using the
%   tuned Ks/Cs values (loaded from setupQuarterCar), with sprung mass
%   increased by 25%, and reports pass/fail metrics + overall pass rate.

% Load baseline parameters (including tuned Ks=12000, Cs=1000), then
% override sprung mass to simulate a 25% heavier payload
setupQuarterCar;
Ms = Ms * 1.25;
assignin('base', 'Ms', Ms);   % push the increased mass to the base workspace so the model uses it

% Same pass/fail limits used throughout the project (Tasks 4 and 5)
comfortLimit = 2.0;
travelLimit = 0.08;
tireDeflLimit = 0.03;

roadCases = {'speedBump', 'pothole', 'roughRoad', 'washboard', 'twoBumps'};
resultsList = struct([]);   % will collect one result struct per road case

for i = 1:length(roadCases)
    roadCase = roadCases{i};
    roadInput = roadSuite(roadCase);
    assignin('base', 'roadInput', roadInput);   % model reads roadInput from the base workspace

    % Run the simulation with the current (heavier) parameters
    simIn = Simulink.SimulationInput('quarterCarModel');
    out = sim(simIn);

    % Score this road case's results and check pass/fail
    results = scoreSuspension(out, roadCase);
    results.pass = results.comfortRMS <= comfortLimit && ...
        results.packagingMax <= travelLimit && ...
        results.roadHoldingMax <= tireDeflLimit;

    resultsList = [resultsList, results];
end

% Combine all 5 road cases into one table and display it
robustResults = struct2table(resultsList);
disp(robustResults);

% Overall pass rate: fraction of road cases that passed all 3 limits
% under the increased payload -- this is the key robustness metric
passRate = sum(robustResults.pass) / height(robustResults);
fprintf('Pass rate: %.0f%% (%d/%d road cases passed)\n', passRate*100, sum(robustResults.pass), height(robustResults));

% Save results to disk so they persist beyond this MATLAB session
if ~exist('results', 'dir')
    mkdir('results');
end
save(fullfile('results', 'robustResults.mat'), 'robustResults');

end