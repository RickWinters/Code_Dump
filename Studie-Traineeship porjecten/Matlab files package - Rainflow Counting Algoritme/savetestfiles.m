function[] = savetestfiles(mainfolder,ntests,multiplier)
%This function separates the signal and time components from
%'ImExport(i).mat' which comes from FamosExport. Next to that it multiplies
%the signal component to get the G acceleration and rectifies the time axis
%Make sure that in 'mainfolder' the folders 'test1', 'test2' ... are placed
%before this function is run.
%==========================================================================
%SYNTAX
% savetestfiles(mainfolder)
% savetestfiles(mainfolder,ntests)
% savetestfiles(mainfolder,ntests,multiplier)
%==========================================================================
%OUTPUT
% none, saves files on disk
%==========================================================================
%INPUT
% mainfolder          = character array / string
%                       a string of the folder where the ImExport files are
%                       placed
% ntests              = integer
%                       Number of samples tested with experiment
%                       optional
%                       default = 8
% multiplier          = float
%                       Number to multiply signal component with, for
%                       example if the sensor is measured at 10mV/G, the
%                       multiplier should be '100' to go from mV to G
%                       optional
%                       default = 100

if nargin < 3
    multiplier = 100;
    if nargin < 2
        ntests = 8;
    end
end


%hour = 1:6

for i = 1:ntests
    progress = strcat('sample =  ',num2str(i),'/',num2str(ntests)) %print out progress
    file = strcat('\ImExport',num2str(i),'.mat');                  %select correct file
    load(strcat(mainfolder,file));
    signal = eval(strcat('Channel_0',num2str(i)))*multiplier;      %extract amplitude signal and multiply with 'multiplier' to get acceleration in G
    time = eval(strcat('Channel_0',num2str(i),'_x'));              %extract time axis
    dt = time(3)-time(2);                                          %rectify time axis
    Tend = dt*length(signal)-dt;
    time = (0:dt:Tend)';
    save(strcat('D:\Stage_Thales\MATLAB\steel plate test\test 2\test',num2str(i),'\file',num2str(1),'signal'),'signal')  %save signal file
    save(strcat('D:\Stage_Thales\MATLAB\steel plate test\test 2\test',num2str(i),'\file',num2str(1),'time'),'time')      %save time file
end