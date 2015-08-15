function [] = mysubplot(window, img1, img2, img3, img4, img5, img6)
if(nargin == 2)
    figure, imshow(img1, window);
elseif(nargin == 3)
    figure, subplot(121), imshow(img1, window);
    subplot(122), imshow(img2, window);
elseif(nargin == 4);
    figure, subplot(131), imshow(img1, window);
    subplot(132), imshow(img2, window);
    subplot(133), imshow(img3, window);
elseif(nargin == 5)
    figure, subplot(221), imshow(img1, window);
    subplot(222), imshow(img2, window);
    subplot(223), imshow(img3, window);
    subplot(224), imshow(img4, window);
elseif(nargin == 6);
    figure, subplot(131), imshow(img1, window);
    subplot(132), imshow(img2, window); subplot(133), imshow(img3, window);
    figure, subplot(121), imshow(img4, window);
    subplot(122), imshow(img5, window);
elseif(nargin == 7)
    figure, subplot(321), imshow(img1, window);
    subplot(322), imshow(img2, window);
    subplot(323), imshow(img3, window);
    subplot(324), imshow(img4, window);
    subplot(325), imshow(img5, window);
    subplot(326), imshow(img6, window);
end
end