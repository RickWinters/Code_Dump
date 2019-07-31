clc, close, clear

% number of settings per generation
nPopulation = 10;
% number of generations
nGenerations = 500;

for leveli = 1
    level = leveli;
    %setting up the initial setting variables
    Vtotal = randi([1 40],nPopulation,1)';
    angle = randi([-180 180],nPopulation,1)';
    plotsim = 0;
    
    %copying the initial settings to save them for later use
    Vtotalnull = Vtotal;
    anglenull = angle;
    finished = 0;
    j = 0;
    lastminscores = [];
    while j < nGenerations && finished == 0
        j = j + 1
        plotsim = 0; %turn off plotting simulation
        if (j == nGenerations) && nPopulation <= 10
            plotsim = 1; %turn on plotting simulation at last generation
        end
        
        %possibly mutate all the genes
        for i = 2:nPopulation
            mutationchange = randi(100);
            if mutationchange < 80
                Vtotal(i) = Vtotal(i) + (rand-0.5)*4;
                angle(i) = angle(i) + (rand-0.5)*20;
            end
        end
        
        %evaluate and score all the genes
        for i = 1:nPopulation
            score(i) = minigolf(Vtotal(i),angle(i),level,plotsim); %simulating all the genes of one population and determining their endscore
        end
        
        %    determining the min, mean and max score of that generation. for later
        %    analysis of the data
        min_score(j) = min(score);
        mean_score(j) = mean(score);
        max_score(j) = max(score);
        
        
        %putting the scores and used settings in a matrix
        results(1,:) = score;
        results(2,:) = angle;
        results(3,:) = Vtotal;
        
        %sorting the matrix by ascending score values
        [sorted,I] = sort(results(1,:));
        results = results(:,I);
        
        %overwrite the worst 50% of genes with the best 50% of genes
        results([2 3],[floor(nPopulation/2) + 1:nPopulation]) = results([2 3],[1:floor(nPopulation/2)]);
        
        %extracht the parameters of the genes into the variables,
        angle = results(2,:);
        Vtotal = results(3,:);
        
        %keep track of the last minimal scores
        lastminscores = [lastminscores min(score)]
        if length(lastminscores) > 20
            lastminscores(1) = [];
            if (std(lastminscores) < 0.1e-15 && mean(lastminscores) < 1) %end simulations if there is no improvement in min scores
                finished = 1;
            end
        end
        %if score has reached end simulation
        if lastminscores(length(lastminscores)) == 0
            finished = 1;
        end
    end
    plotsim = 1;
    i = find(sorted==min(score));
    i = i(1);
    
    minigolf(Vtotal(i),angle(i),level,plotsim);
    
    figure
    subplot(2,2,1)
    hold on
    plot(mean_score,'.b')
    plot(min_score,'.g')
    plot(max_score,'.r')
    legend('mean','min','max')
    
    
    subplot(2,2,3)
    hold on
    plot(anglenull,'.r')
    plot(angle,'.g')
    legend('null','end')
    title('angle')
    
    subplot(2,2,4)
    hold on
    plot(Vtotalnull,'.r')
    plot(Vtotal,'.g')
    legend('null','end')
    title('Vtotal')
end




