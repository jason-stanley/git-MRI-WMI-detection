function [] = squareplot(img, window)
if(nargin == 1)
    window = [];
end
x = uint32(sqrt(size(img, 1)));
img = reshape(img, x, []);
figure, imshow(img, window);
end
