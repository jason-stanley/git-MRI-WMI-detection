% Modification of the original file -- m0912.m
% Aimed at data set in folder 3

% Pengwei Wu
function [] = m0723_folder3()


%% initialization
clear; close all; clc; tic;
path(path, '../toolbox');

global booDebug; global booDisplayResult; global booInfo;
booDebug = 0; booDisplayResult = 1; booInfo = 1;

booCropped = 1;
if(booCropped); 
    disp('Hi, let us begin the program');
else
    error('Please run "crop.m" before running this program'); %#ok<UNRCH>
end
%% looping
loopImageRange = 1:8;
for loopImage = loopImageRange
    if(length(loopImageRange) >= 2)
        if(booDebug)
            error('Do not turn on debugging mode when processing too many images');
        end
    end
    
    %% load the image to be processed
    pathImage = ['../data/Folder-3/', 'BC0160-2-', num2str(loopImage), '-3second.png'];
    pathImageRef = ['../data/Folder-3/', 'BC0160-2-', num2str(loopImage), '-1second.png'];
    pathImageRaw = ['../data/Folder-3/', 'BC0160-2-', num2str(loopImage), '-2second.png'];
    imgRawColor = imread(pathImage);
    imgRawColorRef = imread(pathImageRef);
    imgRawColorOrigin = imread(pathImageRaw);
    imgRaw = rgb2gray(imgRawColor); % make gray image default
    imgRawBack = imgRaw;
    
    if(booDebug); mysubplot([], imgRawColor, imgRaw); suptitle('Step 0 --- Load the image'); end;
    %% classify this image into injury & non-injury
%     booInju = classifierM(imgRaw); % output is boolean
%     if (booInju==0)    
%         clear imgRawColorDisplay;
%         imgRawBg = 255 * logical(imgRaw > 200);
%         imgRawColorDisplay(:,:,1) = imgRawBg;
%         imgRawColorDisplay(:,:,2) = imgRawBg;
%         imgRawColorDisplay(:,:,3) = ones(size(imgRawBg));   
%         if(booDisplayResult);             
%             figure, subplot(131), imshow(imgRawColorOrigin);
%     %         subplot(222), imshow(imgRawColorBack); 
%             subplot(132), imshow(imgRawColorDisplay); 
%             subplot(133), imshow(imgRawColorRef);
%             suptitle('Final results, with red indicating the white injury'); 
%             maxscreen();
%         end;
%         pathImageOut = ['../data/secondBC0147-3-', num2str(loopImage), '-4.png'];
%         imwrite(imgRawColorDisplay, pathImageOut, 'png')
%         continue
%     end
    %% stretch the histogram and group the intensity    
    % Parameter
    thHigh = 200; numPixGroup = 10; 
    % erase the background and stretch the histogram
    imgRaw = erase_bg(imgRaw, thHigh);  
    imgNoBg = imgRaw;
    logImgBg = (imgRaw == -1);
    % Group the intensity using force casting
    imgRaw = int16(double(imgRaw) / numPixGroup) * numPixGroup;
    imgRaw = -1 * (int16(logImgBg)) + imgRaw .* (1 - int16(logImgBg));
    if(booDebug); mysubplot([], imgRaw); 
        suptitle('Step 1 -- Stretch histogram and group intensities'); end;
    
    %% calculate the transition matrix
    % Parameter
    
    n = length(unique(imgRaw)) - 2; % -2 (n^0 exists and -1 in imgRaw)
    q = 0.6;
    polySolve = [0.4 zeros(1, n-1) -1 1 - q];
    rootSpace = roots(polySolve);
    logRoot = (imag(rootSpace) == 0) & (real(rootSpace) < 0.99) & (real(rootSpace) > 0) ;
    if(sum(logRoot) ~= 1)
        disp(rootSpace);
        error('Sorry, multiple roots. Try to figure out yourself');
    else
        alpha = rootSpace(logRoot);
        if(booInfo); disp(['Alpha is now : ', num2str(alpha)]); end
    end
        
    ParaTM = struct('method', 'formal', 'numPixGroup', numPixGroup,  ...
        'pBase', 0.4, ... % this line is for the simpe method
        'q', q, 'alpha', alpha); % this line is for the formal method 
    
    tMatrix = calc_t_matrix(imgRaw, ParaTM);
    if(booDebug); mysubplot([], tMatrix); suptitle('Step 2 -- Calculate transition matrix'); end;
        
    %% mark the potential boundary
    topPossibTh = 0.075; % 0.075  
    maskLowTM = sort_tm(tMatrix, topPossibTh);
    % this is used in the m0912 file, but I think it is not necessary and
    % it mentioned in the formal passage
    if(booDebug); mysubplot([], maskLowTM); suptitle('Step 3 -- Calculate initial boundary'); end;
    
    if 0  
        temp = maskLowTM - bwareaopen(maskLowTM, 200);
        se = strel('disk', 2);
        maskLowTM = imerode(maskLowTM, se);    
        maskLowTM = double(logical(maskLowTM) | logical(temp));
    end
    
    if(booDebug); mysubplot([], maskLowTM); suptitle('Step 3.5 -- Calculate initial boundary'); end;
    %% remove false boundary
    winSize = 10;    
    % winSize should be a little larger when 'wrong_boundary_fast' is used
    % (since se is circle-shaped), like 20
    % when 'wrong_boundary' is used, you can set winSize to be 15 (square-like)
    pixValThRation = 0.2; 
    pixValTh = max(imgRaw(:)) * pixValThRation;   
    maskHighPixValue = imgRaw >= pixValTh;
    
    maskBg = logImgBg; % change name only    
    % maskWrongBoundary = wrong_boundary(maskBg, maskLowTM, winSize);
    maskWrongBoundary = wrong_boundary_fast(maskBg, maskLowTM, winSize);
    maskLowTMRightPre = maskLowTM .* (1 - maskWrongBoundary) .* maskHighPixValue;
    maskLowTMRight = bwareaopen(maskLowTMRightPre, 5);    
    
    % this is an extra step (not included in the passage)
    % treat all central elements as false boundray
    
    bandWidth = 15;
    maskCentral = zeros(size(maskBg));
    maskCentral(:, floor(end/2)-bandWidth : floor(end/2)+bandWidth) = 1;
    maskLowTMRight = maskLowTMRight .* (1 - maskCentral);    
    if(booDebug); mysubplot([], maskLowTMRight, maskLowTM); suptitle('Step 4 -- Remove false boundary'); end;
    
    %% grow the boundary    
    simiTh = 5; % 5 is also good
    
    pixValThRation = 0.4; 
    pixValTh = max(imgRaw(:)) * pixValThRation;   
    maskHighPixValue = imgRaw >= pixValTh;
    % we are now using imgRawBack for growing
