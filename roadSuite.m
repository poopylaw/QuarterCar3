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

if nargin < 2
    tEnd = 5;
end
if nargin < 3
    dt = 0.001;
end

t = (0:dt:tEnd)';
road = zeros(size(t));

switch roadCase
    case 'speedBump'
        bumpStart = 1.0;
        bumpDuration = 0.5;
        bumpHeight = 0.05;
        idx = t >= bumpStart & t <= bumpStart + bumpDuration;
        tau = (t(idx) - bumpStart) / bumpDuration;
        road(idx) = bumpHeight * sin(pi * tau);

    case 'pothole'
        potholeStart = 1.0;
        potholeDuration = 0.5;
        potholeDepth = 0.05;
        idx = t >= potholeStart & t <= potholeStart + potholeDuration;
        tau = (t(idx) - potholeStart) / potholeDuration;
        road(idx) = -potholeDepth * sin(pi * tau);

    case 'roughRoad'
        rng(1);
        noiseAmplitude = 0.01;
        rawNoise = noiseAmplitude * randn(size(t));
        [b, a] = butter(2, 10 / (1/dt/2));
        road = filtfilt(b, a, rawNoise);

    case 'washboard'
        washStart = 1.0;
        washAmplitude = 0.02;
        washFrequency = 4;
        idx = t >= washStart;
        road(idx) = washAmplitude * sin(2*pi*washFrequency*(t(idx) - washStart));

    case 'twoBumps'
        bumpDuration = 0.5;
        bumpHeight = 0.05;
        bump1Start = 1.0;
        bump2Start = 2.5;

        idx1 = t >= bump1Start & t <= bump1Start + bumpDuration;
        tau1 = (t(idx1) - bump1Start) / bumpDuration;
        road(idx1) = bumpHeight * sin(pi * tau1);

        idx2 = t >= bump2Start & t <= bump2Start + bumpDuration;
        tau2 = (t(idx2) - bump2Start) / bumpDuration;
        road(idx2) = bumpHeight * sin(pi * tau2);

    otherwise
        error('Unknown roadCase: %s', roadCase);
end

roadInput = timeseries(road, t);
roadInput.Name = roadCase;

end