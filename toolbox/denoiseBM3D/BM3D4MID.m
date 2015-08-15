function y_est = BM3D4MID(data, file_type, adjust_en, sigma)
% BM3D4MID(data, file_type, sigma, adjust_en)
%   This function is used to denoise based on BM3D.
%   Attention:  Data should be or be preprocessed to raw data !!!!!!
%                   dicom2raw()
%               Toolbox shoulbe add to path using "addpath(genpath(___))"
%   data:   raw data
%   file_type:  file extension name eg: 'dcm'
%   sigma:  (optional) 'default'    0.6 for raw data (.bin)
%                                   10 for normal image (.jpg/.bmp/...)
%                                   40 for dicom (.dcm) (needs to be improved)
%                       threshold for BM3D
%   adjust_en:  (optional) adjust or not(0(default)/1)
%% Initialization
if(exist('sigma') ~= 1)
    switch file_type
        case 'dcm'
            sigma = 40;
        case 'ima'
            sigma = 40;
        case 'bin'
            sigma = 0.6;
        case 'raw'
            sigma = 0.6;
        otherwise
            sigma = 10;
    end
end
if(exist('adjust_en') ~= 1)
    adjust_en = 0;
end
%% Denoise
data = double(data);
data_max = max(max(data));
data_min = min(min(data));
if(strcmp(file_type, 'dcm') || strcmp(file_type, 'ima'))
    data = double(data) * 255 / data_max;
end
[~, y_est] = BM3D(1, data, sigma);
%% Adjustment
if(adjust_en)
    est_max = max(max(y_est));
    est_min = min(min(y_est));
    y_est = (y_est - est_min) * (data_max - data_min) / (est_max - est_min) + data_min;
end
end