%     maskLowTMRightGrow = grow_boundary(imgNoBg, maskLowTMRight, ...
%         maskWrongBoundary | maskBg | (1 - maskHighPixValue), simiTh, pixValTh);
    maskLowTMRightGrow = grow_boundary(imgNoBg, maskLowTMRight, ...
        maskBg | (1 - maskHighPixValue), simiTh, pixValTh);

    if(booDebug); mysubplot([], imgNoBg, maskLowTMRightGrow, maskLowTMRight); suptitle('Step 5 -- Grow the boundary'); end;
    
    % test final procedure, shrinking 
    temp = maskLowTMRightGrow - bwareaopen(maskLowTMRightGrow, 100);
    se = strel('disk', 1);
    maskLowTMRightGrow = imerode(maskLowTMRightGrow, se);    
    maskLowTMRightGrow = double(logical(maskLowTMRightGrow) | logical(temp));
    
    if(booDebug); mysubplot([], imgNoBg, maskLowTMRightGrow, maskLowTMRight); suptitle('Step 5.5 -- Grow the boundary (shrinking)'); end;
    %% display & finale
    clear imgRawColorDisplay; % this var (without preallocation) must be destroyed
   
    imgRawDisplay = imgRawBack;
    imgRawDisplay(logical(maskLowTMRightGrow)) = 255;
    imgRawDisplay(~logical(maskLowTMRightGrow)) = 0;
    x1 = imgRawDisplay;               %red
    x3 = 255-imgRawDisplay;           %blue
    x2 = zeros(size(imgRawDisplay));  %green

    x1(maskBg) = 255;
    x2(maskBg) = 255;
    x3(maskBg) = 255;
    
    imgRawColorDisplay(:,:,1) = x1;
    imgRawColorDisplay(:,:,2) = x2;
    imgRawColorDisplay(:,:,3) = x3;
    
    imgOverlayDisplay = imgRawColorOrigin;
    imgOverlayDisplayOne = imgRawColorOrigin(:,:,1);
    imgOverlayDisplayOne(logical(maskLowTMRightGrow)) = 255;
    imgOverlayDisplay(:,:,1) = imgOverlayDisplayOne;
    
    
    if(booDisplayResult);   
        if(booDebug)
            figure, subplot(131), imshow(imgRawColorOrigin);
    %         subplot(222), imshow(imgRawColorBack); 
            subplot(132), imshow(imgRawColorDisplay); 
            subplot(133), imshow(imgRawColorRef);
            suptitle('Final results, with red indicating the white injury'); 
            maxscreen();
        end
        
        figure, subplot(121), imshow(imgOverlayDisplay);
        subplot(122), imshow(imgRawColorRef); suptitle('Final results, with red indicating the white injury');
        maxscreen();
    end;
    pathImageOut = ['../data/Folder-3/BC0160-2-', num2str(loopImage), '-4second.png'];
    imwrite(imgRawColorDisplay, pathImageOut, 'png')
    
    % Save the result now
    dimSave1 = max(size(imgRaw, 1), size(imgRawColorRef(:,:,1), 1));
    dimSave2 = max(size(imgRaw, 2), size(imgRawColorRef(:,:,1), 2));
    
    imgRawColorOrigin = padarray(imgRawColorOrigin, [dimSave1 - size(imgRawColorOrigin,1) dimSave2 - size(imgRawColorOrigin, 2)], 0, 'post');
    imgOverlayDisplay = padarray(imgOverlayDisplay, [dimSave1 - size(imgOverlayDisplay,1) dimSave2 - size(imgOverlayDisplay, 2)], 0, 'post');
    imgRawColorDisplay = padarray(imgRawColorDisplay, [dimSave1 - size(imgRawColorDisplay,1) dimSave2 - size(imgRawColorDisplay, 2)], 0, 'post');
    imgRawColorRef = padarray(imgRawColorRef, [dimSave1 - size(imgRawColorRef,1) dimSave2 - size(imgRawColorRef, 2)], 0, 'post');
    
    % Note that padarray can be used directly on color image
    
    pathImageOut = ['../misc/Folder-3/detect-', num2str(loopImage), '.png'];
    imwrite([uint8(imgRawColorOrigin), uint8(imgRawColorDisplay), ...
        uint8(imgOverlayDisplay), uint8(imgRawColorRef)], pathImageOut, 'png');
    
    
    %%

