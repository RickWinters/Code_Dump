function[diffmag,amp,amptime,means,indices] = analysePSDsignal(signal,Mtime,Fac,timeinds,LPFF,doplot,titlestring,saveplot,newfigure,linecolor,legendstring)
% This function combines 'PhaseSD' and 'exctractPSDamps' to analyse a
% signal with Phase Sensitive Detection. If no time indices are given for
% when to break up the signal it is tried automatically to do so, however
% this is still buggy. For every timeblock the mean amplitude at Fac is
% extracted using 'exctractPSDamps', and this is shown with a straigt line
% and a textbox. Next to that the DiffMag value gets calculated.
%--------------------------------------------------------------------------
%SYNTAX
% analysePSDsignal(signal,Mtime,Fac,1)
% outputs = analysePSDsignal(signal,Mtime,Fac)
% outputs = analysePSDsignal(signal,Mtime,Fac,timeinds)
% outputs = analysePSDsignal(signal,Mtime,Fac,timeinds,LPFF)
% outputs = analysePSDsignal(signal,Mtime,Fac,timeinds,LPFF,doplot)
% outputs =
% analysePSDsignal(signal,Mtime,Fac,timeinds,LPFF,doplot,titlestring)
% outputs =
% analysePSDsignal(signal,Mtime,Fac,timeinds,LPFF,doplot,titlestring,saveplot)
% 
%--------------------------------------------------------------------------
%OUTPUT
% diffmag-----------------------[float]
%                               - DiffMag value of sequence. Sequence must
%                                 consist a measurement including two time
%                                 blocks without DC offset and two with DC
%                                 offset. i.e. 0V, + DC offset, 0V , - DC
%                                 offset
% amp---------------------------[array]
%                               - Array of the estimated amplitude over
%                                 time of the Fac frequency.
% amptime-----------------------[array]
%                               - Time array, where the first 2/LPFF is
%                                 removed. i.e. if LPFF = 20 Hz, the first
%                                 0.1 seconds is removed to delete Filter
%                                 settling time.
% means-------------------------[array]
%                               - Array of mean amplitudes found
% indices-----------------------[matrix]
%                               - A matrix of the indices, where every row
%                                 represents a different time block.
%                                 Columnn 1 is the starting index of this
%                                 time block and Columnn 2 is the last
%                                 index of this time block
%--------------------------------------------------------------------------
%INPUT
% signal------------------------[array]
%                               - Raw signal to be analysed
% Mtime-------------------------[float]
%                               - Measurement time of the signal
% Fac---------------------------[float]
%                               - Frequency on which the PSD will be used
% timeinds----------------------[array]
%                               - Indices on the time axis on where to
%                                 break the time up in different blocks.
%                                 when timeinds == 0, the signal gets
%                                 broken up automatically, however this is
%                                 not perfect yet so it is recommended to
%                                 define the indices.
%                               - Optional, default = 0
% LPFF--------------------------[integer]
%                               - Frequency used by the low-pass filter
%                                 at the end of PSD
%                               - Optional, default = 20
% doplot------------------------[0 or 1]
%                               - If 0, no plot; if 1 creates a plot
%                               - Optional, default = 1
% titlestring-------------------[string]
%                               - Title of the figure
%                               - Optional, default = 'PSD analysis'
% saveplot----------------------[0 or 1]
%                               - If 0, figure is not saved, if 1, figure
%                                 is saved
%                               - Optional, default = 0
% newfigure---------------------[0 or 1]
%                               - If 0, no new figure is made. this makes
%                                 it possible to plot a second signal by
%                                 calling this function again with            
%                                 newfigure = 0                                             
%                               - Optional, default = 1
% linecolor---------------------[string]
%                               - A strinig representing a color propertie
%                                 of a line. i.e. 'red', 'black', 'k' ,'r'.
%                                 Can also be: ' ', with this no line color
%                                 is set
%                               - Optional, default = ' '
% legendstring------------------[cell array of strings]
%                               - Lets say this function is called for the
%                                 third time and all three plots are in the
%                                 same figure, legendstring can be set to
%                                 'legendstring  = {'signal 1','signal
%                                 2','signal 3'} in order to get the legend
%                                 of the figure correctly. If legendstring
%                                 = {' '}, no legend will be made
%                               - Optional, default = {' '} 
%--------------------------------------------------------------------------
%DEPENDENCIES
% PhaseSD(time,signal,Fsample,Fac,LPFF)
% extractPSDamps(time,amp,LPFF,locs)
% reset_text(fighandle)
%--------------------------------------------------------------------------
%Rick Winters, 2018-01-03
if nargin < 11
    legendstring = {' '};
