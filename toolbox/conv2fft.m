function imgConv = conv2fft(img, kernel, numPadding)
if(nargin == 2)
    numPadding = 1024;
end
kSize1 = size(kernel, 1); kSize2 = size(kernel, 2);
iSize1 = size(img, 1); iSize2 = size(img, 2);
img(numPadding, numPadding) = 0;
kernel(numPadding, numPadding) = 0;
temp = abs(ifft2(fft2(img) .* fft2(kernel)));
imgConv = temp(floor(kSize1/2 + 1):floor(kSize1/2) + iSize1, floor(kSize2/2 + 1):floor(kSize2/2) + iSize2);

end
