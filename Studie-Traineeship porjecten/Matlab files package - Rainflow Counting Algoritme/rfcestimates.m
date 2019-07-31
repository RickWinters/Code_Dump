function[] = rfcestimates(ntests,mainfolder,Sult,Stensile,Ntensile,Istruct,Mstruct,flim,tlim,psdon)

T = []
for i = 1:ntests
    figure;
    load(strcat(mainfolder,'test',num2str(i),'\file1signal.mat'))
    signal = signal - mean(signal);
    load(strcat(mainfolder,'test',num2str(i),'\file1time.mat'))
    ind = find(time > tlim(1) & time < tlim(2));
    dt = time(3) - time(2);
    signal = signal(ind);
    time = time(ind);
    T = [T, analysesignal(signal,dt,Sult,Stensile,Ntensile,Istruct,Mstruct,flim,psdon)];
end

figure;
hold on
grid on
meantime = mean(T); %mean of time
stdtime = std(T);   %standard deviation
threesigmarange = [(meantime-3*stdtime),(meantime+3*stdtime)]; %three sigmarange
T/60 %output the measured times in minutes to the command window
output = [meantime/60, stdtime/60, threesigmarange/60] %output data to command window for analysis (mean, std, threesigmarange)

xaxis = [(meantime/60)-3*(stdtime/60):1:(meantime/60)+3*(stdtime/60)];   %create x-axis for normal probability plot, from \mu - 3*\sigma to \mu + 3*\sigma
yaxis = normpdf(xaxis,meantime/60,stdtime/60);  %calculate y axis of normal probability plot
plot(xaxis,yaxis) %plot normal probability plot of all data

limits = [(meantime-stdtime),(meantime+stdtime)];   %limitations to delete everythine 1 std away from mean as 'outlier'
i = 1;
while i < length(T) %this while loop removes all data that is seen as outlier
    if T(i) < limits(1) || T(i) > limits(2)
        T(i) = [];
    end
    i = i+1;
end
meantime = mean(T); %do all the normal probability plot stuff again
stdtime = std(T);
threesigmarange = [(meantime-3*stdtime),(meantime+3*stdtime)];
T/60
filteredoutput = [meantime/60, stdtime/60, threesigmarange/60]

hold on
xaxis = [(meantime/60)-3*(stdtime/60):1:(meantime/60)+3*(stdtime/60)];
yaxis = normpdf(xaxis,meantime/60,stdtime/60);
plot(xaxis,yaxis)
xlabel('time to crack initialization (min)')
ylabel('probability')
legend('all data','outliers removed')

save(strcat(mainfolder,'rfcestimates'),'T')

grid on

figure;
boxplot(T/60)
ylabel('time (min)')
grid on