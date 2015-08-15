function img = reconstruction2d(sino)


%--------------------------------------------------------------------------
% Parameter for projection and reconstruction
%--------------------------------------------------------------------------
Nproj = 720; % total number of projections
DetectorSize = [1024 1]; % Y-by-Z
SID = 1500; SAD = 1000;
CRD_Y = 0; CRD_Z = 0; %#ok<*NASGU>
Skip_num = 1;   % skipping number between two adjacent projections
ND = DetectorSize(1);%projection size
psize = 0.388;% detector pixel size
img_size = [512, 512];
vsize = 0.5; % recon pixel size
start_ang = 0; 
ang = 0:-2*pi/(Nproj/Skip_num):-2*pi; ang(end) = [];
step = 1e-2;
ng = 50; inc_ng = 1.03;
COR = [0 0 0];
ds_proj = 1;   % down sampling for projection
% If we use this (ds_proj = 1), then a complete matrix is formed
scale = 1; % control the intensity outside of the object
mod_num = 2;
alpha = 1;
span = 0.8;
N_total = 20;
CT0 = 0.021;
parkerWeighting = 0;
Truncate = 0;
Pixel_edge = 0;

img = fanBeamRecon_shortscan(SID,SAD,vsize,vsize,img_size,sino,psize,ND,0,ang,Skip_num,parkerWeighting);
