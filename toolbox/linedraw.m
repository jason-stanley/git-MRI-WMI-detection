function [] = linedraw(coor, edgeLength)


lineX = [coor(1) - edgeLength/2, coor(1) + edgeLength/2, ...
    coor(1) + edgeLength/2, coor(1) - edgeLength/2, coor(1) - edgeLength/2];
lineY = [coor(2) - edgeLength/2, coor(2) - edgeLength/2, coor(2) + edgeLength/2, ...
    coor(2) + edgeLength/2, coor(2) - edgeLength/2];    
line(lineX,lineY, 'color', [0.9 0.9 0.9], 'linewidth', 1);

end