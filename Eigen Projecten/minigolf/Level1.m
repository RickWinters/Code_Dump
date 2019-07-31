function[start, hole, points] = level1()
close all

points = [0 0
    10 0
    10 20
    5 20
    5 5
    0 5];

start  = [1 2.5];
hole = [7.5 18];

drawcourse(points,start,hole)

end