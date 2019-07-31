clc, close, clear all

% number of settings per generation
nPopulation = 20
% number of generations
nGenerations = 500

%setting up the initial setting variables
Vtotal = randi([1 20],nPopulation,1)'
ballangle = randi([-45 45],nPopulation,1)'
S_y = randi([3 20],nPopulation,1)'
plotsim = 0

%copying the initial settings to save them for later use
Vtotalnull = Vtotal;
ballanglenull = ballangle;
S_ynull = S_y;

%deciding end parameters, what the best thing is for the system to reach
Sxend = 9;
Syend = 5;

finished = 0;
j = 0;
lastminscores = [];

while j < nGenerations && finished == 0
    j = j + 1
    plotsim = 0; %turn off plotting simulation
    if (j == nGenerations || j == 1) && nPopulation <= 10
        plotsim = 1; %turn on splotting simulation at last generation
    end
    
    for i = 1:nPopulation
        mutationchange = randi(100);
        if mutationchange < 80
            Vtotal(i) = Vtotal(i) + (rand-0.5)*4;
            ballangle(i) = ballangle(i) + (rand-0.5)*20;
            S_y(i) = S_y(i) + (rand-0.5)*10;
        end
    end
    
    for i = 1:nPopulation
        score(i) = simulation(S_y(i),Vtotal(i),ballangle(i),plotsim,Sxend,Syend,i); %simulating all the genes of one population and determining their endscore
    end
    
    %    determining the min, mean and max score of that generation. for later
    %    analysis of the data
    min_score(j) = min(score);
    mean_score(j) = mean(score);
    max_score(j) = max(score);
    
    % one- child per generation evolutions
    
    %child, first & second parent will be tracked in arrays so they can be
    %analysed later.
    childs = find(score==max(score));%finding what the child should be
    child(j) = childs(randi(length(childs))); %in case there are more genes with the same score, a random gene gets chosen
    first_parents = find(score==min(score)); %finding what the first parent should be
    first_parent(j) = first_parents(randi(length(first_parents))); %in case there are more first_parents, pick a random one
    score(first_parent(j)) = max(score)+1; %change the score of the first parent so a second one can be chosen
    second_parents = find(score==min(score)); %find second parents
    second_parent(j) = second_parents(1); %select random second parents in case there are more
    
    %change the settings of the child by the average of the parents
    Vtotal(child(j)) = (Vtotal(first_parent(j)) + Vtotal(second_parent(j)))*0.5;
    ballangle(child(j)) = (ballangle(first_parent(j))+ballangle(second_parent(j)))*0.5;
    S_y(child(j)) = (S_y(first_parent(j)) + S_y(second_parent(j)))*0.5;
    
    lastminscores = [lastminscores min(score)]
    if length(lastminscores) > 20
        lastminscores(1) = [];
        if std(lastminscores) < 0.1e-15 && mean(lastminscores) < 3
            finished = 1;
        end
    end
end

plotsim = 1;
i = find(score==min(score))
i = i(1)

simulation(S_y(i),Vtotal(i),ballangle(i),1,Sxend,Syend,1)
figure
subplot(2,2,1)
hold on
plot(mean_score,'.b')
plot(min_score,'.g')
%plot(max_score,'.r')
legend('mean','min')


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

