function [imgTemplate, imgLogic] = imgSegmentation(img, ParaSeg)
dim1 = size(img, 1); dim2 = size(img, 2); dim3 = size(img, 3);
boo1D = 0;
softPadding = 0.021;
% Hard coding exists in BM3D
if(dim2 == 1)    % only one dimension
    dim1 =sqrt(length(img));    
    img = reshape(img, dim1, []);     % back to the 2-D image
    dim2 = size(img, 2);    boo1D = 1;
end
imgLogic = zeros(dim1, dim2, 1);
if(ParaSeg.booDenoise)
    img = BM3D4MID(img, 'bin', 1, 1.5);
end

if(strcmp(ParaSeg.method, 'smooth')) 
    if(~ParaSeg.booDenoise)
        error('You can not use the smooth method with booDenoise = 0');
    else
        imgTemplate = img;
        imgLogic = zeros(size(img));
    end
end

if(strcmp(ParaSeg.method, 'threshold_1')) 
    logicAir = img <= ParaSeg.numThreshold(1);
    logicBone = img >= ParaSeg.numThreshold(2);
    logicSoft = ones(dim1, dim2) - logicAir - logicBone;
    imgTemplate = logicAir .* img + logicBone .* img + logicSoft .* (softPadding * ones(dim1, dim2));
    imgLogic(:,:,1) = logicAir; imgLogic(:,:,2) = logicSoft; imgLogic(:,:,3) = logicBone;     
end

if(strcmp(ParaSeg.method, 'load')) 
    load imgTemplateLoad
    imgTemplate = imgTemplateLoad;
end

if(boo1D)
    imgTemplate = imgTemplate(:);
end

    
