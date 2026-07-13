%% setupQuarterCar.m
clear; clc;

%% Masses
Ms = 300;      % Sprung mass, [kg]
Mu = 40;       % Unsprung mass, [kg]

%% Suspension parameters
Ks = 16000;    % Suspension spring stiffness, [N/m]
Cs = 1500;     % Suspension damping coefficient, [N*s/m]

%% Tire parameters
Kt = 190000;   % Tire stiffness, [N/m]
Ct = 100;      % Tire damping coefficient, [N*s/m]

%% Road input setup
roadCase = 'twoBumps';  % change to test: pothole, roughRoad, washboard, twoBumps
roadInput = roadSuite(roadCase);