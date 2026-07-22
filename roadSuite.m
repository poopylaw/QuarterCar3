function roadInput = roadSuite(roadCase, tEnd, dt)
% ROADSUITE Generate a named road displacement profile as a timeseries.
%
%   roadInput = roadSuite(roadCase) generates a 5-second road profile
%   sampled at dt = 0.001 s for the named road case.
%
%   Available road cases:
%       'speedBump'  - smooth 5 cm hump, 1.0-1.5 s
%       'pothole'    - smooth 5 cm dip, 1.0-1.5 s
%       'roughRoad'  - band-limited random noise, ~1 cm amplitude
%       'washboard'  - sinusoidal corrugation, ~2 cm amplitude
%       'twoBumps'   - two speed bumps in sequence

% Default simulation length and sample rate if not specified by caller
if nargin < 2
    tEnd = 5;
end
if nargin < 3
    dt = 0.001;
end

% Build the time vector and initialize the road profile to flat (0 m)
t = (0:dt:tEnd)';
road = zeros(size(t));

switch roadCase
    case 'speedBump'
        % Single smooth hump (half-sine pulse) starting at t=1.0s,
        % lasting 0.5s, peaking at 5cm.
        bumpStart = 1.0;
        bumpDuration = 0.5;
        bumpHeight = 0.05;
        idx = t >= bumpStart & t <= bumpStart + bumpDuration;      % time window of the bump
        tau = (t(idx) - bumpStart) / bumpDuration;                 % normalize time to [0,1] within the bump
        road(idx) = bumpHeight * sin(pi * tau);                    % half-sine shape: rises then falls smoothly

    case 'pothole'
        % Same shape as speedBump, but inverted (a dip instead of a hump)
        potholeStart = 1.0;
        potholeDuration = 0.5;
        potholeDepth = 0.05;
        idx = t >= potholeStart & t <= potholeStart + potholeDuration;
        tau = (t(idx) - potholeStart) / potholeDuration;
        road(idx) = -potholeDepth * sin(pi * tau);                 % negative sign = downward dip

    case 'roughRoad'
        % Random road noise, filtered to remove high-frequency content
        % so it looks like a realistic bumpy road rather than pure noise.
        rng(1);                                                     % fixed seed so results are repeatable
        noiseAmplitude = 0.01;
        rawNoise = noiseAmplitude * randn(size(t));                 % raw Gaussian noise, ~1cm amplitude
        [b, a] = butter(2, 10 / (1/dt/2));                          % 2nd-order low-pass filter, 10 Hz cutoff
        road = filtfilt(b, a, rawNoise);                            % zero-phase filtering (no time shift/delay)

    case 'washboard'
        % Continuous sinusoidal corrugation (like a washboard dirt road),
        % starting at t=1.0s and continuing for the rest of the simulation.
        washStart = 1.0;
        washAmplitude = 0.02;
        washFrequency = 4;                                          % oscillation frequency, [Hz]
        idx = t >= washStart;
        road(idx) = washAmplitude * sin(2*pi*washFrequency*(t(idx) - washStart));

    case 'twoBumps'
        % Two separate speed-bump pulses in sequence, used to test how
        % the suspension recovers/settles between successive events.
        bumpDuration = 0.5;
        bumpHeight = 0.05;
        bump1Start = 1.0;
        bump2Start = 2.5;

        % First bump
        idx1 = t >= bump1Start & t <= bump1Start + bumpDuration;
        tau1 = (t(idx1) - bump1Start) / bumpDuration;
        road(idx1) = bumpHeight * sin(pi * tau1);

        % Second bump
        idx2 = t >= bump2Start & t <= bump2Start + bumpDuration;
        tau2 = (t(idx2) - bump2Start) / bumpDuration;
        road(idx2) = bumpHeight * sin(pi * tau2);

    otherwise
        % Guard against typos/unsupported road case names
        error('Unknown roadCase: %s', roadCase);
end

% Package the generated profile as a Simulink-compatible timeseries,
% labeled with the road case name for easy identification downstream.
roadInput = timeseries(road, t);
roadInput.Name = roadCase;

end