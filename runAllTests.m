function summaryTable = runAllTests()

setupQuarterCar;

comfortLimit = 2.0;
travelLimit = 0.08;
tireDeflLimit = 0.03;

roadCases = {'speedBump', 'pothole', 'roughRoad', 'washboard', 'twoBumps'};


resultsList = struct([]);

for i=1:length(roadCases)
    roadCase = roadCases{i};
    roadInput = roadSuite(roadCase);
    assignin('base', 'roadInput', roadInput);

    simIn = Simulink.SimulationInput('quarterCarModel');
    out = sim(simIn);

    results = scoreSuspension(out, roadCase);

    results.pass = results.comfortRMS <= comfortLimit && ...
                    results.packagingMax <= travelLimit && ...
                    results.roadHoldingMax <= tireDeflLimit;

    resultsList = [resultsList, results];
end

summaryTable = struct2table(resultsList);
disp(summaryTable);

if ~exist('results', 'dir')
    mkdir('results');
end

figure;
bar(categorical(summaryTable.roadName), summaryTable.score);
ylabel('Score (lower = better)');
title('Suspension Score by Road Case');
saveas(gcf, fullfile('results', 'summaryPlot.png'));

save(fullfile('results', 'summaryTable.mat'), 'summaryTable');

end

