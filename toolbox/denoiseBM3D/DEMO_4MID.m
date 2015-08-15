%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a demo for medical image denoise based on BM3D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all

resolution_dim1 = 512;
resolution_dim2 = 512;
test_number = 7;
figureresult_ornot = 1;

fid = fopen('f:/data/fudan_streakarti/406292_CBCT_raw.bin', 'r');
data = fread(fid, inf, 'float32');

fclose(fid);
disp('Data loaded');

data = reshape(data, resolution_dim1, resolution_dim2, []);
data_correct = data;
for loopslice = 7
	dispfirst = 'We are now processing on image number :';
	dispsecond = strcat(dispfirst, num2str(loopslice));
	disp(dispsecond);
	data_correct_single = BM3D4MID(data(:,:,loopslice), 'bin', 1, 0.3);
	data_correct(:,:,loopslice) = data_correct_single;
end

fid = fopen('f:/data/fudan_streakarti/406292_CBCT_raw_denoise_BM3D.raw', 'wb');
fwrite(fid, data_correct, 'float32');

if (figureresult_ornot == 1)
	figure();
	subplot(1,2,1), imshow(data(:,:,test_number), [0.01 0.02]);
	subplot(1,2,2), imshow(data_correct(:,:,test_number), [0.01 0.02]);
end

% [gv,t]=edge(bin_de,'sobel',0.0001,'horizontal');
% figure, imshow(gv,[]);
