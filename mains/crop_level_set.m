% This code implements the level set method by Chuming Li (2011, IEEE
% transaction), by Pengwei Wu, guided by Tianye Niu.
% The code implemented is now three-phase (which can be extended to four or
% more phases). 

clear; close all; clc; tic

path(path, '../toolbox');
path(path, '../functions');
imgPath = '../data/Folder-2/secondBC0147-3-2-2.png';

img = imread(imgPath);

% larger iter_outer means a higher accuracy.
iter_outer = 100; % times of iteration for outer loop
iter_inner = 10; % times of iteration for inner loop
sigma = 4; % scale parameter
timestep = .1;
mu = 0.1 / timestep; % (u in the passage)
A = 255; % (well, for double image, 255 pixel intervals)
nu = 0.001 * A ^ 2; % weight of length term (v)
c0 = 1;
epsilon = 1;

img = double(img(:,:,1)); % better than imdouble (which will normalize the image)
img = normalize01(img) * A; % rescale the image intensity to the interval [0,A]
Mask = (img > 5);

[nrow, ncol] = size(img);
numframe = 0;

figure;
% the window will always be [0 255]
imagesc(img, [0 255]); colormap(gray); hold on; axis off; axis equal;
title('Segmentation begins'); maxscreen();

% initialization of bias field and level set function
b = ones(size(img));
initialLSF(:,:,1) = randn(size(img)); % randomly initialize the level set functions
initialLSF(:,:,2) = randn(size(img)); % randomly initialize the level set functions
initialLSF(:,:,1) = Mask; % remove the background outside the mask
u = sign(initialLSF);

[~,~] = contour(u(:,:,1),[0 0],'r');
[~,~] = contour(u(:,:,2),[0 0],'b');

hold off
% Kernel for clustering  
% we have implemented two different kernels

booGaussianKernel = 1;
if(booGaussianKernel)
    Ksigma = fspecial('gaussian', round(2 * sigma) * 2 + 1, sigma); % Gaussian kernel
else
    disk_radius = 7; 
    Ksigma=fspecial('disk',disk_radius); % an alternative kernel as a truncated uniform function
end
KONE = conv2(ones(size(img)), Ksigma, 'same');

pause(0.1)

totaltime = 0;
disp(['Total time is now : ', num2str(totaltime)]);
for n = 1:iter_outer
   
    t0 = cputime;
    [u, b, C] =  lse_bfe_3Phase(u, img, b, Ksigma, KONE, nu, timestep, mu, epsilon, iter_inner);
    t1 = cputime;
    totaltime = totaltime + t1 - t0;
    
    if(mod(n,3) == 0)
        pause(0.01);
        imagesc(img,[0 255]); colormap(gray); hold on; axis off; axis equal;
        [~,~] = contour(u(:,:,1), [0 0], 'r');
        [~,~] = contour(u(:,:,2), [0 0], 'b');
        iterNum=[num2str(n), ' iterations'];
        title(iterNum);
        hold off;            
    end    
   
end
disp(['Total time is now : ', num2str(totaltime)]);

H1 =  Heaviside(u(:,:,1), epsilon);
H2 =  Heaviside(u(:,:,2), epsilon);
M1 = H1 .* H2;
M2 = H1 .* (1 - H2);
M3 = (1 - H1);

img_seg = C(1) * M1 + C(2) * M2 + C(3) * M3;  % three regions are labeled with C1, C2, C3
figure; imagesc(img_seg); axis off; axis equal; title('Segmented regions');
colormap(gray); maxscreen();

figure;
imagesc(img, [0 255]); colormap(gray);hold on; axis off; axis equal;
[~, ~] = contour(u(:,:,1),[0 0],'r','LineWidth',1);
[c, h] = contour(u(:,:,2),[0 0],'b','LineWidth',1); 
maxscreen();

figure; imagesc(img, [0,255]);colormap(gray); hold on; axis off; axis equal;
title('Original image');
 
img_corrected = normalize01(Mask .* img ./ (b + (b == 0))) * 255;
figure; imagesc(img_corrected, [0,255]); colormap(gray); hold on; axis off; axis equal;
title('Bias corrected image');

figure;
imshow(uint8(Mask .* normalize01(b) * 200), [0 255]); colormap(gray); ...
    hold on; axis off; axis equal
title('Estimated bias field (on the mask)');

figure; title('Histogram');
subplot(1,2,1)
[N, X] = hist(img(:), 30); plot(X, N, 'b', 'linewidth', 2); title('Histogram of original image');
subplot(1,2,2)
[N, X] = hist(img_corrected(:), 30); plot(X, N, 'r', 'linewidth', 2); title('Histogram of bias corrected image');

toc
