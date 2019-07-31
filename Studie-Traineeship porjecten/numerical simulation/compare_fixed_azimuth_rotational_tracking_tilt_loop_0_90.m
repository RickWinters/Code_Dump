clear all
close all
clc
warning off
folder = 'C:\Dropbox\Saxion\4e jaar\EPS finland Floating Solar Park\EPS Floating Solar Park\numerical simulation\figures\';

load('Max_power_per_day_per_angle_facing_south.mat')
facingsouth_temp = Maxpower;
load('Max_power_per_day_per_angle_rotational_tracking.mat')
rotationaltracking_temp = Maxpower;
load('Total_daily_energy_per_day_per_angle_facing_south.mat')
facingsouth_totalenergy_temp = Totaldailyenergy;
load('Total_daily_energy_per_day_per_angle_rotational_tracking.mat')
rotationaltracking_totalenergy_temp = Totaldailyenergy;


for i = 1:length(Maxpower)
    facingsouth(i,:) = facingsouth_temp{i};
    rotationaltracking(i,:) = rotationaltracking_temp{i};
    facingsouth_totalenergy(i,:) = facingsouth_totalenergy_temp{i};
    rotationaltracking_totalenergy(i,:) = rotationaltracking_totalenergy_temp{i};
end

[y,x] = meshgrid(0:1:90,1:1:365);
figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
surf(x,y,rotationaltracking');
view([-45,45])
xlabel('Day in the year')
ylabel('Fixed tilt angle')
zlabel('Max power output (W)')
title('Max power generated at each day at each tilt angle, with rotational tracking')
saveas(gca, strcat(folder,'Max_power_output_each_day_each_tilt_angle_rotational_tracking'),'png')

figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
surf(x,y,facingsouth');
view([-45,45])
xlabel('Day in the year')
ylabel('Fixed tilt angle')
zlabel('Max power output (W)')
title('Max power generated at each day at each tilt angle, Panel facing south')
saveas(gca, strcat(folder,'Max_power_output_each_day_each_tilt_angle_facing_south'),'png')

[y,x] = meshgrid(0:1:90,1:1:365);
figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
surf(x,y,facingsouth_totalenergy');
view([-45,45])
xlabel('Day in the year')
ylabel('Fixed tilt angle')
zlabel('Total energy created (J)')
title('Total energy created at each day at each tilt angle, Panel facing south')
saveas(gca, strcat(folder,'Total_energy_created_each_day_each_tilt_angle_facing_south'),'png')


[y,x] = meshgrid(0:1:90,1:1:365);
figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
surf(x,y,rotationaltracking_totalenergy');
view([-45,45])
xlabel('Day in the year')
ylabel('Fixed tilt angle')
zlabel('Total energy created (J)')
title('Total energy created at each day at each tilt angle, rotational tracking')
saveas(gca, strcat(folder,'Total_energy_created_each_day_each_tilt_angle_rotational_tracking'),'png')

figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
surf(x,y,rotationaltracking_totalenergy');
surf(x,y,facingsouth_totalenergy');
view([-45,45])
xlabel('Day in the year')
ylabel('Fixed tilt angle')
zlabel('Total energy created (J)')
title('Total energy created at each day at each tilt angle, rotational tracking')
%saveas(gca, strcat(folder,'Total_energy_created_each_day_each_tilt_angle_rotational_tracking'),'png')


