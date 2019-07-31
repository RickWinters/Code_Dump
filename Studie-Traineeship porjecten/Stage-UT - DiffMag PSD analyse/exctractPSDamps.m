function[means,indices,amptime,amp] = exctractPSDamps(time,amp,LPFF,locs)
% This function extracts the mean amplitudes from a DiffMag sequence in
% order to calculate the DiffMag value. This is done by dividing the
% sequence in different time blocks and finding the mean amplitude within
% these timeblocks. At the start 2/LPFF of time does not get used, and
% 1/LPFF around the break up points does not get used to account for the 
% filter response time.
%--------------------------------------------------------------------------
%SYNTAX
% [means,indices,amptime,amp] = exctractPSDamps(time,amp)
% [means,indices,amptime,amp] = exctractPSDamps(time,amp,LPFF)
% [means,indices,amptime,amp] = exctractPSDamps(time,amp,LPFF,locs)
%--------------------------------------------------------------------------
%OUTPUT
% means-------------------------[array]
%                                - array of mean amplitudes
% indices-----------------------[matrix]
%                               - A matrix of the indices, where every row
%                                 represents a different time block.
%                                 Columnn 1 is the starting index of this
%                                 time block and Columnn 2 is the last
%                                 index of this time block
% amptime-----------------------[array]
%                               - Time array, where the first 2/LPFF is
%                                 removed. i.e. if LPFF = 20 Hz, the first
%                                 0.1 seconds is removed to delete Filter
%                                 settling time.
% amp---------------------------[array]
%                               - Amplitude array,
%--------------------------------------------------------------------------
%INPUTS
% time--------------------------[array]
%                               - Time array
% amp---------------------------[array]
%                               - Amplitude array
% LPFF--------------------------[integer]
%                               - Low pass filter frequency
%                               - Optional, default = 20
% locs--------------------------[array]
%                               - Array of indices on the time axis to
%                                 break up the time in separate blocks
%                               - Optional, default = 0
%--------------------------------------------------------------------------
%DEPENDENCIES
% none
%--------------------------------------------------------------------------
%Rick Winters, 2018-01-03
                   
if nargin < 4                                                               % set default values if needed
    locs = 0;
    if nargin < 3
        LPFF = 20;
    end
end

if locs == 0                                                                % keep track if indices are given where to break up the time into blocks or not
    ownlocs = 0;
else
    ownlocs = 1;
end

ind = find(time < 2/LPFF);                                                  % find the indices on the time axis where the time is less then 2/LPFF, to account for filter settling time
if ownlocs == 0, amp(ind) = []; end
amptime = time;
amptime(ind) = [];

if locs == 0                                                                % If no times are given where to break up, find it automatically
    diffamp = abs(diff(amp))./(time(2)-time(1));                            % calculate the absolute change of the amplitude over time
    diffamp(end+1) = diffamp(end);                                          % make it the same length as signal
    [pks,locs,widths] = findpeaks(diffamp,'MinPeakHeight',3*mean(diffamp)); % Find when the amplitude changes the most, in diffmag happens when a DC offset is changed
    widths = round(widths);                                                 % round the widths of the peaks to an integer
else
    widths = ones(size(locs)).*ind(end);                                    % The widths of the 'peaks' is 1/LPFF on either side of the indicated times.
    pks = ones(size(locs));                                                 % so that the next for loop works
end

for i = 1:length(pks)+1                                                     % this for loop finds the indices of the amplitude where there is no drastic change. i.e. in between
    if isempty(pks)                                                         % If the time is not broken up automatically, set the necessary variables and break for loop
        indices(1,1) = 1;
        indices(1,2) = length(amp);
        means(i) = mean(amp);
        meandiffs(i) = mean(abs(amp - mean(amp)));
        break
    end
    if i == 1                                                               % These if statementes control the start and stop indices on the time axis for the timeblocks set
        if ownlocs == 0, startindex = 1; else
            startindex = ind(end); end
    else
        startindex = locs(i-1)+widths(i-1);
    end
    if i > length(pks)
        stopindex = length(amp);
    else
        stopindex = locs(i)-widths(i);
    end
    indices(i,1) = startindex;                                              % save the start and stopindices, used in drawing lines
    indices(i,2) = stopindex;
end

for i = 1:size(indices,1)                                                   % Calculate the mean amplitudes in the timeblocks
    means(i) = mean(amp(indices(i,1):indices(i,2)));
end

nanmeans = isnan(means);                                                    % If by any change, the mean is NaN, delete that index from array
means(nanmeans) = [];
indices(nanmeans,:) = [];
if ownlocs == 1, amp(ind) = []; end

