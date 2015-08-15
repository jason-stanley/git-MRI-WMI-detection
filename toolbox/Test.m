clear all
close all

path(path, 'd:\code\ZJU\Lab\BowtieArtifacts\every\') 
load imgRaw
tic
sino = forwardproj2d(imgRaw);
toc
imgCorrected = reconstruction2d(sino);
figure, imshow(imgCorrected, [0.015 0.025]);