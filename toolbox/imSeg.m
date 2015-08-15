function imgSegLayer = imSeg(img, Para)
% img is the imgRaw
% Para is a struct containing the corresponding parameters
% Author: Pengwei Wu
dim1 = Para.infoDimension(1);
dim2 = Para.infoDimension(2); 
if(size(Para.infoDimension) > 2); dim3 = Para.infoDimension(3); end %#ok<NASGU>
imgSegLayer = zeros(dim1, dim2, 3);
% Water % Air % Bone


if(strcmp(Para.method, 'softThreshold_2'))
    thres = Para.threshold;
    logicCenter = (img > thres(1)) .* (img < thres(2));
    logicSupBone = double((~logicCenter)) .* double(img > thres(2));
    logicSupWater = double((~logicCenter)) .* double(img < thres(1));
    coorXBone = [thres(1) thres(2)]; coorYBone = [0 1];
    pBone = polyfit(coorXBone, coorYBone, 1);
    imgSegBoneLogic = polyval(pBone, img); 
    imgSegBoneLogic = imgSegBoneLogic .* logicCenter + logicSupBone;
    imgSegBone = img .* imgSegBoneLogic;
    
    coorXWater = [thres(1) thres(2)]; coorYWater = [1 0];
    pWater = polyfit(coorXWater, coorYWater, 1);
    imgSegWaterLogic = polyval(pWater, img);
    imgSegWaterLogic = imgSegWaterLogic .* logicCenter + logicSupWater;
    imgSegWater = img .* imgSegWaterLogic;   
    imgSegLayer(:,:,1) = imgSegWater; imgSegLayer(:,:,3) = imgSegBone;
end

if(strcmp(Para.method, 'hardThreshold_2'))
    thres = Para.threshold;
    imgSegBone = img .* (img >= thres(2));
    imgSegWater = img .* (img <= thres(1));    
    imgSegLayer(:,:,1) = imgSegWater; imgSegLayer(:,:,3) = imgSegBone;      
end

if(strcmp(Para.method, 'hardThreshold_3'))
    thres = Para.threshold;
    imgSegBone = img .* (img >= thres(3));
    imgSegBack = img .* (img <= thres(1));   
    imgSegAir = img .* (img >= thres(1)) .* (img <= thres(2));
    suppLogic = zeros(dim1, dim2); suppLogic(162:243, 137:352) = 1;
    imgSegLayer(:,:,1) = imgSegBack; imgSegLayer(:,:,2) = imgSegAir .* suppLogic; imgSegLayer(:,:,3) = imgSegBone;      
end

if(strcmp(Para.method, 'manual'))
    figure, imshow(img, Para.window);
    set(gcf,'outerposition',get(0,'screensize'));
    logicSeg = zeros(dim1, dim2);
    for i = 1:1:Para.numROI
        [coorX, coorY] = ginput();
        logicSeg = logicSeg + roipoly(ones(dim1, dim2), coorX, coorY);
    end
    logicSeg = logicSeg >= 1;
    
    imgSegAir = img .* logicSeg;
    imgSegLayer(:,:,2) = imgSegAir;
    tempFolder = pwd; cd(Para.miscPath); save imgSegLayer imgSegLayer; cd(tempFolder);
end

if(strcmp(Para.method, 'read'))
    disp('The segmentation is done in previous action');
    load imgSegLayer
end



end

