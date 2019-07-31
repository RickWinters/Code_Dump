function[] = compareresults(mainfolder)
% This function compares the rfc estimates and NFovertime results from a
% measurement. It creates a figure of both boxplots and a figure of both
% normal probability distributions and calculating the overlap in the
% distributions
%==========================================================================
%Syntax
% compareresults(mainfolder)
%==========================================================================
%OUTPUT
% none
%==========================================================================
%INPUT
% mainfolder        = characeter array / string
%                     mainfolder where the measurements are saved


%mainfolder = 'D:\Stage_Thales\MATLAB\steel plate test\test 2\';

load(strcat(mainfolder,'rfcestimates')); %load rfc estimates
load(strcat(mainfolder,'nfovertimetimes')); %load NFovertimetimes

T = T/60; %convert to minutes
endtime = endtime/60;

figure;
data(1:length(T),1) = T'; %put the RFC estimates ('T') and NFovertime ('endtime') in a data array for boxplot plots
data(1:length(endtime),2) = endtime';
G = [1 2];
boxplot(data,G,'labels',{'rfc estimates','measured times'},'widths',[0.75 0.75])
grid on


figure;
hold on
meantimeT = mean(T); %calculate mean and std of RFC estimates
stdtimeT = std(T);

meantimeNF = mean(endtime); %calculate mean and std of NFovertime
stdtimeNF = std(endtime);

daxis = 0.5; %Create x-axis of T and NF 
xaxisT = [meantimeT-3*stdtimeT:daxis:meantimeT+3*stdtimeT];
xaxisNF = [meantimeNF-3*stdtimeNF:daxis:meantimeNF+3*stdtimeNF];

%find lower limit and higher limit of xaxis and create single xaxis from
%both normal probability distributions
lowlim = min(xaxisT); 
highlim = max(xaxisT);

if lowlim > min(xaxisNF)
    lowlim = min(xaxisNF);
end
if highlim < max(xaxisNF)
    highlim = max(xaxisNF);
end

%recreate both normpdf on common xaxis
xaxis = [lowlim:daxis:highlim];
yaxisT = normpdf(xaxis,meantimeT,stdtimeT);
yaxisNF = normpdf(xaxis,meantimeNF,stdtimeNF);

%plot both normpdfs
plot(xaxis,yaxisT)
plot(xaxis,yaxisNF)


sum = 0;
%calculate overlap by summing values over xaxis and multiply by daxis and
%draw lines in overlap
for i = 1:length(xaxis)
    sum = sum + min([yaxisT(i) yaxisNF(i)]);
    line([xaxis(i) xaxis(i)],[0, min([yaxisT(i) yaxisNF(i)])])
end
sum = sum*daxis;


xlabel(strcat({strcat('time (min)');
    strcat('overlap = ',num2str(sum*100),'%')}))
ylabel('probability')
grid on
legend('rfc estimates','measured time')

    

