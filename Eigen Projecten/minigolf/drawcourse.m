function[] = drawcourse(points,start,hole)
figure
hold on

for n = 1:size(points,1)-1
    line([points(n,1) points(n+1,1)], [points(n,2) points(n+1,2)])
end
line([points(1,1) points(size(points,1),1)], [points(1,2) points(size(points,1),2)])

plot(start(1),start(2),'ob')
plot(hole(1),hole(2),'og')

end