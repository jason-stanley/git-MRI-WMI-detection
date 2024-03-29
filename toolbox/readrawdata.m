function imgRaw = readrawdata(path, infoDimension, type)

% example: readrawdata(d:/test.raw, [512 512])
if (nargin == 2)
    fid = fopen(path, 'rb', 'ieee-le');
    [imgRaw, ~] = fread(fid,inf,'float32');
    fclose(fid);
    imgRaw = reshape(imgRaw, infoDimension(1),infoDimension(2),[]);
elseif (nargin == 3)
    fid = fopen(path, 'rb', 'ieee-le');
    [imgRaw, ~] = fread(fid,inf, type);
    fclose(fid);
    imgRaw = reshape(imgRaw, infoDimension(1),infoDimension(2),[]);

end