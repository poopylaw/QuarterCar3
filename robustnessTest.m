function robustResults = robustnessTest()
setupQuarterCar;
Ms = Ms * 1.25; %increase the sprung mass by +25% 

assignin('base', 'Ks', Ks); %use these so that all the variable are also found in the workspace 
assignin('base', 'Kt', Kt);
assignin('base', 'Cs', Cs);
assignin('base', 'Ct', Ct);
assignin('base', 'Ms', Ms);
assignin('base', 'Mu', Mu);

roadCases = {'speedBump', 'pothole', 'roughRoad', 'washboard', 'twoBumps'}; %create cell arrays for the 5 road cases
comfortLimit = 2.0; %setup the limit for comfortRMS, travel, and tireDefl
travelLimit = 0.08;
tireDeflLimit = 0.03;

robustResults = struct ([]); %create an empty struct

for i = 1:length(roadCases) %create a for loop to go through all the cases

    roadCase = roadCases{i}; %Cycles through each of the cases
    roadInput = roadSuite(roadCase);
    assignin('base', 'roadInput', roadInput); %link the variable into the workspace outside of the function

    %start and run the simulation that was built 
    simPrep = Simulink.SimulationInput('quarterCarModel');
    simStart = sim(simPrep);

    results = scoreSuspension(simStart, roadCase); %call the scoreSuspension function to score 

    results.pass = results.comfortRMS <= comfortLimit && ... %create conditions for passing
        results.packagingMax <= travelLimit && ...
        results.roadHoldingMax <= tireDeflLimit; 

    robustResults = [robustResults, results]; %storing the results into the empty struct that was built earlier
end

robustResults = struct2table(robustResults); %turn the struct into table
disp(robustResults); %display the table
passRate = sum(robustResults.pass)/height(robustResults); %calculate the pass rate
%print out the format
fprintf('Pass rate: %.0f%% (%d/%d road cases passed)\n', passRate*100, sum(robustResults.pass), height(robustResults));

end