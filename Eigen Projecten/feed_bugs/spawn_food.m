function[foods,nfoods] = spawn_food(maxNfoods,Ntospawn,foods)

nfoods = 0;

for j = 1:Ntospawn
    spawnchange = randi(100);
    if spawnchange < 50
        spawn = randi(maxNfoods);
        if foods(spawn,1) == 0;
            foodx = round(rand*1000);
            foods(spawn,1) = foodx;
            foody = round(rand*1000);
            foods(spawn,2) = foody;
        end
        %drawnow
        
    end
end
