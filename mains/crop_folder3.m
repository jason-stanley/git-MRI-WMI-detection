% This is a new segmentation progam
% Aimed at images contained in folder 3 which can not be filling easily
% Pengwei Wu : 2015/07/23

% The red and green cross is a huge problem

disp('Let us begin');
path(path, '../toolbox');
clear; close all; clc; tic;

boseFigure = 0;
boseResult = 1;
booSave = 1;
loopImageRange = 1:8;
for loopImage = loopImageRange; % max is 8 for folder BC0160
    if(boseFigure)
        if(length(loopImageRange) >= 2)
            error('Too many figures to be displayed');
        end
    end
    
    %----- Read the raw image -----
    pathImage = ['../data/Folder-3/BC0160-2-', num2str(loopImage), '-2second.png'];
    imgRaw = imread(pathImage); imgRawBack = imgRaw;
    imgRaw = uint8(imgRaw(:,:,1));
    dim1 = size(imgRaw, 1); dim2 = size(imgRaw, 2);
    
    pathRef = ['../data/Folder-3/BC0160-2-', num2str(loopImage), '-1second.png'];
    imgRef = imread(pathRef); 
    
    %----- Stretch the histogram -----
    imgRawContra = uint8(255 * imadjust(double(imgRaw) / 255, [60 110] / 255, [0 1]));
    if(boseFigure), figure, imshow(imgRawContra, []); end   
    
    %----- Distill the dark parts -----
    maskThresLow = imgRawContra < 20;    
    maskThresLowGrow = grow_queue(maskThresLow, [134, 92; 130, 148], 1); 
    if(boseFigure), mysubplot([], maskThresLow, maskThresLowGrow); end
    
    %----- Generate seeds & growing -----
    se = strel('disk', 1);
    maskThresLowGrowDilate = logical(imdilate(maskThresLowGrow, se));
    if(boseFigure); figure, imshow(maskThresLowGrowDilate - maskThresLowGrow, []); end    
    [queueX, queueY] = find((maskThresLowGrowDilate - maskThresLowGrow) == 1);
    queue = [queueX queueY];  
        
    % final is made of final one and final two
    % two parameters lie below
    finalOne = logical(grow_queue(imgRawContra, queue, 10));     
    finalTwo = imgRawContra < 100 & imgRawContra > 5; % logical
    if(boseFigure); mysubplot([], finalOne, finalTwo); end 
    
    %----- Combin the results -----
    finalOT = finalOne | finalTwo;
    finalOT = bwareaopen(imfill(finalOT, 'holes'), 500, 4);
    final = finalOT & ~maskThresLowGrow;
    if(boseFigure); mysubplot([], finalOT, final); end
    
    
    %----- Display and save the results -----
    maskFinal = final;   
    
    % Extra step, dealing with the green and red cross at the upper right
    % corner of the un-cropped image.
    
    maskFinal = bwareaopen((imgRawBack(:,:,3) .* uint8(maskFinal)) > 0, 5000, 4);    
    imgSeg = imgRaw .* uint8(maskFinal);
    
    imgRawMarkRed = imgRaw;
    imgRawMarkRed(logical(maskFinal)) = 255;    
    clear imgRawMark; % since different images are in different size
    clear imgRawSave imgRaw3D imgSeg3D;
    imgRawMark(:,:,1) = imgRawMarkRed;
    imgRawMark(:,:,2) = imgRaw;
    imgRawMark(:,:,3) = imgRaw;
    % uint8 imgRawSave
    imgRawSave(:,:,1) = imgRawBack(:,:,1) .* uint8(maskFinal) + uint8(255 * ones(dim1, dim2)) .* uint8(1 - maskFinal);
    imgRawSave(:,:,2) = imgRawBack(:,:,2) .* uint8(maskFinal) + uint8(255 * ones(dim1, dim2)) .* uint8(1 - maskFinal);
    imgRawSave(:,:,3) = imgRawBack(:,:,3) .* uint8(maskFinal) + uint8(255 * ones(dim1, dim2)) .* uint8(1 - maskFinal);
    
    dimSave1 = max(size(imgRaw, 1), size(imgRef, 1));
    dimSave2 = max(size(imgRaw, 2), size(imgRef, 2));
    
    imgRaw = padarray(imgRaw, [dimSave1 - size(imgRaw,1) dimSave2 - size(imgRaw, 2)], 0, 'post');
    imgSeg = padarray(imgSeg, [dimSave1 - size(imgSeg,1) dimSave2 - size(imgSeg, 2)], 0, 'post');
    imgRef = padarray(imgRef, [dimSave1 - size(imgRef,1) dimSave2 - size(imgRef, 2)], 0, 'post');
    
    if(boseResult)
        mysubplot([], imgRaw, imgSeg, imgRawMark); % no need for casting
        maxscreen();
    end
    imgRaw3D(:,:,1) = imgRaw; imgRaw3D(:,:,2) = imgRaw; imgRaw3D(:,:,3) = imgRaw;
    imgSeg3D(:,:,1) = imgSeg; imgSeg3D(:,:,2) = imgSeg; imgSeg3D(:,:,3) = imgSeg;
    if(booSave)
        pathImageOut = ['../data/Folder-3/BC0160-2-', num2str(loopImage), '-3second.png'];
        imwrite(imgRawSave, pathImageOut, 'png')
        pathImageOut = ['../misc/Folder-3/crop-', num2str(loopImage), '.png'];
        imwrite([uint8(imgRaw3D), uint8(imgSeg3D), uint8(imgRef)], pathImageOut, 'png');
    end    
    
end
