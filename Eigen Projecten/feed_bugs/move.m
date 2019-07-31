function[creatures] = move(creatures,actions)

for i = 1:length(creatures.alive)
    if actions(1,i) > creatures.threshold(i) && actions(1,i) > actions(2,i)
        creatures.energy{i} = creatures.energy{i} - 1;
        creatures.angles(i) = creatures.angles(i)+10;
        if creatures.angles(i) > 360
            creatures.angles(i) = creatures.angles(i) - 360;
        end
    end
    if actions(2,i) > creatures.threshold(i) && actions(2,i) > actions(1,i)
        creatures.energy{i} = creatures.energy{i} - 1;
        creatures.angles(i) = creatures.angles(i)-10;
        if creatures.angles(i) < 0
            creatures.angles(i) = creatures.angles(i) + 360;
        end
    end
    if actions(3,i) > creatures.threshold(i)
        creatures.notmoved(i) = 0;
        creatures.energy{i} = creatures.energy{i} - 0.5;
        creatures.locations.x(i) = creatures.locations.x(i)+(cosd(creatures.angles(i))*10);
        if creatures.locations.x(i) > 1000
            creatures.locations.x(i) = 1000;
        end
        if creatures.locations.x(i) < 0
            creatures.locations.x(i) = 0;
        end
        creatures.locations.y(i) = creatures.locations.y(i)+(sind(creatures.angles(i))*10);
        if creatures.locations.y(i) > 1000
            creatures.locations.y(i) = 1000;
        end
        if creatures.locations.y(i) < 0
            creatures.locations.y(i) = 0;
        end
    end
end
end