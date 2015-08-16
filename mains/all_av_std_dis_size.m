% For each true detection and false detection, compute:
% 1) the average brightness of the region and its standard deviation
% 2) also compute the same for its 10 pixel boundary neighborhood


% Results on folder 2,3 and 4 are seperated.

% Pengwei Wu, guided by Irene Cheng
clear; close all; clc; tic

path(path, '../toolbox');
path(path, '../functions');
path(path, '../misc');

booDebug = 0; booResult = 1; 
booAll = 0;

numImageF2 = 12;
numImageF3 = 8;
numImageF4 = 10;
if(booAll)
    rangeF2 = 1:1:12;
else
    rangeF2 = 2;
end

Data = [];

for loopImage = rangeF2
    
    pathImageDec = ['../data/Folder-2/secondBC0147-3-', num2str(loopImage), '-4.png'];
    pathImageRef = ['../data/Folder-2/secondBC0147-3-', num2str(loopImage), '-1.png'];
    pathImageRaw = ['../data/Folder-2/secondBC0147-3-', num2str(loopImage), '-2.png'];
    imgDec = imread(pathImageDec);
    imgRef = imread(pathImageRef);       
    imgRaw = imread(pathImageRaw);    
    
    
    dimSave1 = max(size(imgDec, 1), size(imgRef, 1));
    dimSave2 = max(size(imgDec, 2), size(imgRef, 2));
    
    imgDec = padarray(imgDec, [dimSave1 - size(imgDec,1) dimSave2 - size(imgDec, 2)], 255, 'post');
    imgRef = padarray(imgRef, [dimSave1 - size(imgRef,1) dimSave2 - size(imgRef, 2)], 0, 'post');
        
    maskBg = imgDec(:,:,2) == 255;
    
    imgDecGray = double(rgb2gray(imgDec)); % not used
    imgRefGray = double(rgb2gray(imgRef)); % not used
    imgRawGray = double(rgb2gray(imgRaw));
    
    maskDec = (imgDec(:,:,1) == 255) & (~(imgDec(:,:,1) == 255 & ...
        imgDec(:,:,2) == 255 & imgDec(:,:,3) == 255));
    maskRef = (imgRef(:,:,1) >= 150) & (~(imgRef(:,:,1) >= 150 & ...
        imgRef(:,:,2) >= 150 & imgRef(:,:,3) >= 150));
    
    maskSup = ones(size(maskRef)); maskSup(1:50, :) = 0; maskRef = maskRef & logical(maskSup);
    if(booDebug); mysubplot([], imgDec, imgRef, maskDec, maskRef); maxscreen(); end
    
    labelDec = bwlabel(maskDec, 8);
    labelRef = bwlabel(maskRef, 8);
    if(booDebug); mysubplot([], labelDec, labelRef); maxscreen(); end
    
    % Okay, then we know the exact number of the connected components. 
    
    numConnect = max(labelDec(:));
    DataPre = Data;
    for loopConnect = 1:1:numConnect
        maskSingleDec = labelDec == loopConnect;
        maskSingleRef = labelRef == loopConnect;
        Data(size(DataPre, 1) + 1, 1) = loopImage;
        Data(size(DataPre, 1) + 1, 2) = loopConnect;
        Data(size(DataPre, 1) + 1, 3) = mean(mean(imgRawGray(maskSingleDec)));
        Data(size(DataPre, 1) + 1, 4) = mean(mean(imgRawGray(maskSingleRef)));
        Data(size(DataPre, 1) + 1, 5) = std(imgRawGray(maskSingleDec));
        Data(size(DataPre, 1) + 1, 6) = std(imgRawGray(maskSingleRef));
        Data(size(DataPre, 1) + 1, 7) = mean(mean(imgRawGray(logic_dilate(maskSingleDec, 10))));
        Data(size(DataPre, 1) + 1, 8) = mean(mean(imgRawGray(logic_dilate(maskSingleRef, 10))));
        Data(size(DataPre, 1) + 1, 9) = std(imgRawGray(logic_dilate(maskSingleDec, 10)));
        % over 10 (wili, type setting)
        Data(size(DataPre, 1) + 1, 10) = std(imgRawGray(logic_dilate(maskSingleRef, 10)));        
        temp1 = regionprops(bwlabeln(maskSingleDec, 8), 'Area');
        temp2 = regionprops(bwlabeln(maskSingleRef, 8), 'Area');
        Data(size(DataPre, 1) + 1, 11) = temp1.Area;
        Data(size(DataPre, 1) + 1, 12) = temp2.Area;
        % time consuming (below)
        Data(size(DataPre, 1) + 1, 13) = dis_logical(maskSingleDec, maskBg);
        Data(size(DataPre, 1) + 1, 14) = dis_logical(maskSingleRef, maskBg);
    end
    
end


toc