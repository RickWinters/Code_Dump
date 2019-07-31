function[allowed,areadif,peakdifs,locdifs,locs,peaks] = comparepsd(psddata,psdf)
%this function compares two power spectra by finding the peaks of the power
%spectra and comparing the peaks with eachother. it also compares the total
%power of both power spectra by summing the values
%==========================================================================
%SYNTAX
%  comparepsd(psddata,psdf)
%  [allowed,areadif,peakdifs,locdifs,locs,peaks] = comparepsd(psddata,psdf)
%==========================================================================
%OUTPUTS
%allowed = string;
%          either 'true' or 'false', indication if both spectra or the same
%          or not, though it is suggested to look at areadif, peakdifs and
%          locdifs for own conclusion
%areadif  = float;
%           the difference in area under the psd curve in percantage.
%           (1-(min/max))*100
%peakdifs = array;
%           array of differences in amplitude of the peaks (sorted
%           descending) of both power spectra, percentage wise
%locdifs  = array;
%           array of differences in frequency of peaks percentagewise
%locs     = 2*n matrix;
%           each row represents the locations on the frequentie axis of the
%           peaks for each power spectra
%peaks    = 2*n matrix;
%           each row represents the amplitudes of the peaks for each power
%           spectra
%==========================================================================
%INPUTS
%psddata  = 2*n matrix;
%           each row is the amplitude array of a power spectrum
%psdf     = 2*n matrix;
%           each row is the frequency axis of a power spectrum

% by Rick Winters
% Feb-Jul 2017

peaks = [];
locs = [];

for k = 1:2
    area(k) = sum(psddata(:,k)); %summation of the array
    mph = max(psddata(:,k))/20; %minimun peak height is 1/20 of heighest peak
    ind = find(psdf(:,k) ~= 0);
    
    y = psddata(ind,k);
    x = psdf(ind,k);
    [peak,loc] = findpeaks(y,x,'MinPeakHeight',mph,'SortStr','descend'); %find peaks of data
    if length(peak) > 5  %if more then five peaks, save only first five
        peak = peak(1:5);
        loc = loc(1:5);
    end
    
    if size(peaks,1) > 0
        if length(peak) > size(peaks,1)
            peak = peak(1:size(peaks,1));
            loc = loc(1:size(peaks,1));
        elseif length(peak) < size(peaks,1)
            peaks(length(peak)+1:end,:) = [];
            locs(length(loc)+1:end,:) = [];
        end
    end
    
    
    peaks(:,k) = peak; 
    locs(:,k) = loc;

    %plot(psdf(:,k),psddata(:,k))
    hold on
    if k == 2 
        for l = 1:size(peaks,1)
            temppeaks = peaks(l,:); %separate peak L from matrix
            templocs = locs(l,:); %separate loc L from matrix 
            peakdifs(l) = 100 - (min(temppeaks)/max(temppeaks))*100; %calculate percentagewise difference
            locdifs(l) = 100 - (min(templocs)/max(templocs))*100;
        end
        allowed = 'false';
        areadif = 100 - (min(area)/max(area)*100); %calculate percentagewise difference in power
        if (mean(peakdifs) < 50 && mean(locdifs) < 5) || areadif<10 %(if the meandifference of peaks is less then 50% and if the mean difference of location is less then 5%) or if the total power difference is less then 10% ==> suggest allowed
            allowed = 'true';
        end
        %xlabel(strcat({strcat('area 1 = ',num2str(area(1)),' peakdifs = ',num2str(peakdifs));
            %strcat('area 2 = ',num2str(area(2)),' locdifs = ',num2str(locdifs));
            %strcat('difference in total power = ',num2str(areadif),' % allowed = ',allowed)}))
    end
    
    %plot(locs(:,k),peaks(:,k),'o')
    
    k = k+1;
    
end
end