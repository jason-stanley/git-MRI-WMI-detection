function [imgWithZoomed, coor] = clickandzoom(img, edgeLength, scaleFactor, coor)
if nargin == 3
    figure, imshow(img, []);
    [coor(1), coor(2)] = ginput(1);
    close
elseif nargin == 4
end

imgZooming = img(coor(2)-edgeLength/2 : coor(2) + edgeLength/2, ... 
    coor(1)-edgeLength/2 : coor(1)+edgeLength/2);
imgZoomed = imresize(imgZooming, scaleFactor);
imgWithZoomed = img;
imgWithZoomed(end-size(imgZoomed,1)+1 : end, end-size(imgZoomed,2)+1 : end) = imgZoomed;









