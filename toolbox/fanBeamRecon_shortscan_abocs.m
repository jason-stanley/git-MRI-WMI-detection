function img = fanBeamRecon_shortscan_abocs(SID,SAD,dx,dy,ReconSize,sino,py,DetectorSize,shift_c,ang)

% This is a script for a fanbeam reconstruction; an equalily spaced flat 
% detector is used.

% Input:

% SID: distance from the source to the detector;
% SAD: distance from the source to the iso-center;
% dx,dy: reconstruction resolution in x and y directions;
% ReconSize: reconstruction size in pixels (2D vector);
% sino: input sinogram file;
% pos: positions along the detector, with 0 right at the center; 
%      same format as the output variable of radon.m;
% shift_c: shift of the rotation center on the projection; be careful about
%          the sign of this value;
% ang: angle in rad for different projections;

% Output:

% img: reconstructed image.

% Written by: Lei Zhu, Ph.D., Stanford University (copyright reserved, May 1, 2007)
% Modified by: Tianye Niu, Ph.D., Georgia Institute of Technology (copyright reserved, May 1, 2012)

parkerWeighting = 0;
Num_of_proj = length(ang)-1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Prepare the variable;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

delta_Y = py;
Y = 1:DetectorSize;
Y = Y*delta_Y;
Y = Y-(Y(1)+Y(end))/2-shift_c;

weight = SID./sqrt(Y.^2+SID^2);

x = 1:ReconSize(1);
x = x*dx;
x = x-(x(1)+x(end))/2;

y = 1:ReconSize(2);
y = y*dy;
y = y-(y(1)+y(end))/2;

img = zeros(ReconSize);
img_temp = img;

len = DetectorSize;

H = SAD/SID*delta_Y*designFilter2(delta_Y,'hamming',len,0.3)';

if parkerWeighting;
    D = sqrt(SID^2);
    alpha = sign(ang(2,1)-ang(1,1))*atan(Y./D);
    delta = atan((max(Y)+delta_Y/2)./D);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reconstruct projection by projection;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
totalWeight = weight;
param = rad2deg(ang);
for i = 1:Num_of_proj;

    if mod(i,20)==0;
        disp(strcat('Projection ',num2str(i),'.................'));
    end
    
    proj = sino(:,i)';    
    proj = totalWeight.*proj;   
    
    % filtering
    p_dummy = proj;
    p_dummy(length(H)) = 0;
    p_f = (fft(p_dummy));    % p_f holds fft of projections
    p_f = p_f.*H;

    p_dummy = real(ifft(p_f));
    p_dummy(len+1:end) = [];        % truncate
    proj = p_dummy;

    % backprojection

    phi = ang(i);

    xx_step = dx*cos(phi);
    xy_step = dy*sin(phi);
    yx_step = -dx*sin(phi);
    yy_step = dy*cos(phi);

    x_temp_0 = x(1)*cos(phi)+y(1)*sin(phi);
    y_temp_0 = -x(1)*sin(phi)+y(1)*cos(phi);
    for u = 1:length(x);
        x_temp = x_temp_0;
        y_temp = y_temp_0;
        for v = 1:length(y);
            magni = SID/(x_temp+SAD);

            Yp = y_temp*magni;

            Yinx = ceil((Yp-Y(1,1))/delta_Y);

            if Yinx>0 & Yinx<DetectorSize %#ok<AND2>

                wb = (Y(Yinx+1)-Yp)/delta_Y;
                w_1 = wb;
                w_2 = (1-wb);

                img_temp(u,v) = magni^2*(w_1*proj(Yinx)+w_2*proj(Yinx+1));

            else
                img_temp(u,v) = 0;
            end
            x_temp = x_temp+xy_step;
            y_temp = y_temp+yy_step;
        end
        x_temp_0 = x_temp_0+xx_step;
        y_temp_0 = y_temp_0+yx_step;
    end

    delta_phi = abs(param(i+1)-param(i))*pi/180;
    img_temp = delta_phi*img_temp;
    img = img+img_temp;

end



