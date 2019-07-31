function[score] = simulation(Sy,Vtotal,ballangle,plotsim,Sxend,Syend,i)
close all

maplength = Sxend+10;

%plotsim = 1
%defining ball stats
CoR = 0.9;
m = 5;
Vy = -sind(ballangle)*Vtotal;   %determening the new velocities
Vx = cosd(ballangle)*Vtotal;
Sx = 0;
%Vy = 0;


%end point to get
S_xend = Sxend;
S_yend = Syend;

% defining gravity
gravity = 9.8;
Grav_Force = -m*gravity;

% defining the function of the floor, for now only a straight floor in an
% angle
slope = -1;
startheight = 3;

%sos cas toa
floorangle = -atand(slope);
floornormal = floorangle - 90;
floor = @(x) slope*x+startheight; %funtion of the floor

%drawing the lines of the floor
if plotsim == 1
    hold on
    line([0 -startheight/slope],[startheight 0])
    line([-startheight/slope maplength],[0 0])
    line([maplength maplength],[0 Sy])
    plot(S_xend,S_yend,'og')
end
% defining starting forces
F_y = Grav_Force;
F_x = 0;

%defining time limits and time step
dt = 0.02;
start_time = 0;
end_time = 10;


simulate = 1;

time = start_time;
score = 10000;
while simulate == 1 && time < end_time    
    %calculating accelerations from previous force
    A_y = F_y/m;
    A_x = F_x/m;
    
    %deriving into velocities
    Vy = Vy + (A_y * dt);
    Vx = Vx + (A_x * dt);
    Vtotal = abs(sqrt(Vx^2 + Vy^2)); %total velocity
    ballangle = -atand(Vy/Vx); %angle of the ball
    
    
    if Vx < 0
        ballangle = ballangle + 180;
    end
    
    %check if the next step the ball will end up below the floor so a
    %rebound can happen
    %sos cas toa
    %pause
    if Sy + Vy*dt <= floor(Sx + Vx*dt) || Sy + Vy*dt <=0;
        ballangle = floornormal - ((ballangle - 180) - floornormal); %determines the new angle of the ball
        Vy = -sind(ballangle)*Vtotal*CoR;   %determening the new velocities
        Vx = cosd(ballangle)*Vtotal;
    end
    
    %check if the next step the ball reaches the end wall
    if Sx + Vx*dt >= maplength || Sx + Vx*dt <= 0
        Vx = -Vx*CoR;
    end
    
    Sy = Sy + (Vy * dt);
    Sx = Sx + (Vx * dt);
    %S_x = S_x +1;
    
    %drawing of ball
    if plotsim == 1
        hold on
        drawnow
        plot(Sx, Sy, '.r')
        %plot(S_x,floor(S_x),'.b')
        %xlabel({strcat('floorangle ',num2str(floorangle));
            %strcat('ballangle' ,num2str(ballangle));
            %strcat('V_x',num2str(Vx));
            %strcat('V_y',num2str(Vy));
            %strcat('V-total',num2str(Vtotal))
            %strcat('score',num2str(score))
            %strcat('i',num2str(i))})
    end
    %changing the floorangle and normalangle depending on the floor
    if floor(Sx + Vx * dt) <= 0
        floorangle = 0;
        floornormal = 90;
    elseif floor(Sx + Vx * dt) > 0
        floorangle = -atand(slope);
        floornormal = floorangle - 90;
    end
    
    %stopping the simulation if the ball somehow ends up below the floor
    if Sy < -0.02 || Sy < (floor(Sx)-0.02) || abs(Vtotal) < 0.1
        simulate=0;
    end
    
    %timestep
    time = time + dt;
    
    %determining score
    if sqrt((Sx - S_xend)^2 + (Sy - S_yend)^2)+time < score
        score = sqrt((Sx - S_xend)^2 + (Sy - S_yend)^2)+time;
    end
    
end
end