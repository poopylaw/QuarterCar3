function roadData = roadSuite(roadCase) %set the initial function with input called "roadData" and roadSuite as the name

t = [0:0.001:5]; %set the time vector so that it is between 0 to 5 seconds with 0.001 second steps

road = zeros(size(t)); %create a zero vector named road with size of the time vector

switch roadCase %create a switch case function so that when different road cases are inputted, it will have different effects

    case 'speedBump'
        bumpStart = 1.0; %start time is 1 second into the imulation
        bumpDuration = 0.5; %this bump's duration is 0.5 second
        bumpHeight = 0.05; %set the height of the bump
        idx = t >= bumpStart & t <= bumpStart + bumpDuration; %get all the values where its true
        x = (t(idx) - bumpStart) / bumpDuration; %Use this to get how much of the bump is already passed in percentage
        road(idx) = bumpHeight * sin(pi*x); %takes just the true values from idx and calculate the height at each instance

    case 'pothole'
        dipStart = 1.0; %start time is 1 second into the simulation
        dipDuration = 0.5; %this dip's duration is 0.5 second
        pothole = 0.05; %set the dip of the pothole
        idx = t >= dipStart & t <= dipStart + dipDuration; %get all the values where its true
        x = (t(idx) - dipStart) / dipDuration; %Use this to get how much of the bump is already passed in percentage
        road(idx) = pothole * (-sin(pi*x)); %takes just the true values from idx and calculate the dip at each instance

    case 'roughRoad'
        randomHeight = 0.01;
        randomValues = (rand(size(t))-0.5) * 2 * randomHeight;
        road = movmean(randomValues, 50);

    case 'washboard'
        washStart = 1.0; %start time is 1 second into the imulation
        washHeight = 0.02; %set the height of the bump
        washFrequency = 4; %set the frequency
        idx = t >= washStart; %bumps occurs repeatedly, so all the times after bump starts stores into idx
        x = t(idx)-washStart;
        road(idx) = washHeight * sin(2*pi*x*washFrequency); %changes sin function so that bumps occurs repeatedly as time goes on, and uses the set frequency


    case 'twoBumps'
        firstBumpStart = 1.0; %first bump starts at 1 second
        firstBumpDuration = 0.5; %first bump duration is 0.5 seconds
        firstBumpHeight = 0.05; %first bump height is 0.05 cm

        idx = t >= firstBumpStart & t <= firstBumpStart + firstBumpDuration; %Use the same logic as 'speed bump' case
        x = (t(idx) - firstBumpStart) / firstBumpDuration;
        road(idx) = firstBumpHeight * sin(pi*x);

        secondBumpStart = 2.0; %The first bump completes after 1.5 seconds, set second bump start at 2 seconds so it logically makes sense 
        secondBumpDuration = 0.5;
        secondBumpHeight = 0.05;

        idx = t >= secondBumpStart & t <= secondBumpStart + secondBumpDuration; %Same concept as above
        x = (t(idx) - secondBumpStart) / secondBumpDuration;
        road(idx) = secondBumpHeight * sin(pi*x);
    otherwise
        error('Unknown road case') %if none of the given cases are inputted, error will show and program will stop running 
end


roadData = timeseries(road, t); %takes the time and the road case and packages it into one singular object
end