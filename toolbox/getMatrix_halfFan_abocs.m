function [M, count] = getMatrix_halfFan_abocs(NV, vsize, ND, psize, SID, SAD, COR, CRD, Pixel_edge, ang)

% 2D version only 

N_voxel_x = NV(1); % num of voxels of one dimension (image domain)
N_voxel_y = NV(2); % num of voxels of one dimension (image domain)
N_voxel_z = NV(3);  % num of voxels of one dimension (image domain)

dx = vsize; % 0.5 or things like that -- Physical size of voxel
dy = vsize; % 0.5 or things like that -- Physical size of voxel
dz = vsize; % 0.5 or things like that -- Physical size of voxel

N_det_z = ND(2); % num of detectors on one line, so the total num should be N_det * N_det
N_det_y = ND(1); % num of pixels in the projection domain

dy_det = psize; % Physical size of detector
dz_det = psize; % Physical size of detector

M = [];
count = 0;
for i_theta = ang   %1: Skip_num: Nproj
    

% disp(['Angle ', num2str(i_theta), ' .................']);
% Turn it on if you want to know the speed

    
    M = [M; forwardProj_matrix(i_theta, N_det_y, N_det_z, [N_voxel_x, N_voxel_y, N_voxel_z], ...
        SID, SAD, dx, dy, dz, dy_det, dz_det, COR, CRD, Pixel_edge)]; 
    count = count+1;
    
end;