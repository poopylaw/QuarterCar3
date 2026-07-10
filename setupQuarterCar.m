%% setupQuarterCar.m
% Baseline quarter-car suspension setup
%
% This script defines the parameters for the quarter-car suspension
% model and creates the road displacement input used in Simulink. The model
% represents one vehicle corner using:
%
%   - Sprung mass: 1/4 vehicle body corner
%   - Unsprung mass: wheel assembly
%   - Suspension spring and damper
%   - Tire vertical compliance
%   - Road displacement input
%

clear; clc;

% Masses

Ms = 300;      % Sprung mass, [kg]
Mu = 40;       % Unsprung mass, [kg]

% Suspension parameters

Ks = 16000;    % Suspension spring stiffness, [N/m]
Cs = 1500;     % Suspension damping coefficient, [N*s/m]

% Tire parameters

Kt = 190000;   % Tire stiffness, [N/m]
Ct = 100;      % Tire damping coefficient, [N*s/m]
%% This is for Road input - Not sure if it works yet 
% The road input is a smooth 5 cm speed bump that starts at 1 second and
% lasts 0.5 seconds. The final variable, roadInput, is formatted as a
% timeseries so it can be used by the From Workspace block to drive the
% RoadActuator in the Simscape Multibody model.

%{
% Road input setup

tEnd = 5;          % Total simulation time, [s]
dt = 0.001;        % Time step, [s]
t = (0:dt:tEnd)';  % Time vector

% Start with a flat road
road = zeros(size(t));

% Smooth speed bump

bumpStart = 1.0;      % Time when bump begins, [s]
bumpDuration = 0.5;   % Duration of bump, [s]
bumpHeight = 0.05;    % Bump height, [m]

% Find the time range where the bump occurs
idx = t >= bumpStart & t <= bumpStart + bumpDuration;

% Normalize bump time from 0 to 1
tau = (t(idx) - bumpStart) / bumpDuration;

% Create a smooth half-sine bump
road(idx) = bumpHeight * sin(pi * tau);

% Create road input for Simulink - This variable is used by the From Workspace block in Simulink
roadInput = timeseries(road, t);
%}