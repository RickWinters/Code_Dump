function[data] = getdifftable(signal1,signal2)
%helper function for 'comparesignals', this functions creates the cell
%array used in the uitable
%--------------------------------------------------------------------------
%SYNTAX
% [data] = getdifftable(signa1,signal)
%--------------------------------------------------------------------------
%OUTPUT
% data----------[cell array]
%               - The cell array with data used for the UITable
%--------------------------------------------------------------------------
%INPUTS
% signal1-------[data structure]
%               - Data structure of the first signal as outputted by
%               'analysis'
% signal2-------[data structure]
%               - Data structure of the second signal as outpuut by
%               'analysis'
%--------------------------------------------------------------------------
%DEPENDENCIES
% getnormdistoverlap
%--------------------------------------------------------------------------
%Rick Winters, 2018-01-03

if length(signal1.Fharmonics) > length(signal2.Fharmonics)                  % create a harmonics array from the harmonic frequencies found in the 1st signal and add those found in the second
    harmonicsarray = signal1.Fharmonics;                                    % create harmonics array
    for i = 1:length(signal2.Fharmonics)
        if sum(signal2.Fharmonics(i) == harmonicsarray)>0                   % if harmonics found in 2nd signal already exist in harmonicsarray, skip
            continue
        else
            harmonicsarray = [harmonicsarray, signal2.Fharmonics(i)];       % otherwise add to array
        end
    end
else                                                                        % same here
    harmonicsarray = signal2.Fharmonics;
    for i = 1:length(signal1.Fharmonics)
        if sum(signal1.Fharmonics(i) == harmonicsarray)>0
            continue
        else
            harmonicsarray = [harmonicsarray, signal1.Fharmonics(i)];
        end
    end
end


harmonicsarray = sort(harmonicsarray);                                      % sort array ascending

data = cell(3+length(harmonicsarray),5);                                    % create cell array
data{1,1} = 'Harmonic frequencies';                                         % fill in the top row
data{1,2} = 'Amplitude signal 1';
data{1,3} = 'Amplitude signal 2';
data{1,4} = 'amp 2 / amp 1';
data{1,5} = 'same mean %';

for i = 1:length(harmonicsarray)                                            % fill in the found harmonics in the first column
    data{1+i} = harmonicsarray(i);
end

for i = 1:length(signal1.Fharmonics)                                        % fill in the amplitudes of the harmonics from the first signal, at the correct position
    ind = find(harmonicsarray == signal1.Fharmonics(i));
    data{1+ind(1),2} = signal1.Aharmonics(i);
end

for i = 1:length(signal2.Fharmonics)                                        % fill in the amplitudes of the harmonics form the second signal, at the correct position
    ind = find(harmonicsarray == signal2.Fharmonics(i));
    data{1+ind(1),3} = signal2.Aharmonics(i);
end

for i = 1:length(harmonicsarray)                                            % calculate the difference in amplitude of the harmonics
    if ~( (isempty(data{i+1,2})) || (isempty(data{i+1,3})))
        data{1+i,4} = data{i+1,3} / data{i+1,2};                            
        F = data{i+1,1};
        ind1 = find(signal1.Faxis == F);
        ind2 = find(signal2.Faxis == F);
        overlap = getnormdistoverlap(signal1.sigF(ind1), signal1.stdsigF(ind1), signal2.sigF(ind2), signal2.stdsigF(ind2)); %calculate the normal distribution overlap of the two amplitudes
        data{1+i,5} = num2str(round(overlap,3));
    end
end

rown = size(data,1);                                                        % rownumber
data{rown,1} = 'median signal 1 = ';                                        % add information about the median values of both signals and the difference
data{rown,2} = signal1.med;
data{rown+1,1} = 'median signal 2 = ';
data{rown+1,2} = signal2.med;
data{rown+2,1} = 'median 2 / median 1';
data{rown+2,2} = signal2.med / signal1.med;
%overlap = getnormdistoverlap(signal1.med, signal1.stdmed, signal2.med, signal2.stdmed, 1000000, 1);
overlap = getnormdistoverlap(signal1.med, signal1.stdmed, signal2.med, signal2.stdmed);
data{rown+2,5} = num2str(round(overlap,3));

maxind1 = (signal1.sigF == max(signal1.sigF));
maxind2 = (signal2.sigF == max(signal2.sigF));

data{rown+4,1} = 'peak value signal 1 = ';
data{rown+4,2} = max(signal1.sigF);
data{rown+4,3} = ['at ', num2str(signal1.Faxis(maxind1)),' Hz'];

data{rown+5,1} = 'peak value signal 2 = ';
data{rown+5,2} = max(signal2.sigF);
data{rown+5,3} = ['at ', num2str(signal2.Faxis(maxind2)),' Hz'];

if signal1.Faxis(maxind1) == signal2.Faxis(maxind2)
    data{rown+6,1} = 'peak 2 / peak 1';
    data{rown+6,2} = signal2.sigF(maxind2) ./ signal1.sigF(maxind1);
    %overlap = getnormdistoverlap(signal1.sigF(maxind1), signal1.stdsigF(maxind1), signal2.sigF(maxind2), signal2.stdsigF(maxind2), 1000000, 1);
    overlap = getnormdistoverlap(signal1.sigF(maxind1), signal1.stdsigF(maxind1), signal2.sigF(maxind2), signal2.stdsigF(maxind2));
    data{rown+6,5} = num2str(round(overlap,3));
end

end