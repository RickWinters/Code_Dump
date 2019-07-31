function[pks,locs,Fharmonics,Aharmonics,found,groups] = findharmonics(amplitude,Faxis,Fmargin)
% This function tries to find multiple harmonics in a fft of a signal by
% looking at the distances of the peaks. The function tries to group
% different peaks which belong to the same base harmonics frequency
% (50,100,150 Hz).
%--------------------------------------------------------------------------
%SYNTAX
% (showing only combinations of inputs)
% findharmonics(amplitude)
% findharmonics(amplitude,Faxis)
% findharmonics(amplitude,Faxis,Fmargin)
% -------------------------------------------------------------------------
% OUTPUT
%   pks--------------------------[array]
%                                - Magnitudes of the found peaks
%   locs-------------------------[array]
%                                - Frequencies of the found peaks
%   Fharmonics-------------------[array]
%                                - The base frequencies of the found
%                                harmonics
%   Aharmonics-------------------[array]
%                                - Amplitudes of the base frequencies of the
%                                harmonics
%   found------------------------[1 / 0]
%                                - 1 if harmonics are found
%                                - 0 if no harmonics are found
%   groups-----------------------[cell array]
%                                - The array in each cell represents the
%                                index of the found peaks that are expected
%                                to belong to the same harmonics group
%--------------------------------------------------------------------------
%INPUT
%   amplitude--------------------[array]
%                                - Magnitudes of the fft
%   Faxis------------------------[array]
%                                - Frequency axis of the fft
%                                - optional, default =
%                                1:1:length(amplitude)
%   npeaks-----------------------[integer]
%                                - Maximum number of peaks to be used for
%                                analysis
%                                - optional, default =10
%   Fmargin----------------------[integer]
%                                - If two distances between peaks differ
%                                less then this value, it is considered
%                                that these distances are the same, and
%                                that the peaks are thus belonging to a
%                                harmonic. e.g. if the distance between
%                                peak 2 and 1 is 49 Hz and the distance
%                                between peak 3 and 2 is 51 Hz and Fmargin
%                                = 10. Then (51-49) < 10, thus peak 1,2 and
%                                3 belong to the 50 Hz harmonic
%                                - optional, default = 10;
%--------------------------------------------------------------------------
%DEPENDENCIES
% - none
%--------------------------------------------------------------------------
%Rick Winters, 2018-01-03

found = 0;                                                                  %no harmonics found yet

if nargin < 3                                                               % set variables to default value if not given
    Fmargin = 10;
    if nargin < 2
        Faxis = 1:1:length(amplitude);
    end
end


[pks,locs] = findpeaks(amplitude,Faxis,'MinPeakDistance',45, ...            % find peaks in the fft, with a min distance of 45 Hz, and a min prominence of 50/length(amplitude).
    'MinPeakProminence',median(amplitude));                                 % These are still experimental settings that can be changed if necessary

inds = find((ismember(Faxis,locs)) == 1);                                   % Finds the indices of the Faxis, which have the same value as in found in 'locs'

Fmarginind = find(Faxis < Fmargin);                                         % Find the indices of the Faxis smaller than Fmargin
Fmarginind = Fmarginind(end);                                               % and get the last one

throwaway = (inds <= Fmarginind) | (inds >= length(Faxis)-Fmarginind);      % find the indices of inds where inds is within Fmargin of the Faxis boundaries
inds(throwaway) = [];
locs(throwaway) = [];
pks(throwaway) = [];

throwaway = [];                                                             % create an empty array that stores the indices of peaks that can be thrown away
for i = 1:length(inds)                                                      % This for loop gets the indices of the peaks who are not bigger then x times the mean of the amplitudes 50 indices on both sides
    meanamp = mean(amplitude(inds(i)-Fmarginind:inds(i)+Fmarginind));       % mean value of amplitudes Fmargin Hz around current peak
    peakovermean = amplitude(inds(i)) / meanamp;                            % current peak divided by meanamp
    if peakovermean < 5
        throwaway = [throwaway, i];                                         % If the current peak is not bigger than x times the mean, add the index of the current peak to 'throwaway'
    end
