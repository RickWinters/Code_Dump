function[start, hole, points] = level3()


close all

points = [0 0
    7.5 0
    7.5 5
    15 5
    15 10
    2.5 10
    2.5 5
    0 5];

start  = [1 2.5];
hole = [12.5 7.5];

drawcourse(points,start,hole)

end