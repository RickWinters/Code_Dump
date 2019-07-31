function[history] = plothistory(creatures,j,history)

history.meanage(j) = mean(creatures.alive);
history.minage(j) = min(creatures.alive);
history.maxage(j) = max(creatures.alive);

history.meanscore(j) = mean(creatures.score);
history.minscore(j) = min(creatures.score);
history.maxscore(j) = max(creatures.score);


if mod(j,100) == 0
    
    if j > 500
        clf(figure(2));
    end
    
    %if j > 100, close(2), end
    figure(2)
    subplot(2,1,1)
    hold on
    if j > 500
        plot(history.meanage(j-500:j),'b')
        plot(history.minage(j-500:j),'r')
        plot(history.maxage(j-500:j),'g')
    else
        plot(history.meanage,'b')
        plot(history.minage,'r')
        plot(history.maxage,'g')
    end
    xlabel('ticks')
    ylabel('age')
    title('ages over time')
    subplot(2,1,2)
    hold on
    if j > 500
        plot(history.meanscore(j-500:j),'b')
        plot(history.minscore(j-500:j),'r')
        plot(history.maxscore(j-500:j),'g')
    else
        plot(history.meanscore,'b')
        plot(history.minscore,'r')
        plot(history.maxscore,'g')
    end
    xlabel('ticks')
    ylabel('scores')
    title('scores over time')
    drawnow
    figure(1)
end

end