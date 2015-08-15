function [] = reconstruction3d(Parameter)



% GPU based reconstruction
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

sourceFDKPath = strcat(Parameter.sourceFDKDir, '%d.raw');
targetFDKPath = Parameter.targetFDKPath;

targetFDKPath = [targetFDKPath, '  ', '# FBP FILE'];
sourceFDKPath = [sourceFDKPath, '  ', '# PROJECTION IMAGE FILES'];	
xI0Path = [Parameter.xI0Path, '  ', '#FLAT FIELD INTENSITY'];	

if (Parameter.nameFDK == -1)
	nameFDK = '/home/tyniu/Data/pwwu/temp/temp_FDK.in'
else
	nameFDK = Parameter.nameFDK;
end

if (verBose == 1)
	disp('We are now generating .in file');
	toc
end

% Now the FDK file
matrixFDK{1,1}  = '# >>>> INPUT FILE FOR gFDK >>>>';
matrixFDK{1,2}  = ' ';
matrixFDK{1,3}  = 'gFDK v.1.0 : half-fan geometry, FFT for ramp filtering';
matrixFDK{1,4}  = ' ';
matrixFDK{1,5}  = '#[SECTION GPU CONFIG v.2013-06-07]';
matrixFDK{1,6}  = '0                               # GPU NUMBER TO USE';
matrixFDK{1,7}  = '512                              # GPU THREADS PER CUDA BLOCK (multiple of 32)';
matrixFDK{1,8}  = '32768                           # the leading dimension of the 2d thread grid';
matrixFDK{1,9}  = ' ';
matrixFDK{1,10} = '#[SECTION SOURCE v.2013-06-07]';
matrixFDK{1,11} = '0.0 0.0  0.0                     # SOURCE OFFSET: X Y Z [mm] (optional)';

matrixFDK{1,12} = ' ';
matrixFDK{1,13} = '#[SECTION DETECTOR   v.2013-06-07]';
matrixFDK{1,14} = projResolutionAndSliceNumber;
matrixFDK{1,15} = '0.388   0.388                    # PIXEL SIZE ON THE IMAGER (width, height): PIXSIZE_XY PIXSIZE_Z [mm]';
matrixFDK{1,16} = '1500.0                           # SOURCE-TO-DETECTOR DISTANCE: SID [mm]';
matrixFDK{1,17} = '1000.0                           # SOURCE-TO-AXIS DISTANCE: SAD [mm]';
matrixFDK{1,18} = '160.0		    # SHIFTED DETECTOR DISTANCE: CRD_Y [mm]';
matrixFDK{1,19} = num2str(Parameter.bProjOrLine);
matrixFDK{1,20} = '0				# PWLS: 1 -- on; 0 -- off. Note: on windows it should be always off';
matrixFDK{1,21} = '0				# PROJECTION FLIP: 1 -- fliped; 0 -- no change';
matrixFDK{1,22} = sourceFDKPath;
matrixFDK{1,23} = xI0Path;

matrixFDK{1,24} = ' ';
matrixFDK{1,25} = '#[SECTION CT SCAN    v.2013-06-07]';
matrixFDK{1,26} = '0	   1			                                       # ASCENDING OF PROJECTION NUMBER: FILEINI FILEINC';
matrixFDK{1,27} = '32';
matrixFDK{1,28} = resolutionAndSliceNumber;

matrixFDK{1,29} = '0.9082	    0.9938		                                   # VOXEL SIZE OF CT: VOXSIZE_XY VOXSIZE_Z [mm]';
matrixFDK{1,30} = '1.0				                                           # CROP FREQUENCY FOR RAMP FILTER, NORMALIZED';

matrixFDK{1,31} = [Parameter.angularPath, '  ', '# ANGULAR FILE'];
matrixFDK{1,32} = targetFDKPath;

matrixFDK{1,33} = ' ';
matrixFDK{1,34} = '#[SECTION SECTION DENOISE v.2013-06-07]';
matrixFDK{1,35} = '300	   150		        # HORIZONTAL AND VERTICAL WEIGHT';
matrixFDK{1,36} = '1.0e-6     0.12			# stopping metric to terminate the GS itertion; controls the strength of edge';
matrixFDK{1,37} = '20				        # define the maximum number of itertions in GS iteration';
matrixFDK{1,38} = ' ';
matrixFDK{1,39} = '# >>>> END INPUT FILE >>>>';

% Now we begin the file generation process
fid1 = fopen(nameFDK, 'w');

for loopLine = 1:size(matrixFDK, 2)
	fprintf(fid1,'%s',matrixFDK{1, loopLine});
	fprintf(fid1,'\r\n');
end

pause(1);

fclose(fid1);

tempNowFolder = pwd;
cd '/home/tyniu/code/gpu/gFDK_fft_halffan/'
if (verBose == 1)
    disp('Now FDK begins');
    toc
end
if(gpuBose == 1)
    system('./bashwpw4')
else
    [status1,results1]=system('./bashwpw4');
end
if (verBose == 1)
    disp('FDK is completed')
    toc
end
% Back to the original folder
cd (tempNowFolder);
