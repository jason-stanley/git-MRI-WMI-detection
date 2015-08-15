function y_est = BM3D4MID(file_path, sigma, adjust_en)
% BM3D4MID(data, file_type, sigma, q)
%   This function is used to denoise based on BM3D.
%   file_path: full path for file (./.../*.*)
%   sigma: (optional) 'default' 0.6 for raw data (.bin)
%                               10 for normal image (.jpg/.bmp/...)
%                               40 for dicom (.dcm) (needs to be improved)
%           threshold for BM3D
%   adjust_en:  (optional) adjust or not (0/1)
%   y_est: [0, 1]
addpath(genpath('./'));
%% type extraction
if(ischar(file_path))
    file_type = file_path(length(file_path) - 2: length(file_path));
end
fid = fopen(file_path, 'r');
if(fid == -1)
    error(message(MATLAB:FileIO:InvalidFid));
end
fclose(fid);
switch file_type
    case 'dcm'
        data = dicomread(file_path);
    case 'bin'
        fid = fopen(file_path, 'r');
        data = fread(fid, 'float32');
        fclose(fid);
        data = reshape(data, [512, 512, length(data) / 512 / 512]);
    otherwise
        try
            data = imread(file_path);
        catch ME
            msg = ME.message
            error(msg);
        end
end
%% Initialization
if(exist('sigma') ~= 1)
    switch file_type
        case 'dcm'
            sigma = 40;
        case 'bin'
            sigma = 0.6;
        otherwise
            sigma = 10;
    end
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

