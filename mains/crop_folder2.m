function [] = crop_folder2()

% This program is used to segment the image provided in folder 2
% This program will save the cropped image into the same folder with the
% postfix '3' (if booSave is set as '1')
% Pengwei Wu

disp('Let us begin');
path(path, '../toolbox');
% This function is used to crop the image and distill the white matter
clear; close all; clc; tic;
boseFigure = 0;
boseResult = 1;
booSave = 1;

for loopImage = 1:12;
    pathImage = ['../data/Folder-2/secondBC0147-3-', num2str(loopImage), '-2.png'];
    imgRaw = imread(pathImage);
    imgRawBack = imgRaw;
    dim1 = size(imgRaw, 1); dim2 = size(imgRaw, 2);
    imgRaw = uint16(imgRaw(:,:,1));
    if(loopImage >= 11)
        maskThres = (imgRaw <= 85) .* (imgRaw > 60);
    else
        maskThres = (imgRaw <= 78) .* (imgRaw > 60);
    end
    maskThresLow = imgRaw <= 58;
    
    disp(['We are now processing on image : ', num2str(loopImage)]);

    maskThresGrow = grow_queue(maskThres, [154, 77; 179, 264], 1); % 95 202
    % [154, 77; 177, 261], like this, if white matters are not connected
    maskThresFilled = imfill(maskThresGrow, 'holes');
    
    maskThresLowLarge = bwareaopen(maskThresLow, 100); % so 85 is good for 3-12-2
    maskThresFinal = maskThresFilled .* (~maskThresLowLarge);

    % Ok, everything is done, let us display the result


    if(boseFigure)
        mysubplot([], imgRaw, maskThres, maskThresGrow, maskThresLow, maskThresLowLarge, maskThresFinal);
        figure, imshow(maskThresFilled, []);
    end
    imgSeg = imgRaw .* uint16(maskThresFinal);
    imgRawMarkRed = imgRaw;
    imgRawMarkRed(logical(maskThresFinal)) = 255;
    
    clear imgRawMark; % since different images are in different size
    clear imgRawSave imgRaw3D imgSeg3D;
    imgRawMark(:,:,1) = imgRawMarkRed;
    imgRawMark(:,:,2) = imgRaw;
    imgRawMark(:,:,3) = imgRaw;
    
    imgRawSave(:,:,1) = imgRawBack(:,:,1) .* uint8(maskThresFinal) + uint8(255 * ones(dim1, dim2)) .* uint8(1 - maskThresFinal);
    imgRawSave(:,:,2) = imgRawBack(:,:,2) .* uint8(maskThresFinal) + uint8(255 * ones(dim1, dim2)) .* uint8(1 - maskThresFinal);
    imgRawSave(:,:,3) = imgRawBack(:,:,3) .* uint8(maskThresFinal) + uint8(255 * ones(dim1, dim2)) .* uint8(1 - maskThresFinal);
    
    if(boseResult)
        mysubplot([], imgRaw, imgSeg, uint8(imgRawMark));
        maxscreen();
    end
    imgRaw3D(:,:,1) = imgRaw; imgRaw3D(:,:,2) = imgRaw; imgRaw3D(:,:,3) = imgRaw;
    imgSeg3D(:,:,1) = imgSeg; imgSeg3D(:,:,2) = imgSeg; imgSeg3D(:,:,3) = imgSeg;
    if(booSave)
        if(boseFigure)
            figure, imshow(imgRawSave, []); %#ok<UNRCH>
        end
        pathImageOut = ['../data/Folder-2/secondBC0147-3-', num2str(loopImage), '-3.png'];
        imwrite(imgRawSave, pathImageOut, 'png')
        pathImageOut = ['../misc/Folder-2/crop-', num2str(loopImage), '.png'];
        imwrite([uint8(imgRaw3D), uint8(imgSeg3D), uint8(imgRawMark)], pathImageOut, 'png');
    end       

    toc
    
end

disp('Have a good day');
end

function inQueue = grow_queue(img, queue, simiTh, forbid, pixValTh)
    % img : inputted image
    % queue : initial points in queue
    %       eg : [1 3; 4 5] (x(1) y(1); x(2) y(2))
    %       row first, then column 
    % simiTh : similarity threshold
    % forbid : forbidden region
    % pixValTh : pixel value threshold
    
    % inQueue : the outputted image ('1' for the points in queue)
    % Pengwei Wu
    
    
    if(nargin < 5)        
        pixValTh = min(img(:));    
    end
    if(nargin < 4)
        forbid = zeros(size(img));      
    end
    if(nargin < 3)
        error('Not enough arguments in growing');
    end

    % forbid is the forbidden region of growing method
    [m, n] = size(img);

    inQueue = zeros(size(img));
    inQueue(sub2ind(size(img), queue(:,1), queue(:,2))) = 1; % all the boundary is now in queue for further growing

    while (~isempty(queue))
        t = queue(1,:);
        x = t(1); y = t(2);
        for i = max(1, x-1):min(m, x+1) % in general -- x-1:x+1
            for j = max(1, y-1):min(n,y+1)
                if ((abs(img(i, j) - img(x, y)) < simiTh)  && forbid(i, j) == 0 && img(i, j) >= pixValTh)
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


