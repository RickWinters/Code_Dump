function[] = comparesignals(signal1, signal2, Mtime, titles, closefig, fontsize)
%This function compares two measuered signals by plotting both fourier
%components in one subplot, plotting the difference in another subplot at
%the top right and giving information about the harmonics of both signals
%in a table in the bottom right, in that table the median values are also
%givin. This function analyse the difference between two measured signals.
%Measurement time of both signals must be the same
%
%It is possible to input multiple measurements for each signal. In this
%case of each measurement the frequency domain will be calculated, and the
%mean at every frequency will be shown
%--------------------------------------------------------------------------
%SYNTAX
% comparesignal(signal1, signal2, Mtime, npeaks)
% comparesignal(signal1, signal2, Mtime, npeaks, titles)
%--------------------------------------------------------------------------
%OUTPUTS
% nothing, outputs figure
%--------------------------------------------------------------------------
%INPUTS
% signal1---------[m*n array]
%                 - Amplitude array of signal 1, where m is the number of  
%                 measurements and n is the number of data points per
%                 measurement.
% signal2---------[m*n array]
%                 - Amplitude array of signal 2, where m is the number of
%                 measurements and n is the number of data points per
%                 measurement.
% Mtime-----------[float]
%                 - Measurement time of both signals, must be equal in
%                 both signals
% titles----------[3*1 Cell array]
%                 - A cell array with 3 strings, the first string is the
%                 title used for signal 1, and the second string is used
%                 for title 2. The figure at the end is saved with the name
%                 [titles{1},' vs ',titles{2},' at ',titles{3}].
%                 - Optional, default = {'signal 1','signal 2','standard   
%                                         setting'}
% closefig--------[0 or 1]
%                 - If 0, the figure doest close at the end, if 1 the
%                 figure closes after saving
%                 - Optional, default = 1
% fontsize--------[integer]
%                 - Fontsize of the text in the figure
%                 - Optional, default  = 15
%--------------------------------------------------------------------------
%DEPENDS ON FUNCTIONS
% signalanalysis
% - calculateFFT
% - findharmonics
% getdifftable
% - getnormdistoverlap
%--------------------------------------------------------------------------
%Rick Winters
%2017-10-18

['starting with ', titles{1},' vs ',titles{2},'-',titles{3}]                % output status string to command window so user can see whats happening
f = figure('units','normalized','outerposition',[0 0 1 1]);                 % new figure, full screen
%f = figure;
s = title([titles{1},' vs ',titles{2}]);                                    % figure title

if nargin < 6
    fontsize = 22;
    if nargin < 5                                                           % set default values if not given
        closefig = 1;
        if nargin<4                                                              
            titles = {'measurement 1','measurement 2','standard setting'};
        end
    end
end

subplot(1,2,1)                                                              % Left plot
if size(signal1,1) > 1
    titlestring = ['Frequency domains of both signals, '; 
           'averaged from multiple measurements'];
else
    titlestring = 'Frequency domains of both signals';
end

ax = gca;
ax.Position = [ax.OuterPosition(1), ax.Position(2), ax.OuterPosition(3), ax.Position(4)]; %Increas size of plot to fill the screen

'starting with signal 1'                                                    % Updating user on status
data1 = signalanalysis(signal1,Mtime);                                      % analyse the first signal
'starting with signal 2'                                                    % Updating user on status
data2 = signalanalysis(signal2,Mtime);                                      % analyse the second signal 
set(gca,'FontSize',fontsize)
h = findobj(gca,'Type','Line');
title(titlestring)
legend([h(4),h(1)],titles);                                                 % set correct legend, using the Line handles from h



'Plotting time domain figure'                                               % Updating user on status
subplot(2,2,2)                                                              % uppr right figure
ax = gca;
ax.Position = [ax.OuterPosition(1), ax.Position(2), ax.OuterPosition(3), ax.Position(4)];

dt = Mtime/length(signal1);                                                 % sampling time
time = 0:dt:dt*length(signal1)-dt;                                          % time axis
hold on
plot(time(1:1000),signal1(1,1001:2000))                                     % plot first measurement of signal 1
plot(time(1:1000),signal2(1,1001:2000))                                     % plot first measurement of signal 2
hold off
xlim([0,1000*dt])                                                           % limit plot to first x indices for better readability
%xlim([1,2])
xlabel('time (s)');
ylabel('amplitude (V)');
title('time domains of signals, first 1000 indices');
legend(titles{1},titles{2});
set(gca,'FontSize',fontsize)
grid on

'Gathering table data'                                                      % Updating user on status
data = getdifftable(data1,data2);                                           % get table with data such as found harmonic frequencies and amps, median values etc

subplot(2,2,4);                                                             % lower right figure
ax = gca;
ax.Position = ax.OuterPosition;
pos = get(gca,'Position');                                                  % get position values
axis off                                                                    % turn off the axis
t = uitable(f);                                                             % create uitable handle in main figure
t.Data = data;
t.Units = 'normalized';                                                     % Set uitable units to 'normalized'
t.Position = pos;                                                           % set uitable position to same position as subplot(2,2,4)
t.ColumnName = data(1,:);                                                   % Get the column names from the data-table
resizedifftable(t, data)
data(1,:) = [];                                                             % remove this data from variable
t.Data = data;                                                              % set the uitable.data 

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
titlestring = [titles{1},' vs ',titles{2},' at ',titles{3}];                % create the titlestring from the titles cell aray
text(0.5, 1,titlestring,'HorizontalAlignment','left','VerticalAlignment', 'top','FontSize',fontsize); 

'saving figure'                                                             % update user in command window
titles{1} = strrep(titles{1},' ','_');                                      % replace all the spaces in the titles with underscores so that the title of the figure can be used in LaTeX
titles{2} = strrep(titles{2},' ','_');
titles{3} = strrep(titles{3},' ','_');
saveas(gca,strcat('C:\Dropbox\Apps\ShareLaTeX\main report internship UT\figures\methodology\',[titles{1},'_vs_',titles{2},'_at_',titles{3},'.png']),'png') % Save figure in a folder with correct title, 
if closefig == 1
    close all
end
['done with ', titles{1},' vs ',titles{2},' at ',titles{3}]
end