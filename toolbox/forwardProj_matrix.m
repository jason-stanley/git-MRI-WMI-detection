function M = forwardProj_matrix(i_theta, N_det_y, N_det_z, N_phan, SID, SAD, vx, vy, vz, py, pz, COR, CRD, Pixel_edge)

N_phantom(1:3) = [N_phan(1) N_phan(2) N_phan(3)]+1;

x_temp = ([1:N_phantom(1)]-1)*vx;
x_plane_raw = x_temp-mean(x_temp)+COR(1);
y_temp = ([1:N_phantom(2)]-1)*vy;
y_plane_raw = y_temp-mean(y_temp)+COR(2);
z_temp = ([1:N_phantom(3)]-1)*vz;
z_plane_raw = z_temp-mean(z_temp)+COR(3);

clear x_temp y_temp z_temp;
y_temp = ([1:N_det_y]-1)*py;
y_det_0 = y_temp-mean(y_temp)-CRD(1);
y_det_0 = y_det_0(1:end-Pixel_edge);
z_temp = ([1:N_det_z]-1)*pz;
z_det_0 = z_temp-mean(z_temp)-CRD(2);
x_det_ini = ones([N_det_z (N_det_y-Pixel_edge)])*(-SAD+SID);
[y_det_ini, z_det_ini] = meshgrid(y_det_0, z_det_0);

x_source_ini = -SAD; % x-axis coordinate will remain after rotation
y_source_ini = -0;
z_source_ini = -0;

d12 = sqrt((x_source_ini-x_det_ini(:)).^2+(y_source_ini-y_det_ini(:)).^2+ ...
            (z_source_ini-z_det_ini(:)).^2);
theta=i_theta;
% calculate the coordinates of source and detector elements after
% rotation matrix
rotate_matrix = [cos(theta) -sin(theta) 0; 
    sin(theta) cos(theta) 0; 0 0 1];
cor_source = rotate_matrix*[x_source_ini y_source_ini z_source_ini]';

cor_det = rotate_matrix*[x_det_ini(:), y_det_ini(:), z_det_ini(:)]';

M = [];

for i = 1: (N_det_y-Pixel_edge)*N_det_z
    clear alpha_x alpha_y alpha_z;
    % get alpha values first
    alpha_x(1) = (x_plane_raw(1)-cor_source(1))/(cor_det(1,i)-cor_source(1));
    alpha_x(N_phantom(1)) = (x_plane_raw(N_phantom(1))-cor_source(1))/(cor_det(1,i)-cor_source(1));
    alpha_y(1) = (y_plane_raw(1)-cor_source(2))/(cor_det(2,i)-cor_source(2));
    alpha_y(N_phantom(2)) = (y_plane_raw(N_phantom(2))-cor_source(2))/(cor_det(2,i)-cor_source(2));
    alpha_z(1) = (z_plane_raw(1)-cor_source(3))/(cor_det(3,i)-cor_source(3));
    alpha_z(N_phantom(3)) = (z_plane_raw(N_phantom(3))-cor_source(3))/(cor_det(3,i)-cor_source(3));
    
    % get alpha_max and alpha_min
    alpha_min = max([0, min(alpha_x(1), alpha_x(N_phantom(1))), min(alpha_y(1), alpha_y(N_phantom(2))), ...
        min(alpha_z(1), alpha_z(N_phantom(3)))]);
    alpha_max = min([1, max(alpha_x(1), alpha_x(N_phantom(1))), max(alpha_y(1), alpha_y(N_phantom(2))), ...
        max(alpha_z(1), alpha_z(N_phantom(3)))]);
    if(alpha_min>alpha_max)% if the ray doesn't interact with the array
        M_tmp = sparse ( 1, 1, 0, 1, N_phan(1)*N_phan(2) );
        M = [M; M_tmp];
        continue;
    end;

    % calculate ix_max, ix_min
    [ix_min, ix_max] = getIndexfromAlpha(N_phantom(1), alpha_min, alpha_max, ...
        cor_source(1), cor_det(1,i), x_plane_raw(1), x_plane_raw(N_phantom(1)), vx);
    for j=ix_min:ix_max
        alpha_x(j) = alpha_x(1)+(j-1)*vx/(cor_det(1,i)-cor_source(1));
    end;

    % calculate iy_max, iy_min
    [iy_min, iy_max] = getIndexfromAlpha(N_phantom(2), alpha_min, alpha_max, ...
        cor_source(2), cor_det(2,i), y_plane_raw(1), y_plane_raw(N_phantom(2)), vy);
    for j=iy_min:iy_max
        alpha_y(j) = alpha_y(1)+(j-1)*vy/(cor_det(2,i)-cor_source(2));
    end;

    % calculate iz_max, iz_min
    [iz_min, iz_max] = getIndexfromAlpha(N_phantom(3), alpha_min, alpha_max, ...
        cor_source(3), cor_det(3,i), z_plane_raw(1), z_plane_raw(N_phantom(3)), vz);
    for j=iz_min:iz_max
        alpha_z(j) = alpha_z(1)+(j-1)*vz/(cor_det(3,i)-cor_source(3));
    end;

    % mergy alpha_x alpha_y alpha_z into one set
    clear alpha_merge_raw alpha_merge idx_tmp;
    alpha_merge_raw = sort([alpha_min mergesorted(mergesorted(alpha_x(ix_min:ix_max), ...
        alpha_y(iy_min:iy_max)), alpha_z(iz_min:iz_max)) alpha_max]);
    idx_tmp= diff(alpha_merge_raw)>1e-12;
    alpha_merge = alpha_merge_raw(idx_tmp);

    % calculate alpha_mid
    % identify the density relation, ie. voxel density
    l_voxel = d12(i)*diff(alpha_merge);  

    clear alpha_mid x_idx_phantom y_idx_phantom z_idx_phantom alpha_temp;
    
    alpha_temp=[alpha_merge(1:end-1);alpha_merge(2:end)];
    alpha_mid=mean(alpha_temp);
    x_idx_phantom = floor(1+(cor_source(1)+alpha_mid*(cor_det(1,i)-cor_source(1)) ...
             -x_plane_raw(1))/vx);
    y_idx_phantom = floor(1+(cor_source(2)+alpha_mid*(cor_det(2,i)-cor_source(2)) ...
             -y_plane_raw(1))/vy);
    z_idx_phantom = floor(1+(cor_source(3)+alpha_mid*(cor_det(3,i)-cor_source(3)) ...
             -z_plane_raw(1))/vz);        

    jj = (x_idx_phantom-1)*N_phan(1) + y_idx_phantom;
    ii = ones(1,length(jj));
    M_tmp = sparse ( ii, jj, l_voxel, 1, N_phan(1)*N_phan(2) );
    M = [M; M_tmp];
end;    

return;