if nargin < 10
    linecolor = ' ';
if nargin < 9
    newfigure = 1;
if nargin < 8
    saveplot = 0;
if nargin < 7
    titlestring = 'PSD analysis';
if nargin < 6
    doplot = 1;
if nargin < 5
    LPFF = 20;
if nargin < 4
    timeinds = 0;
end
end
end
end
end
end
end
end

if doplot == 0, saveplot = 0; end

Fsample = length(signal)./Mtime;                                            % calculate sampling frequency

dt = 1/Fsample;                                                             % calculate sampling time
time = [0:dt:Mtime-dt];                                                     % setup time axis

dataout = PhaseSD(time,signal,Fsample,Fac,LPFF);                            % do the phase sensitive detection
amp = dataout.Fac_amp;                                                      % extract only the amplitude over time
LPFF = dataout.LPFF;                                                        % extract low pass filter frequency

[means,indices,amptime,amp] = exctractPSDamps(time,amp,LPFF,timeinds);      % Extract the different mean amplitudes
if length(means) == 4; diffmag = mean([means(2)-means(1), means(4)-means(3)]); % Calculate the mean variables
else diffmag = 'unavailable'; end

indoffset = indices(1,1)-1;
for i = 1:length(means)
    meanvars(i) = std(amp(indices(i,1)-indoffset:indices(i,2)-indoffset-1));
end

if doplot == 1                                                              % plot figure
    if newfigure == 1
        figure('units','normalized','outerposition',[0 0 1 1])              % new fullscreen figure
        grid on
        hold on
    end
    set(gca,'YLimMode','auto')
    if linecolor ~= ' ', plot(amptime,amp,'Color',linecolor)                % plot amplitude
    else plot(amptime,amp); end
    xlabel('time (s)')
    ylabel(['amplitude (mV)'])
    title('amplitude analysis of PSD')
   
    if timeinds ~= 0, amptime = time; end
    for i = 1:length(means)                                                 % this for loop plots the lines of the means and puts text with info above the means
        X = [amptime(indices(i,1)),amptime(indices(i,2))];                  % X coordinates of lines
        Y = [means(i),means(i)];                                            % Y coordinates of lines
        if linecolor ~= ' ', line(X,Y,'LineWidth',2,'Color',linecolor)      % Draw a thick line of the mean amplitude of timeblock
        else, line(X,Y,'LineWidth',2); end
        
        string = {['mean = ',num2str(means(i)),' mV'];
            ['std = ',num2str(meanvars(i)),' mV']};
        X = (amptime(indices(i,2))-amptime(indices(i,1)))/2 + amptime(indices(i,1)); 
        Y = means(i);
        h = text(X,Y,string,'Visible','off');
        X = X - h.Extent(3)/2;
        Y = Y + h.Extent(4);
        if linecolor ~= ' ', h = text(X,Y,string,'FontSize',14,'Color',linecolor);    % Textbox with mean value in the middle of the timeblock
        else, h = text(X,Y,string,'Fontsize',14); end
    end
    if diffmag ~= 'unavailable'
        string = {'DiffMag value =';
            [num2str(round(abs(diffmag),4)),' mV']};
    else
        string = {'DiffMag value = ';
            'unavailable'};
    end
    Y = Y + h.Extent(4);
    if linecolor ~= ' ', text(X,Y,string,'FontSize',14,'Color',linecolor)   % Textbox with DiffMag value below last mean text box
    else, text(X,Y,string,'FontSize',14); end
    
    title(titlestring)
end

set(gca,'FontSize',20)
ax = gca;
ax.Position(1) = ax.TightInset(1);
ax.Position(2) = ax.TightInset(2);
ax.Position(3) = 1-ax.TightInset(1)-ax.TightInset(3);
ax.Position(4) = 1-ax.TightInset(2)-ax.TightInset(4);


%set(gca,'YLim',[0 20])
reset_text(gca)

if legendstring{1}(1) ~= ' '
    inds = [];
    for i = 1:length(legendstring)
        inds = [inds, 5*(length(legendstring)-(i-1))];
    end
    h = findobj(gca,'Type','Line');
    legend(h(inds),legendstring)
end

if saveplot == 1                                                            % save figure to certain folder
    titlestring = strrep(titlestring,' ','_');
    savefolder = 'C:\Dropbox\Apps\ShareLaTeX\main report internship UT\figures\experiments\resovist_experiment\';
    'saving figure'
    saveas(gca,strcat(savefolder,titlestring,'_no_text'),'png')
end





