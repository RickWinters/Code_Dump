function[] = updatedrawing(minNcreatures,creatures,foods,j,creaturetable,angledif,ticktime,time)
figure(1)
clf %clear figure

%create edges
fieldsize = 1000;
plot([-200 -200 1200 1200],[-200 1200 1200 -200],'.')
line([0 0; 0 fieldsize; fieldsize fieldsize; fieldsize 0] ,[0 fieldsize; fieldsize fieldsize; fieldsize 0; 0 0])

hold on

%plot all the locations of food
plot(foods(:,1),foods(:,2),'.')

%plot all the creatures locations, lines toward target, and lines in which
%direction they are
following = find(creatures.alive == max(creatures.alive));
following = following(1);
alive = find(creaturetable == 1);
plot(creatures.locations.x(alive), creatures.locations.y(alive), 'or');
plot(creatures.locations.x(following), creatures.locations.y(following), 'og');
%line([creatures.locations.x(foundtarget) creatures.targets.x(foundtarget)],[creatures.locations.y(foundtarget) creatures.targets.y(foundtarget)]);


for i = 1:length(creaturetable)
    if creaturetable(i) == 1
        %         plot(creatures.locations.x{i}, creatures.locations.y{i}, 'or')
        %         if i == following
        %             plot(creatures.locations.x{i}, creatures.locations.y{i}, 'og')
        %         end
        if isnan(creatures.targets.x(i)) == 0
            line([creatures.locations.x(i) creatures.targets.x(i)],[creatures.locations.y(i) creatures.targets.y(i)])
        end
        line([creatures.locations.x(i) creatures.locations.x(i)+cosd((creatures.angles(i)) + creatures.viewangle(i)/2)*30],[creatures.locations.y(i) creatures.locations.y(i)+sind((creatures.angles(i)) + creatures.viewangle(i)/2)*30],'color',[1,0,0]);
        line([creatures.locations.x(i) creatures.locations.x(i)+cosd((creatures.angles(i)) - creatures.viewangle(i)/2)*30],[creatures.locations.y(i) creatures.locations.y(i)+sind((creatures.angles(i)) - creatures.viewangle(i)/2)*30],'color',[1,0,0]);
        if i == following
            line([creatures.locations.x(i) creatures.locations.x(i)+cosd(creatures.angles(i))*30],[creatures.locations.y(i) creatures.locations.y(i)+sind(creatures.angles(i))*30],'color',[0,1,0]);
        end
    end
    if j > 1, xlabel({strcat('tick=',num2str(j))
            strcat('time',strcat(num2str(floor(toc/60)),' min  ',num2str(floor(mod(toc,60))),' sec'))
            strcat('ticks\s = ',num2str((j - ticktime)/(toc - time)))
            strcat('max score = ',num2str(creatures.score(following)))
            strcat('energy = ',num2str(creatures.energy{following}))
            strcat('alive = ',num2str(creatures.alive(following)))
            strcat('angle dif = ',num2str(angledif))
            strcat('mating = ',num2str(creatures.mate.willing(following)))});
    end
end

drawnow
end