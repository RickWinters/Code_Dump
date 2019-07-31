function[] = nfovertime(mainfolder,flim,timestep,ntests)
%This function calculates the natural frequency over time by analysing the
%signal every minute, calculating the psd, and finding the maximum peak.
%If this analysis is done, the matrix will be saved in
%'[mainfolder]\nfovertimeresults', so that if the script is called again
%for the same files, this file can be loaded instead of analysing all the
%signals again.
%Next to that it calculates at which minute the natural frequency decreases
%by 1%. If multiple files are analysed this script will also plot a
%boxplot and normal distribution of the measured times.
%
%                     Separate tests must be saved as
%                     '[mainfolder]\test[x]\file[y]signal' and
%                     '[mainfolder]\test[x]\file[y]signal', where [x] is
%                     the variable of which sample is tested. If 8 samples
%                     are tested, there should by 8 folders named 'test[x]'
%                     in [mainfolder]. If one sample is measured for
%                     multiple times, lets say one minute measuring every
%                     10 minutes, [y] represents the amount of measurements
%                     of the test sample. Currently this script only loads
%                     the first measurement. If only one measerument is
%                     taken for each sample, this should be called
%                     'file1signal' and 'file1time'
%==========================================================================
%Syntax
% nfovertime(mainfolder)                                                  
% nfovertime(mainfolder,flim)                                              
% nfovertime(mainfolder,flim,timestep)               
% nfovertime(mainfolder,flim,timestep,nbars)
%==========================================================================
%OUTPUT
% none
%==========================================================================
%INPUT
% mainfolder        = character array
%                     folder on disk where the separate test folders are
%                     located
% flim              = float array of 2 values
%                     Frequency limit of measured signal, it is advised to
%                     enter the frequency limits of the random vibration
%                     specification, [flow, fhigh]
%                     optional
%                     default = [0, 2000]
% timestep          = integer
%                     The timestep in which the signal is divided up and
%                     analysed, if this value is 60, the signal is divided
%                     up into pieces of 60 seconds of wich the PSD is
%                     calculated and the highest peak within flim is found
%                     optional
%                     default = 60
% ntests            = integer
%                     Number of samples tested, and number of 'test[x]'
%                     folders in [mainfolder].
%                     optional
%                     default = 8 (most experiments during project were
%                     with 8 samples)

warning off

if nargin < 4
    ntests = 8
    if nargin < 3
        timestep = 60
        if nargin < 2
            flim = [0, 2000]
        end
    end
end
%mainfolder = 'D:\Stage_Thales\MATLAB\steel plate test\test2\';

%flim = [120 160]; %frequency limit, same as random vibration on EDT
%timestep = 60; %time step in seconds, this case every minute gets separated
%nbars = 8; %number of bars
nf = []
try 
    load(strcat(mainfolder,'nfovertimeresults'))
catch
    for j = 1:ntests
        folder = strcat(mainfolder,'bar',num2str(j),'\');% folder of the files, changes when j changes
        signalfile = strcat('file1signal'); %signal file
        timefile = strcat('file1time'); %time file
        load(strcat(folder,signalfile)); %load signal
        load(strcat(folder,timefile)); % load time

        nsteps = floor(time(length(time))/timestep); %calculate how many steps timesteps there are

        nf(:,j) = zeros(1,max(nsteps,size(nf,1)));        %create array of zeros the lentgh of the steps

        for i = 1:nsteps
            progress = strcat(num2str(i),'/',num2str(nsteps),'-',num2str(j),'/',num2str(ntests))
            lowlim = (i*timestep)-timestep;   %lowest time limit, = 0 at first timestep
            highlim = i*timestep;               % highest time limit, = timestep at first timestep
            ind = find(time > lowlim & time < highlim); %find the indices where the time array is within the timelimits
            temptime = time(ind);    % temporary time array
            tempsignal = signal(ind);% temporary signal array
            [pxx,f] = time2psdoriginal(tempsignal,temptime);   %find psd of temporary signal
            ind = find(f > flim(1) & f < flim(2));   %find indices where frequency axis is within frequency limits
            pxx = pxx(ind); %delete data out of frequency limits
            f = f(ind);

            [peaks, locs] = findpeaks(pxx,f,'sort','Descend'); %find the peaks and sort by descending amplitude, so that the highest peak (natural frequency) is on element 1 
            if i == 1
                loc99 = 0.99*locs(1);
            end

            subplot(2,1,1)
            plot(temptime,tempsignal)
            subplot(2,1,2)
            plot(f,pxx) %plot the power spectrum, this is done quickly for every timestep
            line([loc99, loc99],[0, peaks(1)],'Color','r')
            drawnow()

            nf(i,j) = locs(1); %save natural frequency 
        end
    end
    save(strcat(mainfolder,'nfovertimeresults'),'nf')
end

figure %plot all natural frequencies
plot(nf(1:105,:),'o')
hold on
grid on
ax = gca;
ax.ColorOrderIndex = 1;
plot(nf(1:105,:))

xlabel('time (min)')
ylabel('natural frequency (Hz)')
legend('bar 1','bar 2','bar 3','bar 4','bar 5','bar 6','bar 7','bar 8')
endtime = []; %create endtime array

for i = 1:size(nf,2)
    startf = nf(1,i); %the natural frequency at the start of measurement of one bar
    for j = 50:size(nf,1)
        percentage = (nf(j,i)/startf)*100; %calculate percentage of natural frequency
        if percentage < 99 %if percentage drops below 99, i.e. 1 % loss in natural frequency, add the endtime to the array
            endtime = [endtime, j*timestep];
            break
        end
    end
end

endtime = endtime - 21*60;

figure
boxplot(endtime/60)
ylabel('time (min)')
grid on

figure
hold on
grid on

meantime = mean(endtime); %calculate the mean of the endtime array
stdtime = std(endtime);   % standard deviation
endtime/60
threesigmarange = [(meantime - 3*stdtime), (meantime + 3*stdtime)]; %calculate the six sigma range of endtimes

xaxis = [(meantime/60)-3*(stdtime/60):1:(meantime/60)+3*(stdtime/60)];
yaxis = normpdf(xaxis,meantime/60,stdtime/60);
plot(xaxis,yaxis)

output = [meantime/60, stdtime/60, threesigmarange/60]

twosigmarange = [(meantime-stdtime),(meantime+stdtime)];
i = 1;
while i < length(endtime)
    if endtime(i) < twosigmarange(1) || endtime(i) > twosigmarange(2)
        endtime(i) = [];
    end
    i = i+1;
end
        
meantime = mean(endtime);
stdtime = std(endtime);
threesigmarange = [ (meantime - 3*stdtime),(meantime + 3*stdtime)];
endtime/60
output = [meantime/60, stdtime/60, threesigmarange/60]
hold on

xaxis = [(meantime/60)-3*(stdtime/60):1:(meantime/60)+3*(stdtime/60)];
yaxis = normpdf(xaxis,meantime/60,stdtime/60);
plot(xaxis,yaxis)

xlabel('time to crack initialization (min)')
ylabel('probability')
legend('all data','outliers removed')

save(strcat(mainfolder,'nfovertimetimes'),'endtime')













