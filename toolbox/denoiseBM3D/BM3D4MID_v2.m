function y_est = BM3D4MID(data, sigma, adjust_en)
% BM3D4MID(data, sigma, adjust_en)
%   This function is used to denoise based on BM3D.
%   Attention:  Data should be or be preprocessed to raw data !!!!!!
%                   dicom2raw()
%               Toolbox shoulbe add to path using "addpath(genpath(___))"
%   data:   raw data
%   sigma:  (optional) 'default'    0.6 for raw data (.bin)
%                                   10 for normal image (.jpg/.bmp/...)
%                                   40 for dicom (.dcm) (needs to be improved)
%                       threshold for BM3D
%   adjust_en:  (optional) adjust or not(0(default)/1)
%% Initialization
if(exist('sigma') ~= 1)
    sigma = 0.6;
end
if(exist('adjust_en') ~= 1)
    adjust_en = 0;
end
%% Denoise
[~, y_est] = BM3D(1, data, sigma);
%% Adjustment
if(adjust_en)
    data_max = max(max(data));
    data_min = min(min(data));
    est_max = max(max(y_est));
    est_min = min(min(data));
    y_est = (y_est - est_min) * (data_max - data_min) / (est_max - est_min) + data_min;
end
end