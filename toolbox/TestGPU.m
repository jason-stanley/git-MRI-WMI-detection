close all

path(path,'/home/tyniu/Lab/BowtieArtifacts/toolbox');
tic

targetSiddonDir = '/home/tyniu/Data/pwwu/temp/'; 
sourceSiddonPath = '/home/tyniu/Data/pwwu/truebeam_pelvis/template_200.raw';
xI0Path= '/home/tyniu/Data/Truebeam/I0.raw'; angularPath = '/home/tyniu/Data/pwwu/circle/raw_lineint/GantryRtnCircleBack.log';

ParameterSiddon = struct('verBose', 1, 'gpuBose', 1, 'resolutionDim', 512, 'projectionDim', [1024 768], ...
	'numProj', 655, 'bProjOrLine', 0, 'numSliceTotal', 200, 'nameSiddon', -1); 
ParameterSiddon.targetSiddonDir = targetSiddonDir; ParameterSiddon.sourceSiddonPath = sourceSiddonPath; ParameterSiddon.xI0Path = xI0Path; ParameterSiddon.angularPath = angularPath;
forwardproj3d(ParameterSiddon);


sourceFDKDir = '/home/tyniu/Data/pwwu/temp/'; 
targetFDKPath = '/home/tyniu/Data/pwwu/truebeam_pelvis/template_200_recon.raw';
ParameterFDk = struct('verBose', 1, 'gpuBose', 1, 'resolutionDim', 512, 'projectionDim', [1024 768], ...
	'numProj', 656, 'bProjOrLine', 0, 'numSliceTotal', 200, 'nameFDK', -1); 
ParameterFDk.sourceFDKDir = sourceFDKDir; ParameterFDk.targetFDKPath = targetFDKPath; ParameterFDk.xI0Path = xI0Path; ParameterFDk.angularPath = angularPath;
reconstruction3d(ParameterFDk);

imgTest = readrawdata(targetFDKPath, [512 512]);
figure(); imshow(imgTest(:,:,90), [0.015 0.025]);

