function [] = forwardproj3d(Parameter)



% GPU based forward projection
% Revised by Pengwei Wu
% Based on the GPU code from Tianye Niu

% Step 1: generating the .in file for the gpu process
% Step 2: activating the gpu process

% Using x: it is not a struct or class 
verBose = Parameter.verBose;
gpuBose = Parameter.gpuBose;
resolutionAndSliceNumber = [num2str(Parameter.resolutionDim), ...
 '	', num2str(Parameter.numSliceTotal)];
projResolutionAndSliceNumber = [num2str(Parameter.projectionDim(1)), ...
 '    ', num2str(Parameter.projectionDim(2))];

targetSiddonPath = strcat(Parameter.targetSiddonDir, '%d.raw');
sourceSiddonPath = Parameter.sourceSiddonPath;

sourceSiddonPath = [sourceSiddonPath, '  ', '# FBP FILE'];
targetSiddonPath = [targetSiddonPath, '  ', '# PROJECTION IMAGE FILES'];	
xI0Path = [Parameter.xI0Path, '  ', '#FLAT FIELD INTENSITY'];	

if (Parameter.nameSiddon == -1)
	nameSiddon = '/home/tyniu/Data/pwwu/temp/temp_siddon.in'
else
	nameSiddon = Parameter.nameSiddon;
end

if (verBose == 1)
	disp('We are now generating .in file');
	toc
end

% Now the siddon file

matrixSiddon{1,1}  = '#[SECTION GPU CONFIG v.2013-06-07]';
matrixSiddon{1,2}  = '0                                # GPU NUMBER TO USE ';
matrixSiddon{1,3}  = '512                              # GPU THREADS PER CUDA BLOCK (multiple of 32)';
matrixSiddon{1,4}  = '32768                            # the leading dimension of the 2d thread grid';
matrixSiddon{1,5}  = ' ';
matrixSiddon{1,6}  = '#[SECTION SOURCE v.2013-06-07]';
matrixSiddon{1,7}  = '0.0 0.0  0.0                     # SOURCE OFFSET: X Y Z [mm] (optional)';

matrixSiddon{1,8}  = ' ';
matrixSiddon{1,9}  = '#[SECTION DETECTOR   v.2013-06-07]';
matrixSiddon{1,10} = projResolutionAndSliceNumber;
matrixSiddon{1,11} = '0.388   0.388                    # PIXEL SIZE ON THE IMAGER (width, height): PIXSIZE_XY PIXSIZE_Z [mm]';
matrixSiddon{1,12} = '1500.0                           # SOURCE-TO-DETECTOR DISTANCE: SID [mm]';
matrixSiddon{1,13} = '1000.0                           # SOURCE-TO-AXIS DISTANCE: SAD [mm]';
matrixSiddon{1,14} = '160.0		    # SHIFTED DETECTOR DISTANCE: CRD_Y [mm]';
matrixSiddon{1,15} = num2str(Parameter.bProjOrLine);
matrixSiddon{1,16} = '0				# PWLS: 1 -- on; 0 -- off. Note: on windows it should be always off';
matrixSiddon{1,17} = '0				# PROJECTION FLIP: 1 -- fliped; 0 -- no change';
matrixSiddon{1,18} = targetSiddonPath;
matrixSiddon{1,19} = xI0Path;

matrixSiddon{1,20} = ' ';
matrixSiddon{1,21} = '#[SECTION CT SCAN    v.2013-06-07]';
matrixSiddon{1,22} = '0	   1			                                       # ASCENDING OF PROJECTION NUMBER: FILEINI FILEINC';
matrixSiddon{1,23} = num2str(Parameter.numProj);
matrixSiddon{1,24} = resolutionAndSliceNumber;

matrixSiddon{1,25} = '0.9082	    0.9938		                                   # VOXEL SIZE OF CT: VOXSIZE_XY VOXSIZE_Z [mm]';
matrixSiddon{1,26} = '1.0				                                           # CROP FREQUENCY FOR RAMP FILTER, NORMALIZED';

matrixSiddon{1,27} = [Parameter.angularPath, '  ', '# FBP FILE'];
matrixSiddon{1,28} = sourceSiddonPath;

matrixSiddon{1,29} = ' ';
matrixSiddon{1,30} = '#[SECTION SECTION DENOISE v.2013-06-07]';
matrixSiddon{1,31} = '300	   150		        # HORIZONTAL AND VERTICAL WEIGHT';
matrixSiddon{1,32} = '1.0e-6     0.12			# stopping metric to terminate the GS itertion; controls the strength of edge';
matrixSiddon{1,33} = '20				        # define the maximum number of itertions in GS iteration';
matrixSiddon{1,34} = ' ';
matrixSiddon{1,35} = '# >>>> END INPUT FILE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>';

% Now we begin the file generation process
fid1 = fopen(nameSiddon, 'w');

for loopLine = 1:size(matrixSiddon, 2)
	fprintf(fid1,'%s',matrixSiddon{1, loopLine});
	fprintf(fid1,'\r\n');
end

fclose(fid1);

tempNowFolder = pwd;
cd '/home/tyniu/code/gpu/DRR_siddon_halffan/'
if (verBose == 1)
    disp('Now siddon begins');
    toc
end
if(gpuBose == 1)
    system(['./DRR_siddon_halffan', ' ', nameSiddon])
else
    [status1,results1]=system(['./DRR_siddon_halffan', ' ', nameSiddon]);
end
if (verBose == 1)
    disp('siddon is completed')
    toc
end
% Back to the original folder
cd (tempNowFolder);
