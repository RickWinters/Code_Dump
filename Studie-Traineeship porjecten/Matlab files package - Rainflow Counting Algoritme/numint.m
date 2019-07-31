function[vfilt, v, vmean] = numint(signal,time,nmean,flim)
%This function numerically integrates the signal given. The data is
%filtered by subtracting the walking average of 'nmean' bits. This acts as
%a high pass filter and as such removes unwanted linear components or
%semi-static behaviour (very low frequency)
%==========================================================================
%SYNTAX
%  numint(signal)
%  vfilt = numint(signal)
%  vfilt = numint(signal)
%  vfilt = numint(signal,time)
%  vfilt = numint(signal,time,nmean)
%  [vfilt, v] = numint(signal,time,nmean)
%  [vfilt, v, vmean] = numint(signalt,time,nmean)
%==========================================================================
%OUTPUTS
%vfilt = array;
%        the array after subtracting the walking average,
%v     = array;
%        the array that is numerrically integrated from the input, commonly
%        represenst velocity if acceleration is used as input
%vmean = array;
%        the array that represents the walking average of 'v'
%==========================================================================
%INPUTS
%signal = array;
%         the data array that has to be numerricaly integrated
%time   = array;
%         time data at measurement array, used to determine dt for correct
%         numerical integration when time matters
%         optional
%         if not used, time = 1:1:length(signal)
%nmean  = integer;
%         this number is used to determine the length of the walking
%         average filter
%         optional
%         default = 20

% by Rick Winters
% Feb-Jul 2017

if nargin < 3 %default nmean to 20
    nmean = 20;
    if nargin < 2; %set time axis
        time = 1:1:length(signal);
    end
end

v = zeros(1,length(signal)); %creatue velocity array of all zeros
dt = time(3)-time(2); %time step


for i = 2:length(signal) %this loop does the numerical integration
    v(i) = v(i-1) + signal(i)*dt;
end



vmean = zeros(1,length(v)); %create a walking average velocity array
vfilt = zeros(1,length(v)); %create a filtered velocity array
for i = nmean/1:(length(v)-nmean/2) %this loop takes an average of nmean numbers and walks over the signal, then subtracts the walking average number from the integrated number to filter out the low frequencies
    vmean(i) = mean(v(i-nmean/2:i+nmean/2));
    vfilt(i) = v(i) - vmean(i);
end

[meanpxx,meanf] = time2psdoriginal(vmean,time);
 [vpxx] = time2psdoriginal(v,time);
 
 ind = find(meanf < flim(2) & meanf > flim(1));
 meanpxx = meanpxx(ind);
 vpxx = vpxx(ind);
 
 factor = sum(vpxx) / sum(meanpxx);
 
 vfilt = vfilt.*factor;




