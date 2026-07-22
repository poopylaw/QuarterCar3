function tuneResults = tuneSuspension()
% TUNESUSPENSION Sweep Ks and Cs, score worst-case across all road cases,
% and identify the best-performing combination.
%
%   tuneResults = tuneSuspension() runs a parameter sweep over suspension
%   spring stiffness (Ks) and damping (Cs), evaluates each combination
%   against all 5 road cases, and scores each combination by its WORST
%   (max) score across those road cases -- so a combination that fails
%   badly on even one road case is penalized, even if it looks good on
%   average. The best combination (lowest worst-case score) is printed
%   at the end.

% Load fixed parameters (Ms, Mu, Ks, Cs, Kt, Ct) from the setup script.
% NOTE: setupQuarterCar clears the workspace, so it must run first.
setupQuarterCar;

% Push the fixed (non-swept) parameters to the base workspace so the
% model can see them throughout the sweep, regardless of what state the
% base workspace was in beforehand.
assignin('base', 'Ms', Ms);
assignin('base', 'Mu', Mu);
assignin('base', 'Kt', Kt);
assignin('base', 'Ct', Ct);

% Ranges of suspension stiffness/damping to sweep (5 values each = 25
% combinations total)
KsRange = [12000, 14000, 16000, 18000, 20000];   % N/m
CsRange = [1000, 1500, 2000, 2500, 3000];        % N*s/m

% Same pass/fail limits used elsewhere in the project
comfortLimit = 2.0;
travelLimit = 0.08;
tireDeflLimit = 0.03;

roadCases = {'speedBump', 'pothole', 'roughRoad', 'washboard', 'twoBumps'};
sweepList = struct([]);   % will collect one result per Ks/Cs combination

% Outer loop: iterate over every Ks value
for KsIdx = 1:length(KsRange)
% Inner loop: iterate over every Cs value for the current Ks
% (together these two loops test every possible Ks/Cs pairing)
for CsIdx = 1:length(CsRange)
        Ks = KsRange(KsIdx);
        Cs = CsRange(CsIdx);
        assignin('base', 'Ks', Ks);
        assignin('base', 'Cs', Cs);

        % Reset trackers for this specific Ks/Cs combination
        worstScore = -inf;    % will hold the highest (worst) score seen across road cases
        allPass = true;       % will flip to false if any road case fails

% Innermost loop: run all 5 road cases for this Ks/Cs combination
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

            % Track the worst (highest) score seen so far for this combo
if results.score > worstScore
                worstScore = results.score;
end
            % If this road case failed, mark the whole combo as failed
if ~results.pass
                allPass = false;
end
end

        % Save this combination's summary (Ks, Cs, worst score, pass/fail)
        combo.Ks = Ks;
        combo.Cs = Cs;
        combo.worstScore = worstScore;
        combo.allPass = allPass;
        sweepList = [sweepList, combo];
end
end

% Combine all 25 combinations into one table and display it
tuneResults = struct2table(sweepList);
disp(tuneResults);

% Sort by worst-case score (ascending) and report the best combination
sortedResults = sortrows(tuneResults, 'worstScore');
fprintf('\n--- Best combination (lowest worst-case score) ---\n');
disp(sortedResults(1,:));
end