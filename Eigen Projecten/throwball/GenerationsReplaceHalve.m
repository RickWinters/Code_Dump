clc, close, clear

% number of settings per generation
nPopulation = 200;
% number of generations
nGenerations = 100;

%setting up the initial setting variables
Vtotal = randi([1 25],nPopulation,1)';
ballangle = randi([-45 45],nPopulation,1)';
S_y = randi([3 10],nPopulation,1)';
plotsim = 0;

%copying the initial settings to save them for later use
Vtotalnull = Vtotal;
ballanglenull = ballangle;
S_ynull = S_y;



%deciding end parameters, what the best thing is for the system to reach
Sxend = 10;
Syend = 15;

finished = 0;
j = 0;
lastminscores = [];
while j < nGenerations && finished == 0
    j = j + 1
    plotsim = 0; %turn off plotting simulation
    if (j == nGenerations) && nPopulation <= 10
        plotsim = 1; %turn on splotting simulation at last generation
    end
    
    %possibly mutate all the genes
    for i = 2:nPopulation
        mutationchange = randi(100);
        if mutationchange < 80 
            Vtotal(i) = Vtotal(i) + (rand-0.5)*2;
            ballangle(i) = ballangle(i) + (rand-0.5)*2;
            S_y(i) = S_y(i) + (rand-0.5)*2;
        end
    end
    
    %evaluate and score all the genes
    for i = 1:nPopulation
        score(i) = simulation(S_y(i),Vtotal(i),ballangle(i),plotsim,Sxend,Syend,i); %simulating all the genes of one population and determining their endscore
    end
    
    %    determining the min, mean and max score of that generation. for later
    %    analysis of the data
    min_score(j) = min(score);
    mean_score(j) = mean(score);
    max_score(j) = max(score);
    
    
    %putting the scores and used settings in a matrix
    results(1,:) = score;
    results(2,:) = ballangle;
    results(3,:) = Vtotal;
    results(4,:) = S_y;
        
    %sorting the matrix by ascending score values
    [sorted,I] = sort(results(1,:));
    results = results(:,I);
    
    %overwrite the worst 50% of genes with the best 50% of genes
    results([2 3 4],[floor(nPopulation/2) + 1:nPopulation]) = results([2 3 4],[1:floor(nPopulation/2)]);
    
    %extracht the parameters of the genes into the variables,
    ballangle = results(2,:);
    Vtotal = results(3,:);
    S_y = results(4,:);

    lastminscores = [lastminscores min(score)]
    if length(lastminscores) > 30
        lastminscores(1) = [];
        if std(lastminscores) < 0.1e-10 && mean(lastminscores) < 3
            finished = 1;
        end
    end   
end

plotsim = 1;
i = find(sorted==min(score));
i = i(1);

simulation(S_y(i),Vtotal(i),ballangle(i),1,Sxend,Syend,1)
figure
subplot(2,2,1)
hold on
plot(mean_score,'.b')
plot(min_score,'.g')
plot(max_score,'.r')
legend('mean','min','max')


subplot(2,2,2)
hold on
plot(S_ynull,'.r')
plot(S_y,'.g')
legend('null','end')
title('S_y')

subplot(2,2,3)
hold on
plot(ballanglenull,'.r')
plot(ballangle,'.g')
legend('null','end')
title('ballangle')

subplot(2,2,4)
hold on
plot(Vtotalnull,'.r')
plot(Vtotal,'.g')
legend('null','end')
title('Vtotal')

