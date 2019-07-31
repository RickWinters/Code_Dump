clear all
close all
clc
warning off
load elevationangles %Load in the elevationangles data
load angledata
azimuthcolumns = 3:2:49;
for i = 2:366
    for j = 1:length(azimuthcolumns)
        if data{i,azimuthcolumns(j)} == '--'
            azimuth(i,j) = -1;
        else
            azimuth(i,j) = data{i,azimuthcolumns(j)};
        end
    end
end



%%
elevationangles = angles; %Put the values in the 'elevationangles' variable
%data = importfile('SunEarthTools_AnnualSunPath_2018_1519894286943');
%save('angledata','data')
folder = 'C:\Dropbox\Saxion\4e jaar\EPS finland Floating Solar Park\EPS Floating Solar Park\numerical simulation\figures\';

basepower = 75; %Watt
timestep = 1; %in minutes
minutes = 1:1/60:24;
SPangle = 0:1:90; %array of angles of the solar panel
tic


parfor u = 1:91
    Totalenergy(u) = 0;
    maxpower = [];
    for i = 2:366
        strcat('current: ',num2str(SPangle(u)),' deg    days',num2str(i),'/365')
        angles = elevationangles(i,:); %Load in elevation angle data of this day
        weights = (angles > -1);%find which values of the angles are used to fitting the curve
        fitted = fit((1:1:24)',angles','cubicinterp','weight',weights); %Fit the angles of the sun with a cubic interpolated fit
        minuteangles = fitted(minutes); %apply the fit to find the angles per minute
        ind = minuteangles < 0; %find where the sun hasnt risen yet 
        SPangles = minuteangles + SPangle(u); %apply the rotation of the solar panel
        SPangles(SPangles>90) = 90 - (SPangles(SPangles>90)-90); %make sure the angle goes down again
        SPangles(ind) = 0;
        %from here we calculate the energy produced per minute assuming perfect
        %weather condition
        efficiencies = 1 - cosd(SPangles); %Calculate the efficiency of the panel regarding the angle of the sun on the panel
        power = basepower .* efficiencies; %multiply with base power to get power for every minute
        output = power .* 60; %Calculate total output
        Totalenergy(u) = Totalenergy(u) + sum(output); %summarize total output
        maxpower = [maxpower, max(power)]; %remember the max power output of this day
    end
    %After a year, plot the maximum power output vs of each day
    figure('units','normalized','outerposition',[0 0 1 1])
    grid on
    hold on
    plot(1:365,maxpower)
    xlabel('days')
    ylabel('Maximum power output')
    legend('power (W)')
    title(strcat('Maximum power output of panel rated at 75W, each day of the year, at ',num2str(SPangle(u)),' degree, rotating with the sun, assuming perfect weather condition'))
    saveas(gca, strcat(folder,'\Max_power_over_time_at_angle_',num2str(u),'_rotational_tracking'),'png')
    close all
end

%%
ind = find(Totalenergy == max(Totalenergy));

%after looping over the SP angle the total power generated over a year gets
%plotted vs the angle 
figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
plot(SPangle,Totalenergy)
line([SPangle(1),SPangle(end)],[max(Totalenergy),max(Totalenergy)],'Color','r')
Ylim = get(gca,'ylim');
line([SPangle(ind),SPangle(ind)],[Ylim(1),Ylim(2)],'Color','r')
xlabel({'Rotation (deg)',' ';
    'Max power generation at angle: ',num2str(SPangle(ind))})
ylabel('Total power generation (J)')
legend('power generated')
title('Total power generated of a solar panel at a certain angle') 
saveas(gca, strcat(folder,'Yearly_energy_creation_per_angle'),'png')
toc
