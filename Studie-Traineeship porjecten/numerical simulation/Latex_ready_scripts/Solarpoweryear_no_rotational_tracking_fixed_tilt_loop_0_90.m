clear all
close all
clc
warning off

load elevationangles                                                        
% Load in the elevationangles data
load azimuth.mat                                                            
% Load in the azimuthangles data
elevationangles = angles;                                                   
% Put the values in the 'elevationangles' variable
folder = 'C:\Dropbox\Saxion\4e jaar\EPS finland Floating Solar Park\EPS Floating Solar Park\numerical simulation\figures\';

basepower = 75;                                                             
% Watt
SPazimuth = 180;                                                            
% Angle on a compass of the solar panel face
timestep = 1;                                                               
% In minutes
minutes = 1:1/60:24;                                                        
% Array of minutes throughout the day
SPangle = 0:1:90;                                                           
% Array of tilt-angles of the solar panel
tic                                                                         
% Starts timer
dailyplot = 0;                                         
yearlyplot = 1;

parfor u = 1:91                                                             
    % Parallel loop over all tilt angles, Multiple processes get started
    % where each process calculates this loop independently of the others
    % and at the same time, speeding up the process
    Totalenergy(u) = 0;                                                     
    % create an array of Totalenergy
    Maxpower{u} = [];                                                       
    % Create an cell-matrix of MaxPower
    maxpower = [];                                                          
    % Set maxpower to an empty array, this array gets added to the cell
    % matrix
    totaldailyenergy = [];                                                  
    % Create an empty array representing the total power generated for each
    % day in the month
    Totaldailyenergy{u} = [];                                               
    % Set the cell-matrix entry to an empty array
    for i = 2:366                                                           
        % Loop over all days in the year
        strcat('current: ',num2str(SPangle(u)),' deg    days',num2str(i),'/365') 
        %Update the user through command window
        
        %calculate efficiencies based on elevation angles
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
        elevation_efficiencies = 1 - cosd(SPangles);                        
        % Calculate the efficiency of the panel regarding the angle of the
        % sun on the panel
        
        %calculate efficiencies based on azimuth angle differenc
        azimuth_current = azimuth(i,:);                                     
        % Load in azimuth angles of the sun this day
        weights = azimuth_current > 0;                                      
        % Only take the azimuth of the sun into consideration where it has
        % risen to fit it for every minute
        fitted = fit((1:1:24)',azimuth_current','d.*x.^3+a.*x.^2+b.*x+c','weight',weights); 
        % Fit the azimuth with a cubic fit
        azimuth_fitted = fitted(minutes);                                   
        % Evaluate fit
        azdifference = abs(azimuth_fitted - SPazimuth);                     
        % Calculate difference in azimuthe angle
        azdifference(azdifference > 90) = 90;                               
        % If its bigger than 90 degrees, set it to 90 degrees
        azimuthefficiencies = 1-sind(azdifference);                         
        % Calculate efficiency in the same way elevation efficiency is
        % calculated. as a first assumption this should do
        
        efficiencies = azimuthefficiencies .* elevation_efficiencies;       
        % Multiply elevation and azimuth together to get total efficiency
        power = basepower .* efficiencies;                                  
        % Multiply with base power to get power for every minute
        output = power .* 60;                                               
        % Calculate total output
        Totalenergy(u) = Totalenergy(u) + sum(output);                      
        % Summarize total output
        totaldailyenergy = [totaldailyenergy, sum(output)];                 
        % Remember total daily output in array
        maxpower = [maxpower, max(power)];                                  
        % Remember the max power output of this day
        
        if dailyplot == 1                                                   
            % This plot is used for debugging purposes
            figure('units','normalized','outerposition',[0 0 1 1])
            grid on
            hold on
            plot(minutes,azimuthefficiencies.*100)
            plot(minutes,elevation_efficiencies.*100)
            plot(minutes,efficiencies.*100)
            plot(minutes,azdifference);
            plot(minutes,SPangles);
            plot(minutes,power);
            xlabel('Hours')
            ylabel('data')
            legend('azef','elef','eff','azdiff','SPangles','power')
            title('eu') 
        end
    end
    
    %After a year, plot the maximum power output of each day
    if yearlyplot == 1
        figure('units','normalized','outerposition',[0 0 1 1])
        grid on
        hold on
        plot(1:365,maxpower)
        xlabel('days')
        ylabel('Maximum power output')
        legend('power (W)')
        title(strcat('Maximum power output of panel rated at 75W, each day of the year, at ',num2str(SPangle(u)),' degree, facing south, assuming perfect weather condition'))
        saveas(gca, strcat(folder,'Max_power_over_time_at_angle_',num2str(u),'_no_rotational_tracking'),'png')
        close all
    end
    Maxpower{u} = maxpower;                                                 
    % Save max power output per day in cell-matrix, so that Matlab main
    % process can acces it
    Totaldailyenergy{u} = totaldailyenergy;                                 
    % Save totaldailyenergy to cell-matrix, so that main process can acces
    % it
end

ind = find(Totalenergy == max(Totalenergy));                                
% Find the index of the maximum total energy, this is also the optimum
% angle

%Plots total energy output vs solar panel angle, with crossing lines at
%optimum place
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
saveas(gca, strcat(folder,'Yearly_energy_creation_per_tiltangle_no_rotational_tracking'),'png')
toc
save('Max_power_per_day_per_angle_facing_south','Maxpower')
save('Total_daily_energy_per_day_per_angle_facing_south','Totaldailyenergy')
