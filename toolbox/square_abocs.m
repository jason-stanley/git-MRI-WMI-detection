function imgOut = square_abocs(img)

x = uint32(sqrt(size(img, 1)));
imgOut = reshape(img, x, []);

end