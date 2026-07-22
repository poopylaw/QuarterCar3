function summaryTable = runAllTests()
% RUNALLTESTS Run all road cases, score each, check pass/fail, save results.
%
%   summaryTable = runAllTests() runs the full road test suite against
%   quarterCarModel, scores each run using scoreSuspension, checks
%   pass/fail against design limits, and saves a summary table + plot
%   to a "results" folder.

% Load model parameters (Ms, Mu, Ks, Cs, Kt, Ct) from the setup script
setupQuarterCar;

% Pass/fail limits -- a road case only "passes" if it satisfies all three
comfortLimit  = 2.0;    % m/s^2, max acceptable RMS acceleration
travelLimit   = 0.08;   % m, max acceptable suspension travel
tireDeflLimit = 0.03;   % m, max acceptable tire deflection

roadCases = {'speedBump', 'pothole', 'roughRoad', 'washboard', 'twoBumps'};

resultsList = struct([]);   % will collect one result struct per road case

for i=1:length(roadCases)
    roadCase = roadCases{i};
    roadInput = roadSuite(roadCase);
    assignin('base', 'roadInput', roadInput);   % model reads roadInput from the base workspace

    % Run the simulation for this road case
    simIn = Simulink.SimulationInput('quarterCarModel');
    out = sim(simIn);

    % Score the results and check pass/fail against the limits above
    results = scoreSuspension(out, roadCase);
    results.pass = results.comfortRMS <= comfortLimit && ...
                    results.packagingMax <= travelLimit && ...
                    results.roadHoldingMax <= tireDeflLimit;

    resultsList = [resultsList, results];
end

% Combine all 5 road cases into one table and display it
summaryTable = struct2table(resultsList);
disp(summaryTable);

% Create a results folder (if it doesn't already exist) for saved outputs
if ~exist('results', 'dir')
    mkdir('results');
end

% Bar chart comparing score across road cases (lower score = better)
figure;
bar(categorical(summaryTable.roadName), summaryTable.score);
ylabel('Score (lower = better)');
title('Suspension Score by Road Case');
saveas(gcf, fullfile('results', 'summaryPlot.png'));

% Save the results table so it persists beyond this MATLAB session
save(fullfile('results', 'summaryTable.mat'), 'summaryTable');

end