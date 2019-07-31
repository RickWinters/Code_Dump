function[score] = minigolf(Vtotal,angle,level,plotsim)

%level = 3;

% Vtotal = 40; %set total starting velocity,
% angle = -30;

% determinging the coefficients of velocity
Vy = -sind(angle)*Vtotal;
Vx = cosd(angle)*Vtotal;

%set golf coursse
[start, hole, points] = eval(strcat('Level',num2str(level)));
[linesx,linesy] = getlines(points);

%determine other variables
A_x = start(1);
A_y = start(2);
X_end = hole(1);
Y_end = hole(2);

dt = 0.01;

golf = 1;
score = 10000;
while golf == 1;
    A_x = A_x + Vx*dt;
    A_y = A_y + Vy*dt;
    
    dist = sqrt((A_x - X_end)^2 + (A_y - Y_end)^2);
    %sos cas toa
    Vtotal = Vtotal * 0.99;
    Vy = -sind(angle)*Vtotal;
    Vx = cosd(angle)*Vtotal;
    
    if Vtotal < 0.5 || dist < 0.1
        Vtotal = 0;
        golf = 0;
    end
    
    
    for n = 1:size(linesx,1)
        if (linesx(n,1)<A_x && A_x < linesx(n,2))
            if ( A_y < linesx(n,3) && A_y + Vy*dt > linesx(n,3)) || ( A_y > linesx(n,3) && A_y + Vy*dt < linesx(n,3))
                Vy = -Vy;
            end
        end
    end
    
    for n = 1:size(linesy,1)
        if (linesy(n,1)<A_y && A_y < linesy(n,2))
            if ( A_x < linesy(n,3) && A_x + Vx*dt > linesy(n,3)) || ( A_x > linesy(n,3) && A_x + Vx*dt < linesy(n,3))
                Vx = -Vx;
            end
        end
    end
    
    if A_x + Vx*dt < 0
        Vx = -Vx;
    elseif A_y + Vy*dt < 0
        Vy = -Vy;
    end
    
    
    
    angle = -atand(Vy/Vx);
    if Vx < 0
        angle = angle + 180;
    end
    
    
    Vtotal = sqrt(Vx^2 + Vy^2);
    %pause
    
    if plotsim == 1
    drawnow
    plot(A_x,A_y,'.r')
    xlabel({strcat('Vtotal = ',num2str(Vtotal));
        strcat('Vx = ',num2str(Vx));
        strcat('Vy = ',num2str(Vy));
        strcat('angle=',num2str(angle))})
    end
    
    if dist < 0.1
        dist = 0;
    end
    if dist < score
        score = dist;
    end
end


