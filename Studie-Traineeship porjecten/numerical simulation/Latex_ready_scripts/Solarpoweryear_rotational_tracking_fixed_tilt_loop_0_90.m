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
% Array of minutes troughout the day
SPangle = 0:1:90;                                                           
% Array of tilt-angles of the solar panel
tic                                                                         
% Start timer

yearlyplot = 0;

parfor u = 1:91                                                             
    % Parallel loop over all tilt angles, Multiple proceses get started
    % where each process calculates this loop iindependently of the other
    Totalenergy(u) = 0;                                                     
    % Create an array of Totalenery
    maxpower = [];                                                          
    % Set maxpower to an empty array, this gets added to the cell-matrix
    Maxpower{u} = [];                                                       
    % Create a cell-matrix entry that is an empty array.
    Totaldailyenergy{u} = [];                                               
    % Set the cell-matrix entry to an empty array
    totaldailyenergy = [];                                                  
    % Create an ampty array representing the total powergenerated for each
    % day in the month.
    for i = 2:366                                                           
        % Loop over all days in the year
        strcat('current: ',num2str(SPangle(u)),' deg    days',num2str(i),'/365') 
        % Update the user through command window
        
        % Calculate efficiencies based on elevation angles
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
        SPangles = minuteangles + SPangle(u);                               
        % Apply the rotation of the solar panel
        SPangles(SPangles>90) = 90 - (SPangles(SPangles>90)-90);            
        % Make sure the angle goes down again
        SPangles(ind) = 0;
        
        %from here we calculate the energy produced per minute assuming
        %perfect weather condition
        efficiencies = 1 - cosd(SPangles);                                  
        % Calculate the efficiency of the panel regarding the angle of the
        % sun on the panel
        power = basepower .* efficiencies;                                  
        % Multiply with base power to get power for every minute
        output = power .* 60;                                              
        % Calculate total output
        Totalenergy(u) = Totalenergy(u) + sum(output);                      
        % Summarize total output
        totaldailyenergy = [totaldailyenergy, sum(output)];
        maxpower = [maxpower, max(power)];                                  
        % Remember the max power output of this day
    end
    %After a year, plot the maximum power output vs of each day
    if yearlyplot == 1
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
    Maxpower{u} = maxpower;
    Totaldailyenergy{u} = totaldailyenergy;
end

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
save('Max_power_per_day_per_angle_rotational_tracking','Maxpower')
save('Total_daily_energy_per_day_per_angle_rotational_tracking','Totaldailyenergy')
