%This script shows multiple examples of how to call functions and the
%usibility of these functions

%%
%this section is an example of goinf from the ImExport filesto the
%separated signal and time components. Using the RFC for lifetime
%estimation and calculating the lifetime by calculating the Natural
%Frequency over time (NFovertime)

clc
clear all
close all
warning off

mainfolder = 'D:\Stage_Thales\MATLAB\steel plate test\test 2\'; %select folder 
ntests = 8;  %8 samples were tested
multiplier = 100; %sensitivity was 10 mV/G

%savetestfiles loads the ImExport files and separates the signal and time
%components, multiplying the signal component to get acceleration in g and
%rectifies the time component
savetestfiles(mainfolder,ntests,100)

tlim = [10*60, 12*60];  %plot between the 10th and 12th minute
plotbartest(mainfolder,ntests,tlim)


flim = [20 40]; %frequency limits of random vibration specification

%data of testsample 
%eval(Istruct.formula) in this case will be a number. however if from
%multible samples multiple sets of parameters are known, it could be
%possible to evaluate the I value of every sample. However some rewriting
%of the code should be done. Same counts for Mstruct.
Istruct.formula = '(Istruct.b*Istruct.h^3)/12';
Istruct.h = 0.6e-3;
Istruct.b = 30e-3;
Mstruct.formula = '(Mstruct.m*a*Mstruct.l)';
Mstruct.m = 16.3e-3;
Mstruct.l = 11.58e-2;
psdon = 0;
Sult = 597;
Stensile = 280;
Ntensile = 2e6;

%loop over the signals and apply the 'analyse signal' function to do rfc
%estimates, and do statistical analysis over the estimated T
rfcestimates(ntests,mainfolder,Sult,Stensile,Ntensile,Istruct,Mstruct,flim,tlim,psdon)


timestep = 60; %loop over every minute
nfovertime(mainfolder,flim,timestep,ntests) %calculate NF over time and peaks every minute

%Compare results
compareresults(mainfolder)

%%
%this section shows an example of analysing and simplifying a psd

%load a file
signalfile = 'file1signal';
timefile = 'file1time';
load(strcat(mainfolder,'test8\',signalfile))
load(strcat(mainfolder,'test8\',timefile))
ind = find(time > tlim(1) & time < tlim(2)); %extract time limits
signal = signal(ind);
time = time(ind);

[pxx,f] = time2psdoriginal(signal,time); %find power spectrum
ind = find(f > flim(1) & f < flim(2)); %extract frequency limits
f = f(ind);
pxx = pxx(ind);
nk = 10;

fit = simplifypsd(pxx,f,flim,nk); %simplify power spectrum
ampfit = amplifypsd(fit);
figure; %plot power spectrum
hold on
grid on
plot(f,pxx)
plot(f,fit)
plot(f,ampfit)
xlabel('frequency(Hz)')
ylabel('power (G^2/Hz)')
legend('PSD','simplified psd','amplified simplified psd')




