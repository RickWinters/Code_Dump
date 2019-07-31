function[] = plotbartest(mainfolder,ntests,tlim)
%This function plots the raw acceleration signals from multiple
%measurements in subplots, within a certain time limit
%WARNING! MAKE SURE THE TIME LIMIT IS SHORT ENOUGH TO PLOT THE DATA, DO NOT
%EVER PLOT MORE THEN 10 MINUTES FOR EACH MEASUREMENT. WANTING TO PLOT TOO
%MUCH DATA SLOWS DOWN THE COMPUTER A LOT OR MAY CRASH IT! This depends on
%the capabilities of the machine
%==========================================================================
%SYNTAX
% plotbartest(mainfolder)
% plotbartest(mainfolder,ntests)
% plotbartest(mainfolder,ntests,tlim)
%==========================================================================
%OUTPUT
% none, figure
%==========================================================================
%INPUT
% mainfolder               = character array / string
%                            folder where the testfiles are stored on disk
% ntests                   = integer
%                            Number of samples tested during experiment
%                            optional
%                            default = 8
% tlim                     = array of two floats/integers
%                            describes the time limitations between which
%                            the data is plotted. [tlow, thigh]
%                            optional
%                            default = [0, 60] (first minute of signal)

if nargin < 3
    tlim = [0, 60];
    if nargin < 2
        ntests = 8;
    end
end


for j = 1:ntests
    progress = strcat('plotting signal ',num2str(j))
    signalfile = strcat('test',num2str(j),'\file1signal');
    timefile = strcat('test',num2str(j),'\file1time');
    load(strcat(mainfolder,signalfile));
    load(strcat(mainfolder,timefile));
    signal = signal';
    time = time';
    ind = find(time > tlim(1) & time <= tlim(2));
    signal = signal(ind);
    time = time(ind);
    time = time/60;
    
    subplot(2,ceil(ntests/2),j)
    plot(time,signal)
    title(strcat('bar ',num2str(j)))
    xlabel('time (min)')
    ylabel('amplitude (G)')
    drawnow()
end