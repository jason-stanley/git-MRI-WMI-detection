clear; close all; clc

% Please add number of connected parts
clear; close all; clc
path(path, '../toolbox');

booDebug = 0; booResult = 1;
numCorrect = 17; % 17 images successfully detected
range = 1:17;
idImage = [2:12 2:5 7 8];

dataGraph = zeros(5, numCorrect);

for loopImage = range
    
    if(loopImage <= 11)
        pathImageDec = ['../data/Folder-2/secondBC0147-3-', num2str(idImage(loopImage)), '-4.png'];
        pathImageRef = ['../data/Folder-2/secondBC0147-3-', num2str(idImage(loopImage)), '-1.png'];
        imgDec = imread(pathImageDec);
        imgRef = imread(pathImageRef);        
    else
        pathImageDec = ['../data/Folder-3/BC0160-2-', num2str(idImage(loopImage)), '-4second.png'];
        pathImageRef = ['../data/Folder-3/BC0160-2-', num2str(idImage(loopImage)), '-1second.png'];
        imgDec = imread(pathImageDec);
        imgRef = imread(pathImageRef);   
    end
    
    dimSave1 = max(size(imgDec, 1), size(imgRef, 1));
    dimSave2 = max(size(imgDec, 2), size(imgRef, 2));
    
    imgDec = padarray(imgDec, [dimSave1 - size(imgDec,1) dimSave2 - size(imgDec, 2)], 255, 'post');
    imgRef = padarray(imgRef, [dimSave1 - size(imgRef,1) dimSave2 - size(imgRef, 2)], 0, 'post');
        
    maskDec = (imgDec(:,:,1) == 255) & (~(imgDec(:,:,1) == 255 & ...
        imgDec(:,:,2) == 255 & imgDec(:,:,3) == 255));
    maskRef = (imgRef(:,:,1) >= 150) & (~(imgRef(:,:,1) >= 150 & ...
        imgRef(:,:,2) >= 150 & imgRef(:,:,3) >= 150));
    
    maskSup = ones(size(maskRef)); maskSup(1:50, :) = 0; maskRef = maskRef & logical(maskSup);
    if(booDebug); mysubplot([], imgDec, imgRef, maskDec, maskRef); maxscreen(); end

    areaDec = regionprops(bwlabeln(maskDec, 8), 'Area');
    areaRef = regionprops(bwlabeln(maskRef, 8), 'Area');
    
    if(loopImage <= 11) 
        dataGraph(1, loopImage) = idImage(loopImage);
    else
        dataGraph(1, loopImage) = -idImage(loopImage);
    end
    
    dataGraph(2, loopImage) = sum(maskRef(:));
    dataGraph(3, loopImage) = sum(maskDec(:));
    dataGraph(4, loopImage) = dataGraph(2, loopImage) - dataGraph(3, loopImage);
    dataGraph(5, loopImage) = (dataGraph(2, loopImage) + dataGraph(3, loopImage)) / 2;
    
end


% erase one line £¿
% dataGraph(:, 6) = [];





scale = (6.16/233)^2;
dataGraph(2:5, 1:end) = dataGraph(2:5, 1:end) * scale;
% Based on [0 0.3) [0.3 0.6) [0.6 0.9) [0.9 1.2) [1.2 1.5]
dataCell = cell(5, 4);
dataCell{1,1} = '0.0-0.3'; dataCell{2,1} = '0.3-0.6';
dataCell{4,1} = '0.6-0.9'; dataCell{3,1} = '0.9-1.2';
dataCell{5,1} = '1.2-max'; 
% Remember this syntax
dataCell(1:5, 2:3) = num2cell(zeros(5,2));

for loopData = 1:1:size(dataGraph, 2)
    if dataGraph(5, loopData) < 0.3
        dataCell{1, 2} = dataCell{1, 2} + 1; % this is legal 
        dataCell{1, 3} = dataCell{1, 3} + dataGraph(4, loopData);
        dataCell{1, 4} = [dataCell{1, 4} dataGraph(1, loopData)];
    elseif dataGraph(5, loopData) < 0.6
        dataCell{2, 2} = dataCell{2, 2} + 1; 
        dataCell{2, 3} = dataCell{2, 3} + dataGraph(4, loopData);
        dataCell{2, 4} = [dataCell{2, 4} dataGraph(1, loopData)];
    elseif dataGraph(5, loopData) < 0.9
        dataCell{3, 2} = dataCell{3, 2} + 1;
        dataCell{3, 3} = dataCell{3, 3} + dataGraph(4, loopData);
        dataCell{3, 4} = [dataCell{3, 4} dataGraph(1, loopData)];
    elseif dataGraph(5, loopData) < 1.2
        dataCell{4, 2} = dataCell{4, 2} + 1;   
        dataCell{4, 3} = dataCell{4, 3} + dataGraph(4, loopData);
        dataCell{4, 4} = [dataCell{4, 4} dataGraph(1, loopData)];
    else
        dataCell{5, 2} = dataCell{5, 2} + 1;
        dataCell{5, 3} = dataCell{5, 3} + dataGraph(4, loopData);
        dataCell{5, 4} = [dataCell{5, 4} dataGraph(1, loopData)];
    end        
end

% Aver will be calculated
dataCell(1:5, 3) = num2cell(cell2mat(dataCell(1:5, 3))  ...
    ./ cell2mat(dataCell(1:5, 2)));

rowLabels = {'image id', 'area of ground truth', 'area of auto-detected', 'difference', 'aver'};
rawData = table(dataGraph, 'RowNames', rowLabels);
% matrix2latex(dataGraph, 'out.tex');

if(booResult)    
    figure;
    plot(dataGraph(5, :), dataGraph(4, :), 'r*');
    axis([0 max(dataGraph(5, :)) -1 1]);
    set(gca, 'FontSize', 15);
    grid on; hold on;
    set(gca,'xtick',0:0.1:max(dataGraph(5, :)), 'ytick',-1:0.1:1)
    aver = mean(dataGraph(4, :));
    stdBlue = 1.96 * std(dataGraph(4, :) * scale);
    plot([0 max(dataGraph(5, :))], [aver aver], 'r', 'linewidth', 2);
    plot([0 max(dataGraph(5, :))], [stdBlue stdBlue], 'b', 'linewidth', 2);
    plot([0 max(dataGraph(5, :))], [-stdBlue -stdBlue], 'b', 'linewidth', 2);
    ylabel('Ground Truth Area - Automatically Detected Area (cm^{2})', 'FontName', 'Arial', 'FontSize', 15);
    xlabel('Avergae of Automatically Detected Area and Ground Truth Area (cm^{2})', 'FontName', 'Arial', 'FontSize', 15);
    set(gcf, 'color', 'white');
    title('B-A Analysis');
    maxscreen();
end