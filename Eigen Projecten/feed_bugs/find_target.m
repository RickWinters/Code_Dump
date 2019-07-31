function[creatures] = find_target(creatures,creaturetable,maxNfoods,foods)

for j = 1:length(creaturetable)
    closest = 10000;
    creatures.targets.angle(j) = 0;
    creatures.targets.x(j) = nan;
    creatures.targets.y(j) = nan;
    creatures.targets.distance{j} = nan;
    creatures.targets.found(j) = -1;
    if creaturetable(j) == 1 && creatures.targets.found(j) == -1;
        %deciding the left and right most angle the cerature can see
        leftangle = creatures.angles(j) + creatures.viewangle(j)/2;
        if leftangle > 360, leftangle = leftangle - 360; end
        rightangle = creatures.angles(j) - creatures.viewangle(j)/2;
        if rightangle < 0, rightangle = rightangle + 360; end
        
        for i = 1:maxNfoods
            if foods(i,1) ~= 0
                dy = foods(i,2) - creatures.locations.y(j);
                dx = foods(i,1) - creatures.locations.x(j);
                
                targetangle = atand(dy/dx);
                if  dx > 0 && dy < 0
                    targetangle = 360 + targetangle;
                elseif dx < 0
                    targetangle = 180 + targetangle;
                end
                
                
                if rightangle > leftangle
                    if (targetangle < leftangle && targetangle > 0) || (targetangle > rightangle && targetangle < 360)
                        distance = sqrt((creatures.locations.x(j)-foods(i,1))^2 + (creatures.locations.y(j)-foods(i,2))^2);
                        if (distance < closest) && distance < (creatures.viewdistance(j))
                            closest = distance;
                            creatures.targets.x(j) = foods(i,1);
                            creatures.targets.y(j) = foods(i,2);
                            creatures.targets.angle(j) = targetangle;
                            creatures.targets.distance{j} = distance;
                            creatures.targets.found(j) = 1;
                        end
                    end   
                else
                    if targetangle < leftangle && targetangle > rightangle
                        distance = sqrt((creatures.locations.x(j)-foods(i,1))^2 + (creatures.locations.y(j)-foods(i,2))^2);
                        if (distance < closest) && (distance < creatures.viewdistance(j))
                            closest = distance;
                            creatures.targets.x(j) = foods(i,1);
                            creatures.targets.y(j) = foods(i,2);
                            creatures.targets.angle(j) = targetangle;
                            creatures.targets.distance{j} = distance;
                        end
                    end
                end
            end
        end
    end
end
%end


