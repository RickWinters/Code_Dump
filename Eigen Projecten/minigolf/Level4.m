function[start, hole, points] = level4()


close all

points = [0 0
    40 0
    40 10
    35 10
    35 2.5
    0 2.5];

start  = [1 1];
hole = [38 9];

drawcourse(points,start,hole)

end