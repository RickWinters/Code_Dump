clear all
close all
clc
warning off

npeaks = 10;

folder = 'D:\Stage_UT\experiment_1\';
Mtime = 1.001;

for i = 1:9
    if i ~= 8  %skip measurements that failed 
        npeaks = 10;
        if i == 5, npeaks = 6; end
        
        figure('units','normalized','outerposition',[0 0 1 1])                  %new figure, fullscreen
        
        load(strcat(folder,'signal',num2str(i)))                                %load signal
        signal = double(signal - mean(signal));                                 %remove DC component and cast to double
        
        subplot(1,2,1)
        dt = Mtime/length(signal);                                              %Sampling time is measurement time (1.001 s) divided by n samples
        time = 0:dt:dt*length(signal)-dt;                                       %set up time axis
        plot(time(1:500),signal(1:500));                                        %plot first 500 indices of signal
        xlabel('t (s)');
        ylabel('amplitude (V)');
        
        subplot(1,2,2)
        analysis(signal,Mtime,npeaks,i);
    end
end