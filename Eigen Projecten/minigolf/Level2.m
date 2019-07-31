function[start, hole, points] = level2()


close all

points = [10 0
    10 5
    5 5
    5 10
    15 10
    15 0];

start  = [12.5 1];
hole = [7 6.5];

drawcourse(points,start,hole)

end