end
disp('Program is over');
disp('Bye, have a good day');
disp('Saved with postfix 4');
toc
end

function inQueue = grow_boundary(img, mask, forbid, simiTh, pixValTh)

    % forbid is the forbidden region of growing method
    [m, n] = size(mask);
    
    [inx, iny] = find(mask == 1);
    queue = [inx iny];
    inQueue = zeros(size(img));
    inQueue(mask == 1) = 1; % all the boundary is now in queue for further growing

    while (~isempty(queue))
        t = queue(1,:);
        x = t(1); y = t(2);
        for i = max(1, x-1):min(m, x+1) % in general -- x-1:x+1
            for j = max(1, y-1):min(n,y+1)
                if ((abs(img(i, j) - img(x, y)) < simiTh)  && forbid(i, j) == 0 && img(i, j) > pixValTh)
                    new = [i j];
                    if inQueue(i, j) == 0 % not a member for now
                        queue(size(queue, 1)+1, :) = new;
                        inQueue(i, j) = 1;
                    end
                end
            end
        end
        queue(1,:) = [];
    end  
        
end

function mask = wrong_boundary(maskBg, maskLowTM, winSize)
    
    % winSize : about detecting false boundary (near the outside part)
    % increase winSize will slow down the algorithm significantly
    mask = zeros(size(maskLowTM));
    [inx1, iny1] = find(maskBg == 1);
    queue1 = [inx1 iny1];

    [m, n]=size(mask);
    for t = 1:size(queue1, 1)
        x = inx1(t); y = iny1(t);
        for i = max(1, x - winSize):min(m, x + winSize)
            for j = max(1, y - winSize):min(n, y + winSize)
                if (maskLowTM(i,j))
                    mask(i, j) = 1; % fake boundary                    
                end
            end
        end
    end
end

function mask = wrong_boundary_fast(maskBg, maskLowTM, winSize)
    
%     mask = zeros(size(maskLowTM));
    se = strel('disk', winSize);
    mask = imdilate(maskBg, se);
    mask = mask .* maskLowTM;
