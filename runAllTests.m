function summaryTable = runAllTests() %create a function called runAllTests with summaryTable as output

setupQuarterCar; %run the setupQuarterCar.m file 

comfortLimit = 2.0; %setup the limit for comfortRMS, travel, and tireDefl
travelLimit = 0.08;
tireDeflLimit = 0.03;

roadCases = {'speedBump', 'pothole', 'roughRoad', 'washboard', 'twoBumps'}; %create cell arrays for the 5 road cases

resultsArray = struct([]); %create an empty struct array

for i = 1:length(roadCases) %use the for loop to loop through all the road cases

    roadCase = roadCases{i}; %road case variable loops through all of the road cases

    roadInput = roadSuite(roadCase); %create a variable to call each road cases in roadSuite.m

    assignin('base', 'roadInput', roadInput); %copy roadInput into the base workspace so it exists outside of the function

    simPrep = Simulink.SimulationInput('quarterCarModel'); %call the simulation called quarterCarModel
    simStart = sim(simPrep); %run the simulation 

    results = scoreSuspension(simStart, roadCase); %set a variable called result and use the scoreSuspension.m file to score each case

    results.pass = results.comfortRMS <= comfortLimit && ...
                    results.packagingMax <= travelLimit && ...
                    results.roadHoldingMax <= tireDeflLimit; %set pass in the result struct

    resultsArray = [resultsArray, results]; %create a new array for results and store them into the empty array created earlier

end

summaryTable = struct2table(resultsArray) %turn the array into table 

if ~exist('results', 'dir') %search for result directory, if it does no exists run the following
    mkdir('results'); %create directory named results
end

%create a plot with different labels
figure;
bar(categorical(summaryTable.roadName), summaryTable.score);
ylabel('Score (lower = better)');
title('Suspension Score by Road Case');
saveas(gcf, fullfile('results', 'summaryPlot.png'));
save(fullfile('results', 'summaryTable.mat'), 'summaryTable');

end