function [proj, count] = getMatrix_halfFan(img, NV, vsize, ND, psize, Nproj, Truncate, SID, SAD, COR, CRD, start_ang, Skip_num, Pixel_edge)
N_voxel_x = NV;%num of voxels of one dimension
N_voxel_y = NV;%num of voxels of one dimension
N_voxel_z = 1;%num of voxels of one dimension

dx = vsize;
dy = vsize;
dz = vsize;

N_det_z = 1; %num of detectors on one line, so the total num should be N_det*N_det
N_det_y = ND;

dy_det = psize;
dz_det = psize;

delta_theta = deg2rad(360/Nproj);

proj = [];
count = 0;
for i_theta = 1: Skip_num: Nproj
    
    proj = [proj forwardProj_matrix(img, i_theta, delta_theta, start_ang, N_det_y, N_det_z, [N_voxel_x, N_voxel_y, N_voxel_z], ...
        SID, SAD, dx, dy, dz, dy_det, dz_det, COR, CRD, Pixel_edge)]; 
    count = count+1;
end;