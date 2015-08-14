clear; close all; clc

path(path, '../toolbox');

for loopImage = 1:1:12

    pathImageOld = ['../data/Folder-2/secondBC0147-3-', num2str(loopImage), '-3.png'];
    pathImageRef = ['../data/Folder-2/secondBC0147-3-', num2str(loopImage), '-1.png'];
    pathImageNew = ['../data/Folder-2/secondBC0147-3-', num2str(loopImage), '-4.png'];
    
    imgOld = imread(pathImageOld);
    imgNew = imread(pathImageNew);
    imgRef = imread(pathImageRef);
    
    dim1 = max(size(imgOld, 1), size(imgRef, 1));
    dim2 = max(size(imgOld, 2), size(imgRef, 2));
    
    imgOld = padarray(imgOld, [dim1 - size(imgOld,1) dim2 - size(imgOld, 2)], 255, 'post');
    imgNew = padarray(imgNew, [dim1 - size(imgNew,1) dim2 - size(imgNew, 2)], 255, 'post');
    imgRef = padarray(imgRef, [dim1 - size(imgRef,1) dim2 - size(imgRef, 2)], 255, 'post');
    
    pathImageOut = ['../misc/Folder-2/detect-', num2str(loopImage), '.png'];
    imwrite([uint8(imgOld), uint8(imgRef), uint8(imgNew)], pathImageOut, 'png');    
    
end

