function [sino, Nproj] = sino_generate(sourceDir, Para, numSkip)
% Temp
truncate = 0;
if(nargin == 2)
    numSkip = 1;
end
% Now

sino = [];
Nproj = 0;
detectorSizeOrigin = Para.detectorSize * Para.dsProj;
for i = 1 : numSkip : size(Para.ang, 2) * numSkip
    if(Para.verBose && mod(i, 20) == 0)
        disp(strcat('Projection ',num2str(i - 1),'.................'));   
    end
    fid = fopen(strcat(sourceDir, num2str(i - 1, '%05d'), '.raw'), 'r');
    [proj, ~] = fread(fid, detectorSizeOrigin, 'float32');
    fclose(fid);
    proj = proj(:, round(detectorSizeOrigin(2)/4) + 6);
    proj = proj(truncate + 1 : end - truncate);
    proj = downsample(proj, Para.dsProj);
    proj = proj(1 + Para.Pixel_edge : end);
    sino = [sino; proj]; Nproj = Nproj + 1; %#ok<AGROW> 
    % output is over    
end;
sino = flipud(sino);
sino = reshape(sino, Para.detectorSize(1), []);
sino = fliplr(sino);