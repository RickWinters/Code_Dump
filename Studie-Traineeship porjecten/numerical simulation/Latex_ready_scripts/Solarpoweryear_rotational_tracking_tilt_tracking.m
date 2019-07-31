clear all
close all
clc
warning off
load elevationangles                                                        
% Load in the elevationangles data
elevationangles = angles;                                                   
% Put the values in the 'elevationangles' variable
folder = 'C:\Dropbox\Saxion\4e jaar\EPS finland Floating Solar Park\EPS Floating Solar Park\numerical simulation\figures\';

basepower = 75;                                                             
% Watt
timestep = 1;                                                               
% In minutes
minutes = 1:1/60:24;                                                        
% Array of minutes in a day
tic                                                                         
% Start timer
mintilt = 0;                                                                
% Minimun tilt of solar panel
maxtilt = 90;                                                               
% Maximum tilt of solar panel
yearlyplot = 1;                                                             
dailyplot = 0;

maxpower = [];                                                              
% Create an empty array of max power production per day
totaldailyenergy = [];                                                      
% Create an empty array of total energy production per day
Totalenergy = 0;                                                            
% Set Totalenergy to 0
for i = 2:366                                                               
    % Loop over all days of the year
    strcat('current: ',num2str(i-1),'/365')                                 
    % Update user over command window
    angles = elevationangles(i,:);                                          
    % Load in elevation angle data of this day
    weights = (angles > -1);                                                
    % Find which values of the angles are used to fitting the curve
    fitted = fit((1:1:24)',angles','cubicinterp','weight',weights);         
    % Fit the angles of the sun with a cubic interpolated fit
    minuteangles = fitted(minutes);                                         
    % Apply the fit to find the angles per minute
    ind = minuteangles < 0;                                                
    % Find where the sun hasnt risen yet
    SPangles = 90 - minuteangles;                                           
    % Inverse the angles so that 0 degree tilt is the panel on its side,
    % facing the horizon, which coincides with 0 degree elevation of the
    % sun
    SPangles(SPangles >= maxtilt) = maxtilt;                                
    % Limit the tilt of the panel to the maxtilt
    SPangles(SPangles <= mintilt) = mintilt;                                
    % Limit the tilt of the panel to the mintilt
    angledif = invangles - SPangles;                                        
    % Calculate the difference of the SPnormal and SUN, there might be a
    % difference because of tilt limitations
    angledif(ind) = 90;                                                     
    % Set the diff to 90 degrees when the sun hasn't risen yet, because
    % cosd(90) = 0,
   
    %from here we calculate the energy produced per minute assuming perfect
    %weather condition
    efficiencies = cosd(angledif);                                          
    % Calculate the efficiency of the panel regarding the angle of the sun
    % on the panel
    power = basepower .* efficiencies;                                      
    % Multiply with base power to get power for every minute
    output = power .* 60;                                                   
    % Calculate total output
    Totalenergy = Totalenergy + sum(output);                                
    % Summarize total output
    totaldailyenergy = [totaldailyenergy, sum(output)];                     
    % Keep track of totaldaily energy
    maxpower = [maxpower, max(power)];                                      
    % Remember the max power output of this day
    if dailyplot == 1
        figure('units','normalized','outerposition',[0 0 1 1])
        grid on
        hold on
        plot(minutes,efficiencies.*100)
        plot(minutes,SPangles);
        plot(minutes,angledif);
        plot(minutes,power);
        xlabel('Hours')
        ylabel('data')
        legend('eff','SPangles','angledif','power')
        title('eu')
    end
end
%After a year, plot the maximum power output vs of each day
if yearlyplot == 1
    figure('units','normalized','outerposition',[0 0 1 1])
    grid on
    hold on
    plot(1:365,totaldailyenergy)
    xlabel({'days';
        strcat('Total energy produced = ',num2str(Totalenergy),' (J)')})
    ylabel('Total energy produced')
    title(strcat('Total energy creation of panel rated at 75W, each day of the year, rotating and tilting with the sun, assuming perfect weather condition'))
    saveas(gca, strcat(folder,'Total_power_per_day_yearly_rotational_tracking_tilt_tracking'),'png')
    figure('units','normalized','outerposition',[0 0 1 1])
    grid on
    hold on
    plot(1:365,maxpower)
    xlabel('days')
    ylabel('Max power output per day')
    title('Max power output per day of panel rated at 75W, each day of the year, rotating and tilting with the sun, assuming perfect weather conditions')
    saveas(gca, strcat(folder,'Maximumn_power_output_per_day_rotational_tracking_tilt_tracking'),'png')
end

save('Total_daily_energy_per_day_rotational_tracking_tilt_tracking','Totaldailyenergy')
save('Max_power_per_day_rotational_tracking_tilt_tracking','Maxpower')

