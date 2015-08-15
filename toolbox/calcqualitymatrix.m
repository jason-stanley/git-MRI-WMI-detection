function qMatrix = calcqualitymatrix(img, coor, edgeLength, booClick)

% First Y then X
if (booClick == 1)
    for i = 1:1:size(coor,2)
        coorX = coor(1,i);
        coorY = coor(2,i);
        data = img(coorY-edgeLength/2 : coorY + edgeLength/2, coorX-edgeLength/2 : coorX+edgeLength/2);
        qMatrix(1,i) = mean(data(:));  %#ok<*AGROW>
    end
elseif (booClick == 2)
    for i = 1:1:size(coor,2)
        coorX = coor(1,i);
        coorY = coor(2,i);
        data = img(coorY-edgeLength/2 : coorY + edgeLength/2, coorX-edgeLength/2 : coorX+edgeLength/2);
        preMatrix(1,i) = mean(data(:)); 
    end
    for i = 1:1:size(coor,2)/2
        qMatrix(1,i) = preMatrix(2 * i - 1);
        qMatrix(2,i) = preMatrix(2 * i - 1) - preMatrix(2 * i);
    end

end
