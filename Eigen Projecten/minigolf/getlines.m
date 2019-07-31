function[linesx,linesy] = getlines(points)

j = 1;
linesx = [0 0 0];
linesy = [0 0 0];

for i = 1:size(points,1) - 1
    if points(i,2) == points(i+1,2)
        linesx(j,:) = [points(i,1) points(i+1,1) points(i,2)];
        if linesx(j,2) < linesx(j,1)
            linesx(j,[1 2]) = linesx(j,[2 1]);
        end
        j = j+1;
    end  
end

j = 1;
for i = 1:size(points,1)-1
    if points(i,1) == points(i+1,1)
        linesy(j,:) = [points(i,2) points(i+1,2) points(i,1)];
        if linesy(j,2) < linesy(j,1)
            linesy(j,[1 2]) = linesy(j,[2 1]);
        end
        j = j+1;
    end
end

end