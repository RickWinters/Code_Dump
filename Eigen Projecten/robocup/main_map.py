import pygame
import sys
import numpy
import math
import time
import random
import Controller1
import controllerleft
import test_opponent

#MAIN script for self made robocup simulation. Main idea is that a controlcode scans the field and assigns requests the bots to go to a position,rotation,and action.
# the classes in this script will than have the bots go to this configuration. The controller script must have a function called "update"
# A centralised physics engine still has to be implemented in where each object gets updated

class Ball():
    #class Ball
    #   includes the properties of the ball such as position velocity force mass etc
    #   function update changes the position depending on the mass and FPS of the program.
    #   function draw draws the ball
    #   function getdistance can be called from within another object to get the distance of the ball to that object.
    #       input "position" is the position of the other object
    def __init__(self, width, height):
        self.object = "ball" #this is for the physics engine, as the physics engine will see every object as "object" it is necessary to have an object specification
        self.xx = int(width/2)
        self.yy = int(height/2)
        self.radius = 10
        self.mass = 10
        self.fx = 0
        self.fy = 0
        self.ax = 0
        self.ay = 0
        self.vx = 0
        self.vy = 0
        self.Rr = 0.005
        self.Rx = 0
        self.Ry = 0
        self.bouncefactor = 1
        self.hit = False

    def update(self,time,height,width):
        self.ax = self.fx / self.mass
        self.ay = self.fy / self.mass
        self.vx = self.vx*(0.5**abs(time))
        self.vy = self.vy*(0.5**abs(time))
        self.vx += self.ax * time
        self.vy += self.ay * time
        self.position = [self.position[0] + self.vx, self.position[1] + self.vy]
        self.fx = 0
        self.fy = 0

        if (self.position[0] > width - self.radius) or (self.position[0] < self.radius):
            self.vx = -self.vx
        if (self.position[1] > height - self.radius) or (self.position[1] < self.radius):
            self.vy = -self.vy

    def draw(self, screen):
        pygame.draw.circle(screen, (0,255,255), (int(self.xx), int(self.yy)), self.radius, 2)

    def getdistance(self,position):
        difx = self.xx - position[0]
        dify = self.yy - position[1]
        length = math.sqrt(difx**2 + dify**2)
        dirx = difx/length
        diry = dify/length
        return length, dirx, diry

class Bot():
    #Stores the properties of a bot. This class is called from the Team class
    #   function move updates the position of the bot by finding the direction between the requested position and the
    #    curent position. Requested position comes from the controller assigned to the team, the Controller is the basic AI for the whole team
    #    - should be updated to change the movespeed from the requested move speed. Property requested move speed still needs to be implemented.
    #   Function Rotate rotates the bot towards the requested direction.
    def __init__(self):
        self.object = "bot"
        self.role = 1 #can be used by controller to decide which role the bot has. This for example could be a keeper role for which a different script gets executed.
        self.hasBall = False
        self.requestPosition = (0,0)
        self.pidposition = (0,0)
        self.requestAction = (0,0)
        self.facing = 0
        self.requestfacing = 0
        self.movespeed = 1
        self.requestmovespeed = 1
        self.rotatespeed = 1
        self.radius = 20
        self.acceleration = 0.1
        self.fx = 0
        self.fy = 0
        self.ax = 0
        self.ay = 0
        self.vx = 0
        self.vy = 0
        self.xx = 0
        self.yy = 0
        self.Rx = 0
        self.Ry = 0
        self.Rr = 2.5
        self.mass = 10
        self.kP = 1
        self.kI = 0
        self.kD = 1
        self.kickforce = 0

        self.interrorx = 0
        self.interrory = 0
        self.diferrorx = 0
        self.preferrorx = 0
        self.diferrory = 0
        self.preferrory = 0
        self.errorx = 0
        self.errory = 0
        self.moveforce = 500
        self.bouncefactor = 0

    def move(self,dt):
        self.errorx = numpy.float32(self.requestPosition[0] - self.xx)
        self.errory = numpy.float32(self.requestPosition[1] - self.yy)
        self.interrorx += self.errorx
        self.interrory += self.errory
        self.diferrorx = (self.errorx - self.preferrorx)
        self.diferrory = (self.errory - self.preferrory)

        difx = self.errorx*self.kP + self.kI*self.interrorx + self.kD*self.diferrorx
        dify = self.errory*self.kP + self.kI*self.interrory + self.kD*self.diferrory
        self.pidposition = (difx,dify)

        dist = math.sqrt(difx**2 + dify**2)

        if dist > 0:
            dirx = difx / abs(dist)
            diry = dify / abs(dist)
        else:
            dirx = 0
            diry = 0

        self.fx = (self.moveforce * dirx)
        self.fy = (self.moveforce * diry)

        self.preferrorx = self.errorx
        self.preferrory = self.errory

    def rotate(self):
        if self.requestfacing > self.facing:
            self.facing += 0.01*numpy.pi
        else:
            self.facing -= 0.01*numpy.pi