end

function mask = sort_tm(tMatrix, possibTH)

    global booDebug
    tMatrix1D = tMatrix(:);
    % bg is back ground, fg is fore ground
    % tm stands for the 1D version of transition matrix (inside part only)
    [sortedTM, posiTM] = sort(tMatrix1D, 'ascend'); % sort (ascending)
    numPixFg = sum(tMatrix1D ~= 1);
    mask1D = zeros(size(tMatrix1D));    
    length = round(possibTH * numPixFg);
    
%     if(booDebug); plot(sortedTM); 
%     title('We should be able to calculate the threshold from this plot of the transition matrix');
%     end;
    
    for i = 1:length
        mask1D(posiTM(i)) = 1;         
    end
    mask = reshape(mask1D, size(tMatrix));
end

function imgOut = erase_bg(img, thHigh, thLow)

if(nargin == 1)
    % eliminate background and redistribute pixel values
    thresholdHigh = 200;
    % thresholdLow = 20;
elseif(nargin == 2)
    thresholdHigh = thHigh;
end

imgTemp = img(:);         % transform the 2D matrix to 1D 
idx = find(imgTemp < thresholdHigh);  
img1d = imgTemp(idx);      % remove the white part pixel around the brain

img1dseg = int16(double(img1d - min(img1d)) / double(max(img1d) - min(img1d)) * 255);
imgTemp = zeros(size(imgTemp)) - 1; % use -1 (minus 1) as indicator 
imgTemp(idx) = img1dseg; % put the white part around back
imgOut = reshape(imgTemp, size(img));  % change 1D back to 2D

end

function tMatrix = calc_t_matrix(img, Para)
ds = Para.numPixGroup;
tMatrix = ones(size(img));
% you can use both the simple version and the formal version shown in the
% original paper work (as controlled by the field 'method')

if(strcmp(Para.method, 'simple'))
    p = Para.pBase;       
    % right and below (down)
    for j = 1:size(img, 2) - 1                     % compute the posibility of leaping levels for every pixel
        for i = 1:size(img, 1) - 1                 % using the right pixel and the under one 
           if(img(i, j) >= 0)                      % -1 is the outside part (indicator)
                if(img(i, j + 1) >= 0 && img(i + 1,j) >= 0)     
                    power1 = abs( img(i, j) - img(i + 1, j) );     
                    power2 = abs( img(i, j) - img(i, j + 1) );
                    power1 = double(power1 / ds);
                    power2 = double(power2 / ds);
                    if power1 == 0 
                        p1 = 1 - p;
                    else p1 = p ^ power1; % more difference, bigger p1
                    end
                    if power2 == 0 
                        p2 = 1 - p; 
                    else p2 = p ^ power2;
                    end
                    tMatrix(i, j) = p1 * p2;
                 end
            end
        end 
    end
    
elseif(strcmp(Para.method, 'formal'))
    q = Para.q;
    alpha = Para.alpha;
    % ds and tMatrix calculated above
    for j = 2:size(img, 2) - 1
        for i = 1:size(img, 1) - 1
            if(img(i, j) >= 0)  
                if(img(i, j + 1) >= 0 && img(i + 1,j) >= 0) 
                    p1 = q * alpha ^ double((abs( img(i, j) - img(i + 1, j) ) / ds));
                    p2 = q * alpha ^ double((abs( img(i, j) - img(i + 1, j + 1) ) / ds));
                    p3 = q * alpha ^ double((abs( img(i, j) - img(i, j + 1) ) / ds));
                    p4 = q * alpha ^ double((abs( img(i, j) - img(i - 1, j) ) / ds));
                    p5 = q * alpha ^ double((abs( img(i, j) - img(i - 1, j - 1) ) / ds));
                    p6 = q * alpha ^ double((abs( img(i, j) - img(i + 1, j - 1) ) / ds));
                    p7 = q * alpha ^ double((abs( img(i, j) - img(i - 1, j + 1) ) / ds));
                    p8 = q * alpha ^ double((abs( img(i, j) - img(i, j - 1) ) / ds));
                    % tMatrix(i, j) = double(p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8);
                    % actually, plus or multiply is not defined in the passage
                    tMatrix(i, j) = double(p1 * p2 * p3 * p4 * p5 * p6 * p7 * p8);
                end
            end
        end
    end   
    
end

end

    