end

locs(throwaway) = [];                                                       % Throw away the peaks found in the previous for-loop
pks(throwaway) = [];

diffs = diff(locs);                                                         % find the distance between the peaks

i = 1;                                                                      % i is the index of the distance that is checked at the moment
groups = [];
checked = [];
while i < length(diffs)                                                     % This while loop groups together indices of peaks that could be part of the same harmonics groups
                                                                            % by checking if the distance between peaks is the same. This while loop is botched together with what was needed and
                                                                            % is not perfect
    
    if sum(checked == i) > 0                                                % If a gap between peaks is already checked, skip it
        i = i+1;
        continue
    end
    ind = find( abs(diffs - diffs(i)) < Fmargin);                           % find the indices of the distances who are about the same the current distance, always returns current index
    checked = [checked, ind];
    %if length(ind) ~= length(ind(1):ind(end))                               % check if there is no completetly different distance in between.
    %    ind = 1;                                                            % e.g. peak 1: 100Hz peak 2 200Hz peak 3 1800Hz peak 4 1900Hz. This isn't a harmonic but would othersise be seen as
    %end                                                                     % a harmonic of 100 Hz
    
    if length(ind)>1, ind = [ind, ind(end)+1]; end                          % If a harmonics is found so far, the length of 'ind' > 1. by adding ind(end)+1 the indices ar the indices of the peaks
                                                                            % whose distances are the same.
    Find = find( abs(locs - diffs(i)) < Fmargin);                           % Check if there is a peaks who's frequency is that of the found distances so far
                                                                            % e.g. locs = [2.5, 7.5, 10, 12.5] kHz. (the 5 khz peak wasn't found for some reason). So far 'ind' will be [2, 3, 4] since
                                                                            % the distances are 2.5 khz. peak 1 was not found because diff(1) = 5 khz, but is actually the base harmonic.
    if Find ~= 0, ind = [Find, ind]; end                                    % Add this peak's index to the front of the array.
    i = i + 1;                                                              % skip all the differences that are already grouped, if not check the next distance
    if length(ind) ~= 1, groups = [groups; {ind}]; end                      % If harmonics are found, put the array of peaks belonging to this harmonic in a cell
    
end
nharmonics = size(groups,1);                                                % Number of harmonics is the same as number of groups
Fharmonics = [];
Aharmonics = [];
for i = 1:nharmonics
    Fharmonics = [Fharmonics, locs(groups{i}(1))];                          % Base harmonic frequency
    Aharmonics = [Aharmonics, pks(groups{i}(1))];                           % Base harmonic amplitude
end

i = 1;
while i < length(Fharmonics)                                                % this while loop filter out Fharmonics whose amplitude is less then 10 micro Volt
    if Aharmonics(i) < 1e-5
        Fharmonics(i) = [];
        Aharmonics(i) = [];
    else
        i = i+1;
    end
end

j = 1;                                                                      % this while loop filters out Fharmonics that of the same harmonic frequency, i have no idea how anymore
while j < length(Fharmonics)
    reduced = 0;
    while reduced == 0
        reduced = 1;
        throwaway = [];
        for i = j+1:length(Fharmonics)
            mult = round(Fharmonics(i)/Fharmonics(j)); 
            absdiff = abs(Fharmonics(i) - mult*Fharmonics(j));
            if (absdiff <= Fmargin/2) && (Aharmonics(i) <= Aharmonics(j))
                throwaway = [throwaway, i];
                reduced = 0;
            end
        end
        Fharmonics(throwaway) = [];
        Aharmonics(throwaway) = [];
    end
    j = j+1;
end

ind = find(Aharmonics < 10*median(amplitude));                              % If a harmonic frequency is found with a base amplitude less then 10* the median value, this gets deleted
Fharmonics(ind) = [];
Aharmonics(ind) = [];


if length(Fharmonics) > 0, found = 1; else Fharmonics = []; Aharmonics = []; end %set 'found' to one if Fharmonics exists, otherwise set 'Fharmonics' and 'Aharmonics to empty array