class Team():
    # the Team class is pretty much an envelope for the bots in the team, the class is initialized by assinging a number
    # of bots to the team and assinging a controller code. Next to that the bots get assigned a starting position
    #   - idea? Have the starting position assigned by the controller?
    #   function Draw_team loops over the bots and updates the position and rotation, than draws the bots.
    def __init__(self, number, width, height, controller):
        self.bots = [] #array of bots
        self.score = 0 #team score -scoring mechanism still needs to be implemented
        self.number = number #number of the team
        if self.number == 1:
            self.side = 1 #left
            self.color = (255, 0, 0)
        else:
            self.side = 2 #right
            self.color = (0, 0, 255)

        for i in range(3): #append five bots
            self.bots.append(Bot())
        self.controller = controller(self,width,height)

    def draw_team(self,screen,dt,myfont,width):
        for i in range(len(self.bots)):
            self.bots[i].move(dt)
            self.bots[i].rotate()
            scoretext = myfont.render(str(self.score),False,(255,255,255))
            if self.side == 1:
                screen.blit(scoretext,(width/2-50,10))
            else:
                screen.blit(scoretext,(width/2+50,10))
            relpos = (int(numpy.sin(self.bots[i].facing)*20), int(numpy.cos(self.bots[i].facing)*20))
            pygame.draw.circle(screen, self.color, (int(self.bots[i].xx), int(self.bots[i].yy)), self.bots[i].radius, 2)
            pygame.draw.lines(screen, self.color, False, [(self.bots[i].xx, self.bots[i].yy), (self.bots[i].xx+relpos[0], self.bots[i].yy+relpos[1])])

def draw_field(screen, width, height, goal_width,    blue  = (100, 100, 255),    green = (0,   255, 0  ),    white = (255, 255, 255),    black = (0,   0,   0  ),    pink  = (255, 200, 200)):
    #function that draws the field
    #goal_width = 60
    keeper_distance= 100
    centre_circle_radius = 20
    centre_width = round(width/2)
    centre_height = round(height/2)

    screen.fill(black)
    #center circle
    pygame.draw.circle(screen, white, (centre_width,centre_height), centre_circle_radius, 2)

    #keeper field
    pygame.draw.lines(screen, white, True, [(0, centre_height+keeper_distance), (keeper_distance, centre_height+keeper_distance), (keeper_distance, centre_height-keeper_distance), (0, centre_height-keeper_distance)])
    pygame.draw.lines(screen, white, True, [(width, centre_height+keeper_distance), (width-keeper_distance, centre_height+keeper_distance), (width-keeper_distance, centre_height-keeper_distance), (width, centre_height-keeper_distance)])

    #goals
    pygame.draw.lines(screen, blue, False, [(0,centre_height-goal_width/2), (0,centre_height+goal_width/2)], 8)
    pygame.draw.lines(screen, blue, False, [(width-2, centre_height-goal_width/2),(width-2,centre_height+goal_width/2)], 8)

    #vertical line centre
    pygame.draw.lines(screen, white, False, [(centre_width, 0),(centre_width, height)])

    #around the screen
    pygame.draw.lines(screen, white, True, [(0,0), (width-2,0), (width-2,height-2), (0,height-2)], 3)

