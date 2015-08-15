function [coorXY] = multiclickanddraw(img, window, numClick, edgeLength, booClick)
% edgeLength must be even
% coorXY is numClick * 2 (dimension)
textGap = 20;
figure, imshow(img, window);
% set(gcf,'outerposition',get(0,'screensize'));
coorXClick = zeros(1, numClick);
coorYClick = zeros(1, numClick);
for i = 1:1:numClick
    [coorXClick(i), coorYClick(i)] = ginput(1);
    if(booClick == 1)
        lineX = [coorXClick(i) - edgeLength/2, coorXClick(i) + edgeLength/2, ...
            coorXClick(i) + edgeLength/2, coorXClick(i) - edgeLength/2, coorXClick(i) - edgeLength/2];
        lineY = [coorYClick(i) - edgeLength/2, coorYClick(i) - edgeLength/2, coorYClick(i) + edgeLength/2, ...
            coorYClick(i) + edgeLength/2, coorYClick(i) - edgeLength/2];    
        line(lineX,lineY, 'color', [0 0 0], 'linewidth', 1), ...
            text(coorXClick(i) - edgeLength/2 - textGap, coorYClick(i) - edgeLength/2 - textGap, ...
            num2str(i), 'color', [0 0 0], 'fontsize', 22);    
    elseif(booClick == 2)
        if(mod(i,2))
        lineX = [coorXClick(i) - edgeLength/2, coorXClick(i) + edgeLength/2, ...
            coorXClick(i) + edgeLength/2, coorXClick(i) - edgeLength/2, coorXClick(i) - edgeLength/2];
        lineY = [coorYClick(i) - edgeLength/2, coorYClick(i) - edgeLength/2, coorYClick(i) + edgeLength/2, ...
            coorYClick(i) + edgeLength/2, coorYClick(i) - edgeLength/2];    
        line(lineX,lineY, 'color', [0 0 0], 'linewidth', 2), ...
            text(coorXClick(i) - edgeLength/2 - textGap, coorYClick(i) - edgeLength/2 - textGap, ...
            num2str((i+1)/2), 'color', [0 0 0], 'fontsize', 22);    
        else
        lineX = [coorXClick(i) - edgeLength/2, coorXClick(i) + edgeLength/2, ...
            coorXClick(i) + edgeLength/2, coorXClick(i) - edgeLength/2, coorXClick(i) - edgeLength/2];
        lineY = [coorYClick(i) - edgeLength/2, coorYClick(i) - edgeLength/2, coorYClick(i) + edgeLength/2, ...
            coorYClick(i) + edgeLength/2, coorYClick(i) - edgeLength/2];    
        line(lineX,lineY, 'color', [0.9 0.9 0.9], 'linewidth', 2), ...
            text(coorXClick(i) - edgeLength/2 - textGap, coorYClick(i) - edgeLength/2 - textGap, ...
            strcat(num2str(i/2), '*'), 'color', [0.9 0.9 0.9], 'fontsize', 22);          
        end
    end
end    
    
coorXY = [uint32(coorXClick); uint32(coorYClick)];
end
