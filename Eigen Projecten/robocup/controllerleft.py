import random
import math
import numpy

class controller():
    #roles: keeper == 1, disruptor = 2, attack = 3, defender = 4, support = 5
    def __init__(self,team,width,height):
        self.team = team
        self.side = team.side
        for i in range(len(self.team.bots)):
            self.team.bots[i].role = 5
            self.team.bots[i].kickforce = 500
        #self.team.bots[random.randint(0,2)].role = 1
        bot = self.team.bots[0]
        bot.role = 1
        bot.xx = width - bot.radius
        bot.yy = height / 2

        bot = self.team.bots[1]
        bot.role = 3
        bot.xx = width / 2 + bot.radius * 2
        bot.yy = height / 2 + bot.radius / 2
        bot.kickforce = 5000

        bot = self.team.bots[2]
        bot.role = 4
        bot.xx = width / 4 * 3
        bot.yy = height / 2
        bot.kickforce = 2500

    def updatekeeper(self,ball,height,width,bot):
        if self.side == 1:
            x = int(ball.xx / 10)
            if x < bot.radius:
                x = bot.radius
        else:
            x = int(width - (width-ball.xx)/10)
            if x > width - bot.radius:
                x = width - bot.radius
        y = int((ball.yy - height / 2) / 10) + height / 2
        bot.requestPosition = (x, y)
        dist = math.sqrt(x**2 + y**2)
        if dist > 100* bot.movespeed:
            bot.movespeed += 0.1
        if dist < 10* bot.movespeed:
            bot.movespeed -= 0.1

        dist, dirx, diry = ball.getdistance((bot.xx, bot.yy))
        if dist < ball.radius + bot.radius:
            ball.vx = 0
            ball.vy = 0
            ball.fx = dirx*100
            ball.fy = diry*100

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
        if self.side == 1:
            goal_ball_difx = ball.xx - width
            goal_bot_difx = bot.xx - width
        else:
            goal_ball_difx = ball.xx
            goal_bot_difx = bot.xx
        goal_ball_dify = height/2 - ball.yy
        goal_bot_dify = height/2 - bot.yy
        dist = math.sqrt(goal_ball_difx**2 + goal_ball_dify**2)
        goal_ball_dirx = goal_ball_difx/dist
        goal_ball_diry = goal_ball_dify/dist
        x = ball.xx + goal_ball_dirx*bot.radius*10
        y = ball.yy - goal_ball_diry*bot.radius*10

        ballangle = math.atan2(goal_ball_dify,goal_ball_difx)
        botangle = math.atan2(goal_bot_dify,goal_bot_difx)

        if abs(botangle-ballangle) < 0.02*numpy.pi and bot.xx > ball.xx:
            bot.requestPosition = (ball.xx, ball.yy)
        else:
            bot.requestPosition = (x,y)

    def updatedefender(self,bot,ball,width,height):
        if self.side == 1:
            goal_ball_difx = ball.xx
        else:
            goal_ball_difx = ball.xx - width
        goal_ball_dify = height/2 - ball.yy
        dist = math.sqrt(goal_ball_difx**2 + goal_ball_dify**2)
        goal_ball_dirx = goal_ball_difx / dist
        goal_ball_diry = goal_ball_dify / dist
        if dist < bot.radius*20:
            bot.requestPosition = (width + (goal_ball_dirx * dist/2), height/2 - goal_ball_diry*dist/2)
        else:
            bot.requestPosition = (width + (goal_ball_dirx *bot.radius*10), height/2 - goal_ball_diry*bot.radius*10)


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
