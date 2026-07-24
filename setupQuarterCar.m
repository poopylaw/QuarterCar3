clear; clc; %clear all the previous data and start fresh everytime this is called

Ms = 300; %set sprung mass
Mu = 40; %set unsprung mass

Ks = 12000; %set suspension spring stiffness
Cs = 1000; %set suspension damping coefficient

Kt = 190000; % set tire stiffness
Ct = 100; %set tire damping coefficient 

roadCase = 'twoBumps'; %choose the road case input
roadInput = roadSuite(roadCase); %run the roadSuite that has the road case in the switch case