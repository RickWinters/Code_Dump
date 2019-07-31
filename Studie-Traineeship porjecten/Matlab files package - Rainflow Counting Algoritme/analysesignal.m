function[T] = analysesignal(signal,dt,Sult,Stensile,Ntensile,Istruct,Mstruct,flim,psdon)
% This function analyses an acceleration measurement and estimates the
% lifetime of a part by calculating the damage experienced during this
% measurement.
%==========================================================================
%SYNTAX
% analysesignal(signal,dt,dpcpg)
% T = analysesignal(signal,dt,dpcpg)
% T = analysesignal(signal,dt,dpcpg,psdon)
% T = analysesignal(signal,dt,dpcpg,psdon,flim)
% T = analysesignal(signal,dt,dpgpg,psdon,flim,calculatestress)
%==========================================================================
%OUTPUT
% T               = float
%                   estimated time to failure of part, same unit of time as
%                   'dt'
%
%==========================================================================
%INPUT
% signal          = data array;
%                   measured signal in G
% dt              = float;
%                   1 / samplingfrequency
% Sult            = integer;
%                    ultimate stress of material. This is the stress at
%                   the material will snap. give in MPa                    
% Stensile        = integer;        
%                   Tensile stress of material. The stress at the kneepoint
%                   of an S-N curve of the material. 
% Ntensile        = integer;
%                   Amount of cycles according to S-N curve at kneepoint
% Istruct         = structure;
%                   needed in calculating stress. This represents how to
%                   calculate the surface moment of inertia
%                   buildup:
%                   describe the formula for I in a shape by
%                   Istruct.formula = [string, for example '(Istruct.b * 
%                   Istruct.h^3)/12' for a rectangular bar.
%                   next define the parameter values by
%                   'Istruct.[parametername] = [parametervalue]
% Mstruct         = structure;
%                   structure describing how to calculate moment of force
%                   buildup is the same as Istruct
% flim            = float array of 2 values;
%                   frequency limit. suggested to enter the limits of the
%                   random vibration used on the edt. this is needed for
%                   the correction in the numerical integration.
% psdon           = [0 1];
%                   if psdon == 1, plot a psd of the signal
%                   optional
%                   default = 0


%  by Rick Winters
%  Feb-Jul 2017

if nargin < 9
    psdon = 0;
end


%setup time axis from dt
Tend = dt*length(signal);%calculate end time
time = 0:dt:Tend-dt; %setup time axis, since Channel_02_x is messed up

%new figure, fullscreen
%figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,1,1)%upper most left
plot(time,signal) %plot raw signal
title('raw signal')
xlabel('time(s)')
ylabel('acceleration (g)')
drawnow

signal = signal * 9.81;

%numerical integration to displacement
signal = signal - mean(signal);
[vfilt,v,vmean] = numint(signal,time,20,flim);
vfilt = vfilt - mean(vfilt);
[yfilt,y,ymean] = numint(vfilt,time,20,flim);


extdisp = sigext(signal);
extdisp = abs(extdisp);
meandisp = mean(extdisp);
stddisp = std(extdisp);

a = meandisp + 2*stddisp;

%stress calculation
% stress = (M * ymax)/I
% M = m*a*l, these values only for setup used in experiments during
% project
M = eval(Mstruct.formula); 
I = eval(Istruct.formula);
stress = (M .* yfilt)./I;
stress = stress/1e6; %from Pa to MPa
plot(time,stress) %overwrite acceleration plot with stress plot
ylabel('stress (MPa)')
signal = stress;

[extremes, exttime] = sigext(signal,time); %extract extremes from signal
rfdata = rainflow(extremes,exttime); %rainflow counting

%mean Gamp / stress correction
rfdata = stresscorrection(rfdata,Sult); %mean stress correction, second value as 800 Mpa Sult
[D, T] = damagecalculation(rfdata, time(length(time)), Stensile, 1, Ntensile);

if psdon == 1
    subplot(2,3,4) %plot the 3d histogram of mean and amplitude cycle counting
else
    subplot(2,2,3)
end

maxmean = max(abs(rfdata(2,:)));
ind = find(abs(rfdata(2,:))>maxmean/8);
rfdata(:,ind) = [];


nbins = 20; %number of bins
rfmatrix(rfdata,nbins,nbins,'stress amplitude (MPa)','mean stress (MPa)');%plot rainflow 3d histogram
drawnow

if psdon == 1
    ax = subplot(2,3,5);
else
    ax = subplot(2,2,4);
end
set(ax,'visible','off') %makes plot invisible
text(0, 1, strcat('damage = ',num2str(D)),'FontSize',18); %print damage
text(0, 0.9, strcat('life time estimation, =', num2str(round(T/60)), 'minutes'),'FontSize',18); %print remaining cycles
ncycles = sum(rfdata(3,:));
text(0, 0.8, strcat('total number of cycles counted = ', num2str(round(ncycles,4))),'FontSize',18); %print total counted cycles

if psdon == 1
    subplot(2,3,6)
    hold on
    [pxx,f] = time2psdoriginal(signal,time); %calculate psd
    if nargin < 9 %set flim to frequency limit of psd
        flim(1) = f(1);
        flim(2) = f(length(f));
    end
    
    ind = find(f>=flim(1) & f<=flim(2));
    
    f = f(ind);
    pxx = pxx(ind);
    
    plot(f,pxx) %plot PSD
    hold on
    grid on
end


drawnow
