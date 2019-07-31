clear all
close all
clc
warning off

%The idea of no rotational tracking but only tilt tracking is to put the
%panel's tilt axis normal to north-south, so that the panel is either
%facing up, south or north. This way we can ignore the elevation of the
%sun, as we assume that the SP is tilted with to the same angle as the suns
%elevation. What we can say now that is if the sun is at 180 compass
%degrees in azimuth (or 360) the panel faces the sun directly. ...


load azimuth %Load in the azimuth data
%elevationangles = azimuth; %Put the values in the 'elevationangles' variable
%data = importfile('SunEarthTools_AnnualSunPath_2018_1519894286943');
%save('angledata','data')
folder = 'C:\Dropbox\Saxion\4e jaar\EPS finland Floating Solar Park\EPS Floating Solar Park\numerical simulation\figures\';

basepower = 75; %Watt
timestep = 1; %in minutes
minutes = 1:1/60:24;
tic
mintilt = 0;
maxtilt = 90;
yearlyplot = 1;
dailyplot = 0;



maxpower = [];
totaldailyenergy = [];
Totalenergy = 0;
for i = 2:366
    strcat('current: ',num2str(i-1),'/365')
    angles = azimuth(i,:); %Load in elevation angle data of this day
    weights = (angles > -1);%find which values of the angles are used to fitting the curve
    fitted = fit((1:1:24)',angles','a.*x+b','weight',weights); %Fit the angles of the sun with a cubic interpolated fit
    minuteangles = fitted(minutes); %apply the fit to find the angles per minute
    minuteangles = abs(minuteangles - 180); %find the difference in azimuth angles of 180
    minuteangles(minuteangles>90) = 90; %set the maximum azimuth difference to 90 degrees
    
    
    %from here we calculate the energy produced per minute assuming perfect
    %weather condition
    efficiencies = cosd(angledif); %Calculate the efficiency of the panel regarding the angle of the sun on the panel
    power = basepower .* efficiencies; %multiply with base power to get power for every minute
    output = power .* 60; %Calculate total output
    Totalenergy = Totalenergy + sum(output); %summarize total output
    totaldailyenergy = [totaldailyenergy, sum(output)];
    maxpower = [maxpower, max(power)]; %remember the max power output of this day
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
    %saveas(gca, strcat(folder,'Total_power_per_day_yearly_rotational_tracking_tilt_tracking'),'png')
    figure('units','normalized','outerposition',[0 0 1 1])
    grid on
    hold on
    plot(1:365,maxpower)
    xlabel('days')
    ylabel('Max power output per day')
    title('Max power output per day of panel rated at 75W, each day of the year, rotating and tilting with the sun, assuming perfect weather conditions')
    %saveas(gca, strcat(folder,'Maximumn_power_output_per_day_rotational_tracking_tilt_tracking'),'png')
end

save('Total_daily_energy_per_day_rotational_tracking_tilt_tracking','totaldailyenergy')
save('Max_power_per_day_rotational_tracking_tilt_tracking','maxpower')

