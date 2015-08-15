function [X, Y] = getpolyvalcoor(img)
figure();
imshow(img, []);
set(gcf,'outerposition',get(0,'screensize'));
[X, Y] = ginput();
X = uint16(X');
Y = uint16(Y');
end

