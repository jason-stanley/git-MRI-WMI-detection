function [sino, M] = siddon_2d(img, Para)

%     Example parameter set

%     ParaSiddon = struct('SID', 1500, 'SAD', 1000, 'CRD', [0, 0], 'imgSize', ...
%         imgSize, 'detectorSize', detectorSize, 'psize', 0.388, 'vsize', 0.5, ...
%         'dsProj', dsProj, 'dsImg', dsImg, 'COR', [0, 0, 0], 'Pixel_edge', 0, 'ang', ang, ...
%         'verBose', 1, 'figureBose', 0); 


	if(~exist('Para', 'var'))
		imgSize = [512, 512, 1]; NV = imgSize;
		detectorSize = [1024, 1]; ND = detectorSize;
		psize = 0.388; vsize = 0.5; % Should also be down sampled (*)
		SID = 1500; SAD = 1000;
		CRD_Y = 0; CRD_Z = 0; CRD = [CRD_Y CRD_Z]; 
		ang = linspace(0, 2*pi, 720);
		COR = [0 0 0];
		Pixel_edge = 0;
		verBose = 1;
		figureBose = 1;
    else	
	imgSize = Para.imgSize; 
    if(imgSize(3) == 1)
        imgSize(1:2) = imgSize(1:2) / Para.dsImg;
    else
        imgSize = imgSize ./ Para.dsImg; 
        disp('Image size is not two dimensional. Is this okay?');
    end
    NV = imgSize;
	detectorSize = Para.detectorSize; 
    if(detectorSize(2) == 1)
        detectorSize(1) = detectorSize(1) / Para.dsProj;
    else
        detectorSize = detectorSize ./ Para.dsProj;
        disp('Detector size is not two dimensional. Is this okay?');
    end
    ND = detectorSize;
	psize = Para.psize .* Para.dsProj;
    vsize = Para.vsize .* Para.dsImg;
	SID = Para.SID; SAD = Para.SAD;
	CRD = Para.CRD;
	ang = Para.ang;
	COR = Para.COR;
	Pixel_edge = Para.Pixel_edge;
	verBose = Para.verBose; figureBose = Para.figureBose;
    end

	[M, ~] = getMatrix_halfFan_abocs(NV, vsize, ND, psize, SID, SAD, COR, CRD, Pixel_edge, ang);
	sino = M * img(:); % No dot (not .*)
	sino = reshape(sino, ND(1), []);
	if(verBose)
		disp('Forward Projection Completes');
	end
	if(figureBose)
		figure, imshow(sino, []);
	end
end