function[creatures,creaturetable,foods,familytree] = creaturecontrol(creaturetable,creatures,foods,familytree,mutatechange,minNcreatures)

%spawning creatures
for i = 1:length(creaturetable)
    if creaturetable(i) == 1
        creatures.alive(i) = creatures.alive(i) + 1;
        creatures.givenbirth(i) = creatures.givenbirth(i) - 1;
        creatures.timeafterfood(i) = creatures.timeafterfood(i) + 1;
        creatures.score(i) = creatures.alive(i)*2.5 + creatures.energy{i}*0.75 + creatures.amounteaten(i)*10 - creatures.timeafterfood(i)^1.2 - 0.01*creatures.notmoved(i);
        creatures.energy{i} = creatures.energy{i} - 0.5;
        creatures.notmoved(i) = creatures.notmoved(i) + 1;
        if creatures.energy{i} > 500, creatures.mate.willing(i) = creatures.mate.willing(i) + 0.15; end
        creatures.mate.willing(i) = creatures.mate.willing(i) + 0.0001*(creatures.alive(i)-1000);
        
        %creature giving birth
        if creatures.mate.distance(i) < 500 && creatures.mate.willing(i) > creatures.threshold(i) && creatures.mate.willing(creatures.mate.creature(i)) > creatures.threshold(creatures.mate.creature(i)) && creatures.givenbirth(i) < 0
            
            parentone = i;
            parenttwo = creatures.mate.creature(i);
            creatures.energy{parentone} = creatures.energy{parentone}/2;
            creatures.energy{parenttwo} = creatures.energy{parenttwo}/2;
            
            [creatures,creaturetable] = Childbirth(creatures,parentone,parenttwo,length(creaturetable)+1,mutatechange,creaturetable);
            
            creatures.mate.willing(parentone) = 0;
            creatures.mate.willing(parenttwo) = 0;
            creatures.givenbirth(parentone) = 100;
            creatures.givenbirth(parenttwo) = 100;
        end
        
        
        %creature dying
        if creatures.energy{i} <= 0 || creatures.score(i) <= 0
            creaturetable(i) = 0;
            familytree{creatures.generation(i),i}.parents = creatures.parents(i);
            familytree{creatures.generation(i),i}.pgenerations = creatures.pgenerations{i};
            familytree{creatures.generation(i),i}.age = creatures.alive(i);
            familytree{creatures.generation(i),i}.endscore = creatures.score(i);
        end
        
        %creatures eating
        if creatures.targets.distance{i} < 20
            creatures.energy{i} = creatures.energy{i} + 50;
            creatures.amounteaten(i) = creatures.amounteaten(i) + 1;
            creatures.timeafterfood(i) = 0;
            foods(foods(:,1)==creatures.targets.x(i))=0;
            foods(foods(:,2)==creatures.targets.y(i))=0;
        end
        
    elseif creaturetable(i) == 0 && sum(creaturetable==1) < minNcreatures
        % here everything happens when there is a place for a creature to
        % spawn
        creatures.networks{i} = CreateCreature;
        creatures.viewangle(i) = 30;
        creatures.viewdistance(i) = 300;
        creatures.generation(i) = 1;
        creatures.parents{i} = 0;
        creatures.pgenerations{i} = 0;
        creatures.locations.x(i) = randi(1000);
        creatures.locations.y(i) = randi(1000);
        creatures.angles(i) = randi(360);
        creatures.energy{i} = 50;
        creatures.alive(i) = 1;
        creatures.score(i) = 0;
        creatures.amounteaten(i) = 0;
        creaturetable(i) = 1;
        creatures.timeafterfood(i) = 0;
        creatures.threshold(i) = rand(1)*0.4+0.1;
        creatures.notmoved(i) = 0;
        creatures.givenbirth(i) = 50;
    end
end
end