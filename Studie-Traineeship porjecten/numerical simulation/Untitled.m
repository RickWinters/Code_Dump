clear all
close all
clc
warning off

Base_output = 75; %Watt
start_angle = 0;
end_angle = 90;
timestep = 1; %in minutes
nminutes = 60*24; %minutes in a day
nsteps = nminutes / timestep;
SPangle = 0:1:45;


times = (0:timestep:nminutes-timestep)+timestep/2;
angles = linspace(start_angle,end_angle,nsteps/2);
angles = [angles, linspace(end_angle-angles(2),start_angle,nsteps/2)];

for i = 1:length(SPangle)
SPangles = angles + SPangle(i);
ind = SPangles > 90;
SPangles(ind) = 90 - (SPangles(ind)-90);          

efficiency = 1 - cos(deg2rad(SPangles));
power = Base_output .* efficiency;
energypertimeunit = power.*60*timestep;
totalenergy(i) = sum(energypertimeunit * (2.7*10^-7));

% figure('units','normalized','outerposition',[0 0 1 1])
% grid on
% hold on
% plot(times/60,angles)
% plot(times/60,SPangles)
% plot(times/60,efficiency*100)
% plot(times/60,power)
% xlabel('Time')
% ylabel('Data')
% legend('angles','Solar panel angles','efficiency*100','power(J/s)')
% title('Simple simulation') 
end

figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
plot(SPangle,totalenergy)
xlabel('Angle of solar panel')
ylabel('Total energy created over a day')
legend()
title('Angle of SP vs Energy created') 

