clc, close all
tic
% spawning first foods
maxNfoods = 60;
Ntospawn = 100;
foods = zeros(maxNfoods,2);
foods = spawn_food(maxNfoods,Ntospawn,foods);

mutatechange = 30;
minNcreatures = 10;
creaturetable = zeros(1,minNcreatures);
aliveticksneeded = 200;
meantime = 1;
history = [];

time = 0;
ticktime = 0;

Ntospawn = 3;
j = 1;
%creatures = creatures1;
familytree = {};
%familytree = familytree1;
play = true;
while play
    %spawn new foods
    foods = spawn_food(maxNfoods,Ntospawn,foods);
    
    %find mates
    if j > 1; creatures = find_mate(creatures,creaturetable); end
    
    
    %control the creatures, i.e. eat, die, keep up with varieables
    if j == 1, [creatures, creaturetable] = creaturecontrol(creaturetable,[],[],[],[],minNcreatures);
    elseif j > 1 , [creatures, creaturetable, foods, familytree] = creaturecontrol(creaturetable,creatures, foods, familytree, mutatechange, minNcreatures); end
    
    %find targets
    creatures = find_target(creatures,creaturetable,maxNfoods,foods);
    
    %do move actions
    for i = 1:length(creaturetable)
        angledif = creatures.angles(i) - creatures.targets.angle(i);
        if isnan(angledif), angledif = 180; end
        if angledif < -180, angledif = angledif + 360; end
        actions(:,i) = creatures.networks{i}([angledif;creatures.targets.found(i)]);
        creatures.mate.willing(i) = actions(4,i);
    end
    creatures = move(creatures,actions);
    
    %update the drawing
    if mod(j,1) == 0 && (sum(creaturetable == 1) > minNcreatures || max(creatures.alive) > aliveticksneeded); updatedrawing(minNcreatures,creatures,foods,j,creaturetable,angledif,ticktime,time); end
    %if mod(j,1) == 0 ; updatedrawing(minNcreatures,creatures,foods,j,creaturetable,angledif,ticktime,time); end

    %keep trackt of commanding variables
    if min(creatures.alive) >= aliveticksneeded, play = false; end
    j = j + 1;
    
    %cleanup dead creatures
    if mod(j,50) == 0 && length(creaturetable) > minNcreatures
        cleanup = find(creaturetable == 0);
        creaturetable(cleanup) = [];
        creatures.networks(cleanup) = [];
        creatures.viewangle(cleanup) = [];
        creatures.viewdistance(cleanup) = [];
        creatures.generation(cleanup) = [];
        creatures.parents(cleanup) = [];
        creatures.pgenerations(cleanup) = [];
        creatures.locations.x(cleanup) = [];
        creatures.locations.y(cleanup) = [];
        creatures.angles(cleanup) = [];
        creatures.energy(cleanup) = [];
        creatures.alive(cleanup) = [];
        creatures.score(cleanup) = [];
        creatures.amounteaten(cleanup) = [];
        creatures.timeafterfood(cleanup) = [];
        creatures.threshold(cleanup) = [];
        creatures.targets.angle(cleanup) = [];
        creatures.targets.x(cleanup) = [];
        creatures.targets.y(cleanup) = [];
        creatures.targets.distance(cleanup) = [];
        creatures.targets.found(cleanup) = [];
        creatures.mate.willing(cleanup) = [];
        creatures.mate.creature(cleanup) = [];
        creatures.mate.distance(cleanup) = [];
    end
    
    %output variables in command window
    following = find(creatures.score == max(creatures.score));
    if mod(j,50) == 0
        time = toc;
        ticktime = j;
    end
    if mod(j,1) == 0
        clc
        strcat({'tick = ',num2str(j)
            'time = ',strcat(num2str(floor(toc/60)),' min  ',num2str(floor(mod(toc,60))),' sec')
            'ticks\s = ',num2str((j - ticktime)/(toc - time));
            'max score = ',num2str(creatures.score(following));
            'alive = ',num2str(creatures.alive(following));
            'shortens alive = ',num2str(min(creatures.alive))
            'number of creatures = ',strcat(num2str(sum(creaturetable==1)),'/',num2str(length(creaturetable)))
            'mating = ',num2str(creatures.mate.willing(following))})
        
    end
    
    history = plothistory(creatures,j,history);
    
end

%put the still living creatures in the familytree
for i = 1:minNcreatures
    familytree{creatures.generation(i),i}.parents = creatures.parents(i);
    familytree{creatures.generation(i),i}.pgenerations = creatures.pgenerations{i};
    familytree{creatures.generation(i),i}.age = creatures.alive(i);
    familytree{creatures.generation(i),i}.endscore = creatures.score(i);
end

% %draw the familytree
figure
for i = 1:minNcreatures
    for j = 2:size(familytree,1)
        if isempty(familytree{j,i}) == 0
            line([i,familytree{j,i}.parents{1}(1)],[j,familytree{j,i}.pgenerations(1)])
            line([i,familytree{j,i}.parents{1}(2)],[j,familytree{j,i}.pgenerations(2)])
            drawnow
        end
    end
end
            