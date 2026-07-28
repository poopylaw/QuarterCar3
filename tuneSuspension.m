function tuneResults = tuneSuspension()
setupQuarterCar;
assignin('base', 'Kt', Kt); %use these so that all the variable are also found in the workspace 
assignin('base', 'Ct', Ct);
assignin('base', 'Ms', Ms);
assignin('base', 'Mu', Mu);

%set the Ks and Cs ranges so that the function can test each combination 
KsTestValues = [12000, 14000, 16000, 18000, 20000];
CsTestValues = [1000, 1500, 2000, 2500, 3000];

roadCases = {'speedBump', 'pothole', 'roughRoad', 'washboard', 'twoBumps'}; %create cell arrays for the 5 road cases
comfortLimit = 2.0; %setup the limit for comfortRMS, travel, and tireDefl
travelLimit = 0.08;
tireDeflLimit = 0.03;

tuneResults = struct([]); %create an empty struct named tuneResults

%create the initial loop for Ks  to loop through all of the set Ks
for KsIdx = 1:length(KsTestValues) %nested loops for Cs so that it tests each combination, make sure this is nested loop instead of two separate loops 
    for CsIdx = 1:length(CsTestValues)
        Ks = KsTestValues(KsIdx); %assign the variable to the actual values 
        Cs = CsTestValues(CsIdx);
        assignin('base', 'Ks', Ks); %connect these to the workspace 
        assignin('base', 'Cs', Cs);

        worstScore = 0; %set the worst score variable as the smallest possible number 
        allPass = true; %create a variable that is true 

        for i = 1:length(roadCases) %create another nested loop that goes through all the road cases in roadSuite 
            roadCase = roadCases{i};
            roadInput = roadSuite(roadCase);
            assignin('base', 'roadInput', roadInput);

            %start and run the simulation that was built 
            simPrep = Simulink.SimulationInput('quarterCarModel');
            simStart = sim(simPrep);

            %get the scores
            results = scoreSuspension(simStart, roadCase);

            %create a struct that has all the pass conditions
            results.pass = results.comfortRMS <= comfortLimit && ...
                results.packagingMax <= travelLimit && ...
                results.roadHoldingMax <= tireDeflLimit;

            %create if conditions to set it so that if the next value is a
            %worst score, it will get replaced
            if results.score > worstScore
                worstScore = results.score;
            end
            if ~results.pass
                allPass = false;
            end
        end

        %store everything into combo struct
        combo.Ks = Ks;
        combo.Cs = Cs;
        combo.worstScore = worstScore;
        combo.allPass = allPass;
        
        %create a tuneResults 
        tuneResults = [tuneResults, combo];
    end
end

%turn the sturct into a table, and pring out the table format
tuneResults = struct2table(tuneResults);
disp(tuneResults);
sortedResults = sortrows(tuneResults, 'worstScore');
fprintf('\n--- Best combination(lowest worst-case score) --- \n');
disp(sortedResults(1,:));

end