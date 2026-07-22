function tuneResults = tuneSuspension()

setupQuarterCar;

assignin('base', 'Ms', Ms);
assignin('base', 'Mu', Mu);
assignin('base', 'Kt', Kt);
assignin('base', 'Ct', Ct);

KsRange = [12000, 14000, 16000, 18000, 20000];
CsRange = [1000, 1500, 2000, 2500, 3000];

comfortLimit = 2.0;
travelLimit = 0.08;
tireDeflLimit = 0.03;

roadCases = {'speedBump', 'pothole', 'roughRoad', 'washboard', 'twoBumps'};

sweepList = struct([]);

for KsIdx = 1:length(KsRange)
    for CsIdx = 1:length(CsRange)
        Ks = KsRange(KsIdx);
        Cs = CsRange(CsIdx);
        assignin('base', 'Ks', Ks);
        assignin('base', 'Cs', Cs);
        worstScore = -inf;
        allPass = true;
        for i = 1:length(roadCases)
            roadCase = roadCases{i};
            roadInput = roadSuite(roadCase);
            assignin('base', 'roadInput', roadInput);
            simIn = Simulink.SimulationInput('quarterCarModel');
            out = sim(simIn);
            results = scoreSuspension(out, roadCase);

            results.pass = results.comfortRMS <= comfortLimit && ...
                results.packagingMax <= travelLimit && ...
                results.roadHoldingMax <= tireDeflLimit;

            if results.score > worstScore
                worstScore = results.score;
            end

            if ~results.pass
                allPass = false;
            end
        end
        combo.Ks = Ks;
        combo.Cs = Cs;
        combo.worstScore = worstScore;
        combo.allPass = allPass;
        sweepList = [sweepList, combo];
    end
end
tuneResults = struct2table(sweepList);
disp(tuneResults);

sortedResults = sortrows(tuneResults, 'worstScore');
fprintf('\n--- Best combination (lowest worst-case score) ---\n');
disp(sortedResults(1,:));
end