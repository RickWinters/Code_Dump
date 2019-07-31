clear all
close all
clc
warning off

folder = 'C:\Dropbox\Apps\ShareLaTeX\EPS Solar project\figures\Part_2_Product_design\numerical_simulation\';

%load data of facing south fixed tilt
load('Max_power_per_day_per_angle_facing_south')
Mpoweranglesouth = Maxpower;
load('Total_daily_energy_per_day_per_angle_facing_south');
Tenergyanglesouth = Totaldailyenergy;

%load data of rot tracking fixed tilt
load('Max_power_per_day_per_angle_rotational_tracking')
Mpoweranglerotation = Maxpower;
load('Total_daily_energy_per_day_per_angle_rotational_tracking')
Tenergyanglerotation = Totaldailyenergy;

%load data of rot tracking tilt tracking
load('Max_power_per_day_rotational_tracking_tilt_tracking')
Mpowerrotationtilt = maxpower;
load('Total_daily_energy_per_day_rotational_tracking_tilt_tracking')
Tenergyrotationtilt = totaldailyenergy;

%setup plots
angles = 0:90;
Tenergyyearlyanglesouth = [];

for i = 1:91
    Tenergyyearlyanglesouth(i) = sum(Tenergyanglesouth{i});
end
maxangle = find(Tenergyyearlyanglesouth == max(Tenergyyearlyanglesouth))-1;

%plot the total energy produced for fixed tilt facing south, 
figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
plot(angles,Tenergyyearlyanglesouth,'LineWidth',3)
Ylim = get(gca,'ylim');
line([0,90],[Tenergyyearlyanglesouth(maxangle+1),Tenergyyearlyanglesouth(maxangle+1)],'Color','r','LineWidth',3)
line([maxangle,maxangle],[Ylim(1),Ylim(2)],'Color','r','LineWidth',3)
xlabel({'Tilt angle of solar panel';
    strcat('Maximum energy achieved = ',num2str(round(max(Tenergyyearlyanglesouth))),'(J)')
    strcat('At tilt angle = ',num2str(maxangle))})
ylabel('Total energy (J)')
title('Total energy produced per fixed tilt angel, facing south') 
set(gca,'FontSize',24)
saveas(gca, strcat(folder,'Tenergyanglesouth'),'png')

%plot the total energy produced of every day across a whole year with this
%angle
days = 1:365;
figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
plot(days,Tenergyanglesouth{maxangle},'LineWidth',3)
xlabel('Month over the year')
ylabel('Total energy produced (J)')
xticks([0,31,59,90,120,151,181,212,243,273,304,334,365]);
xtickangle(45)
xticklabels({'January','February','March','April','May','June','July','August','September','October','November','December'})
title({'Total energy produced for every day in';
    'a year at a 67 degree tilt with the panel facing south'}) 
set(gca,'FontSize',24)
saveas(gca, strcat(folder,'Tenergyangle67south'),'png')

%Doing the same thing for 0 degrees
figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
plot(days,Tenergyanglesouth{91},'LineWidth',3)
xlabel('Month over the year')
ylabel('Total energy produced (J)')
xticks([0,31,59,90,120,151,181,212,243,273,304,334,365]);
xtickangle(45)
xticklabels({'January','February','March','April','May','June','July','August','September','October','November','December'})
title({'Total energy produced for every day in';
    'a year at a 90 degree tilt with the panel facing south'}) 
set(gca,'FontSize',24)
saveas(gca, strcat(folder,'Tenergyangle90south'),'png')

%And the same for 0 degrees tilt
figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
plot(days,Tenergyanglesouth{1},'LineWidth',3)
xlabel('Month over the year')
ylabel('Total energy produced (J)')
xticks([0,31,59,90,120,151,181,212,243,273,304,334,365]);
xtickangle(45)
xticklabels({'January','February','March','April','May','June','July','August','September','October','November','December'})
title({'Total energy produced for every day in';
    'a year at a 0 degree tilt with the panel facing south'}) 
set(gca,'FontSize',24)
saveas(gca, strcat(folder,'Tenergyangle0south'),'png')
%%
Tenergyyearlyanglerotation = [];
for i = 1:91
    Tenergyyearlyanglerotation(i) = sum(Tenergyanglerotation{i});
end
maxangle = find(Tenergyyearlyanglerotation == max(Tenergyyearlyanglerotation))-1;
%plot the total energy produced for fixed tilt facing south, 
figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
plot(angles,Tenergyyearlyanglerotation,'LineWidth',3)
Ylim = get(gca,'ylim');
line([0,90],[Tenergyyearlyanglerotation(maxangle+1),Tenergyyearlyanglerotation(maxangle+1)],'Color','r','LineWidth',3)
line([maxangle,maxangle],[Ylim(1),Ylim(2)],'Color','r','LineWidth',3)
xlabel({'Tilt angle of solar panel';
    strcat('Maximum energy achieved = ',num2str(round(max(Tenergyyearlyanglerotation))),'(J)')
    strcat('At tilt angle = ',num2str(maxangle))})
ylabel('Total energy (J)')
title('Total energy produced per fixed tilt angel, rotating with the sun') 
set(gca,'FontSize',24)
saveas(gca, strcat(folder,'Tenergyanglerotation'),'png')

%plot the total energy produced of every day across a whole year with this
%angle
days = 1:365;
figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
plot(days,Tenergyanglerotation{maxangle},'LineWidth',3)
xlabel('Month over the year')
ylabel('Total energy produced (J)')
xticks([0,31,59,90,120,151,181,212,243,273,304,334,365]);
xtickangle(45)
xticklabels({'January','February','March','April','May','June','July','August','September','October','November','December'})
title({'Total energy produced for every day in';
    'a year at a 73 degree tilt with the panel rotating with the sun'}) 
set(gca,'FontSize',24)
saveas(gca, strcat(folder,'Tenergyangle73rotation'),'png')

%Doing the same thing for 0 degrees
figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
plot(days,Tenergyanglerotation{91},'LineWidth',3)
xlabel('Month over the year')
ylabel('Total energy produced (J)')
xticks([0,31,59,90,120,151,181,212,243,273,304,334,365]);
xtickangle(45)
xticklabels({'January','February','March','April','May','June','July','August','September','October','November','December'})
title({'Total energy produced for every day in';
    'a year at a 90 degree tilt with the panel rotating with the sun'}) 
set(gca,'FontSize',24)
saveas(gca, strcat(folder,'Tenergyangle90rotation'),'png')

%And the same for 0 degrees tilt
figure('units','normalized','outerposition',[0 0 1 1])
grid on
hold on
plot(days,Tenergyanglerotation{1},'LineWidth',3)
xlabel('Month over the year')
ylabel('Total energy produced (J)')
xticks([0,31,59,90,120,151,181,212,243,273,304,334,365]);
xtickangle(45)
xticklabels({'January','February','March','April','May','June','July','August','September','October','November','December'})
title({'Total energy produced for every day in';
    'a year at a 0 degree tilt with the panel rotating with the sun'}) 
set(gca,'FontSize',24)
saveas(gca, strcat(folder,'Tenergyangle0rotation'),'png')
%%
