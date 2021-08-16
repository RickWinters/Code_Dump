import random
import math
import numpy

class controller():
    #roles: keeper == 1, disruptor = 2, attack = 3, defender = 4, support = 5
    def __init__(self,team,width,height):
        self.team = team
        self.side = team.side
        self.attackerneargoal = False
        for i in range(len(self.team.bots)):
            self.team.bots[i].role = 5
            self.team.bots[i].kickforce = 500
        #self.team.bots[random.randint(0,2)].role = 1

        bot = self.team.bots[0]
        bot.role = 3
        bot.xx = bot.radius
        bot.yy = height/2

        bot = self.team.bots[1]
        bot.role = 3
        bot.xx = width/2 - bot.radius*2
        bot.yy = height/2 - bot.radius/2
        bot.kickforce = 5000

        bot = self.team.bots[2]
        bot.role = 3
        bot.xx = width/4
        bot.yy = height/2
        bot.kickforce = 1000

    def updatekeeper(self,ball,height,width,bot):
        dist,dirx,diry = ball.getdistance((0,height/2))
        x = dirx*bot.radius*2
        y = diry*bot.radius*2+height/2
        if abs(ball.vx) > 0:
            oncoming_y = ball.yy-(ball.xx-bot.xx)/ball.vx*ball.vy
        if ball.vx < 0 and abs(height/2-oncoming_y) < 120:
            y = oncoming_y
        bot.requestPosition = (x,y)

    def updatedisruptor(self,bot,ball,width,height):

        balldifx = ball.xx - bot.xx
        balldify = ball.yy - bot.yy
        length = math.sqrt(balldifx**2 + balldify**2)
        balldirx = balldifx / length
        balldiry = balldify / length

        bot.hasBall = False
        x = ball.xx
        y = ball.yy
        if x > width-bot.radius:
            x = width-bot.radius
        if x < bot.radius:
            x = bot.radius
        if y > height-bot.radius:
            y = height-bot.radius
        if y < bot.radius:
            y = bot.radius
        bot.requestPosition = (x,y)

    def updateattack(self,bot,ball,width,height):
        if bot.xx < bot.radius*20:
            self.attackerneargoal = True
        else:
            self.attackerneargoal = False
        goal_ball_difx = ball.xx - width
        ball_bot_difx = bot.xx - ball.xx
        goal_ball_dify = height/2 - ball.yy
        ball_bot_dify = ball.yy - bot.yy
        dist = math.sqrt(goal_ball_difx**2 + goal_ball_dify**2)
        goal_ball_dirx = goal_ball_difx/dist
        goal_ball_diry = goal_ball_dify/dist
        x = ball.xx + goal_ball_dirx*bot.radius*10 #x position of aiming ball to goal
        y = ball.yy - goal_ball_diry * bot.radius * 10 # y positon of amiing ball to goal

        #adjust y to go around the ball, to not hit it in home direction
        if ball.xx < bot.xx:
            if y > bot.yy:
                y -= bot.radius*2.5
            else:
                y += bot.radius*2.5

        #adjust x and y to get much closer to the ball
        if x < bot.xx and ball.xx-goal_ball_dirx*(ball.radius+bot.radius) > bot.xx:
            x = ball.xx+goal_ball_dirx*(ball.radius+bot.radius)*1
            y = ball.yy-goal_ball_diry*(ball.radius+bot.radius)*1

        if x < 0:
            x = bot.radius
        if x > width:
            x = width - bot.radius
        if y < 0:
            y = bot.radius
        if y > height:
            y = height - bot.radius

        ballangle = math.atan2(goal_ball_dify,goal_ball_difx)
        botangle = math.atan2(ball_bot_dify,ball_bot_difx)
        if (abs(botangle-ballangle) < 0.025*numpy.pi and bot.xx < ball.xx) or (bot.yy == bot.radius or bot.yy == height-bot.radius):
            bot.requestPosition = (ball.xx, ball.yy)
        else:
            bot.requestPosition = (x,y)

    def updatedefender(self,bot,ball,width,height):
        bot.kickforce = 2500
        goal_ball_difx = ball.xx
        goal_ball_dify = height/2 - ball.yy
        dist = math.sqrt(goal_ball_difx**2 + goal_ball_dify**2)
        goal_ball_dirx = goal_ball_difx / dist
        goal_ball_diry = goal_ball_dify / dist
        if dist < bot.radius*20 and bot.xx < ball.xx and not self.attackerneargoal:
            bot.requestPosition = (ball.xx, ball.yy)
            bot.kickforce = 5000
        elif dist < bot.radius*20 and bot.xx > ball.xx:
            bot.requestPosition = (goal_ball_dirx * dist/2, height/2 - goal_ball_diry*dist/2)
        else:
            bot.requestPosition = (goal_ball_dirx * bot.radius*10, height/2 - goal_ball_diry * bot.radius*10)



    def update(self,ball,height,width):
        for i in range(len(self.team.bots)):
            bot = self.team.bots[i]
            bot.requestfacing = math.atan2(ball.xx-bot.xx, ball.yy-bot.yy)
            if bot.requestfacing < 0:
                bot.requestfacing += 2*numpy.pi
            elif bot.requestfacing > 2*numpy.pi:
                bot.requestfacing -= 2*numpy.pi
            if bot.role == 1:
                self.updatekeeper(ball,height,width,bot)
            if bot.role == 2:
                self.updatedisruptor(bot,ball,width,height)
            if bot.role == 3:
                self.updateattack(bot,ball,width,height)
            if bot.role == 4:
                self.updatedefender(bot,ball,width,height)

    def get_ball_y_at_x(self,ball,x):
        difx = x - ball.xx
        y = ball.yy + ball.vy*(x-ball.xx)
