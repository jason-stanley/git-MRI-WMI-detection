function maskOut = logic_dilate(mask, winSize) 

mask = double(mask);
se = strel('disk', winSize);
mask = imdilate(mask, se);
maskOut = logical(mask);

end
