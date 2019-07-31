function[creatures,creaturetable] = Childbirth(creatures,parentone,parenttwo,childnumber,mutatechange,creaturetable)

if parentone<parenttwo
    parents = [parentone,parenttwo];
else
    parents = [parenttwo,parentone];
end
creatures.parents{childnumber} = parents;
%creatures.pgenerations{childnumber} = [creatures.generation(creatures.parents{parentone}(1)), creatures.generation(creatures.parents{parenttwo}(2))];

creatures.networks{childnumber} = CreateCreature;
creatures.score(childnumber) = 0;
creatures.alive(childnumber) = 0;

% copy input weight of parents
for j = 1:size(creatures.networks{childnumber}.IW{1},1)
    for k = 1:size(creatures.networks{childnumber}.IW{1},2)
        creatures.networks{childnumber}.IW{1}(j,k) = creatures.networks{parents(randi(2))}.IW{1}(j,k);
        mutationchange = randi(100);
        if mutationchange < mutatechange
            creatures.networks{childnumber}.IW{1}(j,k) = creatures.networks{childnumber}.IW{1}(j,k) + (rand-0.5)*0.01;
        end
    end
end

%copy first layer weights of parents
for j = 1:size(creatures.networks{childnumber}.LW{1},1)
    for k = 1:size(creatures.networks{childnumber}.LW{1},2)
        mutationchange = randi(100);
        creatures.networks{childnumber}.LW{1}(j,k) = creatures.networks{parents(randi(2))}.LW{1}(j,k);
        if mutationchange < mutatechange
            creatures.networks{childnumber}.LW{1}(j,k) = creatures.networks{childnumber}.LW{1}(j,k) + (rand-0.5)*0.1;
        end
    end
end

%copy second layer weights of parents
for j = 1:size(creatures.networks{childnumber}.LW{1},1)
    for k = 1:size(creatures.networks{childnumber}.LW{1},2)
        mutationchange = randi(100);
        creatures.networks{childnumber}.LW{2}(j,k) = creatures.networks{parents(randi(2))}.LW{2}(j,k);
        if mutationchange < mutatechange
            creatures.networks{childnumber}.LW{2}(j,k) = creatures.networks{childnumber}.WW{2}(j,k) + (rand-0.5)*0.1;
        end
    end
end

%copy bias weights of parents
for j = 1:size(creatures.networks{childnumber}.b{2},1)
    for k = 1:size(creatures.networks{childnumber}.b{2},2)
        mutationchange = randi(100);
        creatures.networks{childnumber}.b{2}(j,k) = creatures.networks{parents(randi(2))}.b{2}(j,k);
        if mutationchange < mutatechange
            creatures.networks{childnumber}.b{2}(j,k) = creatures.networks{childnumber}.b{2}(j,k) + (rand-0.5)*0.1;
        end
    end
end

%set location and angle of child
creatures.locations.x(childnumber) = (creatures.locations.x(parentone) + creatures.locations.x(parenttwo))/2;
creatures.locations.y(childnumber) = (creatures.locations.y(parenttwo) + creatures.locations.y(parenttwo))/2;
creatures.angles(length(creaturetable)+1) = randi(360);

%set viewing variables
creatures.viewangle(childnumber) = creatures.viewangle(parents(randi(2)));
creatures.viewdistance(childnumber) = creatures.viewdistance(parents(randi(2)));
mutationchange = randi(100);
if mutationchange < mutatechange*2
    creatures.viewangle(childnumber) = creatures.viewangle(childnumber)+ (rand-0.5)*10;
    creatures.viewdistance(childnumber) = creatures.viewdistance(childnumber) + (rand - 0.5)*100;
end

creatures.generation(childnumber) = max([creatures.generation(parentone) creatures.generation(parenttwo)])+1;
creatures.pgenerations(childnumber) = {[creatures.generation(parentone), creatures.generation(parenttwo)]};
creatures.energy{childnumber} = 50;
creatures.alive(childnumber) = 0;
creatures.score(childnumber) = 0;
creatures.amounteaten(childnumber) = 0;
creatures.timeafterfood(childnumber) = 0;
creatures.threshold(childnumber) = creatures.threshold(parentone) + creatures.threshold(parenttwo)/2;
creaturetable(childnumber) = 1;
creatures.notmoved(childnumber) = 0;
creatures.givenbirth(childnumber) = 50;

creatures.mate.willing(length(creaturetable)) = rand*0.4+0.1;
end

