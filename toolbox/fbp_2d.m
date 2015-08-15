function img = fbp_2d(sino, Para)

%     Example parameter set
%     ParaSiddon = struct('SID', 1500, 'SAD', 1000, 'CRD', [0, 0], 'imgSize', ...
%         imgSize, 'detectorSize', detectorSize, 'psize', 0.388, 'vsize', 0.5, ...
%         'dsProj', dsProj, 'dsImg', dsImg, 'COR', [0, 0, 0], 'Pixel_edge', 0, 'ang', ang, ...
%         'verBose', 1, 'figureBose', 0); 
%     ParaFBP = ParaSiddon; ParaFBP.shiftC = 0; 

    % sino should be reshaped
	if(~exist('Para', 'var'))
		imgSize = [512, 512, 1]; NV = imgSize;
		detectorSize = [1024, 1]; ND = detectorSize;
		psize = 0.388; vsize = 0.5;
		SID = 1500; SAD = 1000;
		ang = linspace(0, 2*pi, 720);
		verBose = 1;
		figureBose = 1;
        shiftC = 0; shift_c = shiftC;
    else	
	imgSize = Para.imgSize; 
    if(imgSize(3) == 1)
        imgSize(1:2) = imgSize(1:2) / Para.dsImg;
    else
        imgSize = imgSize ./ Para.dsImg; 
    end
    NV = imgSize;
	detectorSize = Para.detectorSize; 
    if(detectorSize(2) == 1)
        detectorSize(1) = detectorSize(1) / Para.dsProj;
    else
        detectorSize = detectorSize ./ Para.dsProj;
    end
    ND = detectorSize;
    NDPart = ND(1);
	psize = Para.psize .* Para.dsProj;
    vsize = Para.vsize .* Para.dsImg;
	SID = Para.SID; SAD = Para.SAD;
	ang = Para.ang;
	verBose = Para.verBose; figureBose = Para.figureBose;
    shiftC = Para.shiftC; shift_c = shiftC;
    end

	img = fanBeamRecon_shortscan_abocs(SID, SAD, vsize, vsize, NV, sino, psize, NDPart, shift_c, ang)' / 2;
	if(verBose)
		disp('Back Projection Completes');
	end
	if(figureBose)
		figure, imshow(img, []);
	end
end