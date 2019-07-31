function[overlap] = getnormdistoverlap(mean1,std1,mean2,std2,npoints,plotinfo)
%This functions returns the overlap of two normal distributions to see if
%the means are significantly diffirent. This is done by calculating both
%normal distributions and summing the minimun values.If the overlap of two
%normal distributions is less than 5 % this can be considered a significant
%difference
%--------------------------------------------------------------------------
%SYNTAX
% overlap = getnormdistoverlap(mean1,std1,mean2,std2)
% overlap = getnormdistoverlap(mean1,std1,mean2,std2,div)
% overlap = getnormdistoverlap(mean1,std1,mean2,std2,div,plotinfo)
%--------------------------------------------------------------------------
%OUTPUT
% overlap------------------[float]
%                          - Represents how much the normal distributions
%                          overlap, returned in percentages
%--------------------------------------------------------------------------
%INPUT
% mean1--------------------[float]
%                          - Mean value of the first distribution
% std1---------------------[float]
%                          - Standard deviation of the first distribution
% mean2--------------------[float]
%                          - Mean value of the second distribution
% std2---------------------[float]
%                          - Standard deviation of the second distribution
% npoints------------------[integer]
%                          - Number of points on the x-axis, The higher
%                          this number is, the more precise the overlap
%                          will be calculated, the longer it takes
%                          - Optional, default = 1000000
% plotinfo-----------------[0 or 1]
%                          - If 1 plot both normal distributions, if 0 do
%                          not plot
%                          - Optional, default = 0
%--------------------------------------------------------------------------
%DEPENDENCIES
% none
%--------------------------------------------------------------------------
%Rick Winters, 2017-10-24
%                          

if nargin < 6                                                               % set default values if needed
    plotinfo = 0;
    if nargin < 5
        npoints = 1000000;
    end
end

minval = min(-3*std1+mean1, -3*std2+mean2);                                 % minimun value of x-axis
maxval = max(3*std1+mean1, 3*std2+mean2);                                   % maximum value of x-axis

div = (maxval - minval)/npoints;                                            % division on the x-axis

x = [minval:div:maxval];                                                    % create x-axis
normdist1 = normpdf(x,mean1,std1);                                          % calculate normal distribution 1
normdist2 = normpdf(x,mean2,std2);                                          % calculate normal distribution 2
mins = min([normdist1;normdist2]);                                          % find the mininum of the two normal distributions across the x-axis

overlap = sum(mins)*div*100;                                                % calculate the overlapping area

if plotinfo == 1                                                            % if required, plot both normal distributions and overlapping area
    figure('units','normalized','outerposition',[0 0 1 1])
    grid on
    hold on
    plot(x,normdist1);
    plot(x,normdist2);
    plot(x,mins);
    xlabel(['x  overlap = ',num2str(overlap)]);
    ylabel('chance')
    title(['mean 1 = ',num2str(mean1),' std 1= ',num2str(std1),' mean 2 = ',num2str(mean2),' std 2 = ',num2str(std2)])
    skip = ceil(npoints/1000);
    ind = [0:skip:npoints];
    ind(1) = 1;
    for i = ind
        line([x(i),x(i)],[0,mins(i)])
    end
    drawnow()
    legend('normdist1','normdist2','min')
    figure(1)
end