def updatephysics(teams,ball,width,height,dt,screen,goalwidth,cornertime):
    objects = []
    for team in teams:
        for bot in team.bots:
            objects.append(bot)
    objects.append(ball)
    for object in objects:
        relftotx = object.xx + object.fx*10
        relftoty = object.yy + object.fy*10
        object.fy += object.Ry
        object.fx += object.Rx
        object.ax = object.fx / object.mass
        object.ay = object.fy / object.mass
        object.vx += object.ax
        object.vy += object.ay
        object.Rx = -object.Rr * object.vx
        object.Ry = -object.Rr * object.vy
        object.xx += object.vx * dt
        object.yy += object.vy * dt
        if object.xx > width-object.radius:
            object.xx = width - object.radius
            object.vx = -object.vx*object.bouncefactor
        if object.xx < object.radius:
            object.xx = object.radius
            object.vx = -object.vx*object.bouncefactor
        if object.yy > height-object.radius:
            object.yy = height-object.radius
            object.vy = -object.vy*object.bouncefactor
        if object.yy < object.radius:
            object.yy = object.radius
            object.vy = -object.vy*object.bouncefactor


        objectdebug = 0
        if objectdebug == 1:
            relrx = object.xx + object.Rx*10
            relry = object.yy + object.Ry*10
            relfx = object.xx + object.fx*10
            relfy = object.yy + object.fy*10
            pygame.draw.lines(screen,(255,0,0),False,[(object.xx,object.yy),(relrx,relry)])
            pygame.draw.lines(screen,(0,255,0),False,[(object.xx,object.yy),(relfx,relfy)])
            pygame.draw.lines(screen,(0,125,0),False,[(object.xx,object.yy),(relftotx,relftoty)])
            if object.object == "bot":
                pygame.draw.lines(screen,(0,0,255),False,[(object.xx,object.yy),(object.pidposition[0]+object.xx,object.pidposition[1]+object.yy)])
                pygame.draw.lines(screen,(0,0,125),False,[(object.xx,object.yy),object.requestPosition])

        if object.object == "bot":
            dist,dirx,diry = ball.getdistance((object.xx,object.yy))
            if dist <= object.radius + ball.radius:
                print("bot hit ball: kickforce = : " + str(object.kickforce) + " dirx: " + str(dirx) + " diry: " + str(diry))
                ball.fx += dirx*object.kickforce
                ball.fy += diry*object.kickforce
                ball.hit = True
                difdist = (ball.radius + object.radius) - dist
                ball.xx += dirx * difdist
                ball.yy += diry * difdist

        if object.object == "ball":
            object.fx = 0
            object.fy = 0
            object.hit = False
            if abs(height/2 - object.yy) < goalwidth/2:
                if object.xx == object.radius:
                    print("ball in left goal")
                    teams[1].score += 1
                    object.xx = width/2
                    object.yy = height/2
                elif object.xx == width-object.radius:
                    teams[0].score += 1
                    print("ball in right goal")
                    object.xx = width/2
                    object.yy = height/2

        for object2 in objects:
            if object2.object == "bot" and object.object == "bot":
                dist = math.sqrt((object2.xx - object.xx)**2 + (object2.yy - object.yy)**2)
                if dist <= object2.radius + object.radius and dist > 0:
                    print("Collision detected between :" + str(object2.object) + " and " + str(object.object))
                    difx = object2.xx - object.xx
                    dify = object2.yy - object.yy
                    dirx = difx/dist
                    diry = dify/dist
                    difdist = (object2.radius + object.radius)-dist
                    object.xx -= dirx*difdist
                    object.yy -= diry*difdist

    if (ball.xx < ball.radius*3 or  ball.xx > width - ball.radius*3) and (ball.yy < ball.radius*3 or ball.yy > height - ball.radius*3):
        cornertime += dt
    else:
        cornertime = 0

    if cornertime > 10:
        ball.xx = width /2
        ball.yy = height /2
        ball.vx = 0
        ball.vy = 0
        ball.ax = 0
        ball.ay = 0
        ball.fx = 0
        ball.fy = 0

    return cornertime


def main():
    #main loop.
    t1 = time.time() #start an FPS timer
    red   = (255, 0,   0  )
    blue  = (100, 100, 255)
    green = (0,   255, 0  )
    white = (255, 255, 255)
    black = (0,   0,   0  )
    pink  = (255, 200, 200)

    screen_width = 1280
    screen_height = 800
    goalwidth = 120

    screen = pygame.display.set_mode((screen_width, screen_height))

    running = True

    pygame.init()
    pygame.font.init()
    myfont = pygame.font.SysFont('Times New Roman',30)
    clock = pygame.time.Clock()

    team1 = Team(1, screen_width, screen_height, Controller1.controller)
    team2 = Team(2, screen_width, screen_height, controllerleft.controller)
    ball = Ball(screen_width, screen_height)
    loop = 1
    dt = time.time() - t1
    cornertime = 0
    while running:
        t1 = time.time()

        clock.tick(1000)

        draw_field(screen, screen_width, screen_height, goalwidth)

        team1.controller.update(ball,screen_height,screen_width)
        team2.controller.update(ball,screen_height,screen_width)
        cornertime = updatephysics([team1,team2],ball,screen_width,screen_height,dt,screen,goalwidth,cornertime)
        #ball.update(dt,screen_height,screen_width)
        team1.draw_team(screen,dt,myfont,screen_width)
        team2.draw_team(screen,dt,myfont,screen_width)
        ball.draw(screen)

        fpstext = myfont.render("FPS = " + str(round(1/dt)),False,(255,255,255))
        screen.blit(fpstext,(10,10))
        cornertimetext = myfont.render("cornertime = " + str(round(cornertime,1)),False,(255,255,255))
        screen.blit(cornertimetext,(10,30))

        pygame.display.update()

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit(); sys.exit()

        #print("FPS = "  + str(round(1/dt)))
        loop += 1
        dt = (time.time() - t1)

main()











