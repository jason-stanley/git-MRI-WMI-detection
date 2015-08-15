function [sagi1 sagi2] = calcsagittal(img, sagiCoor1, sagiCoor2, scaleFactor)

sagi1 = zeros(size(img, 3),size(img, 2));
sagi2 = zeros(size(img, 3),size(img, 1));

for i = 1:1:size(img, 3)
	sagi1(i,1:size(img, 2)) = img(sagiCoor1, :, i);
	sagi2(i,1:size(img, 1)) = img(:, sagiCoor2, i);
end

sagi1=imresize(sagi1,[scaleFactor * size(sagi1,1),size(sagi1,2)],'bicubic');
sagi2=imresize(sagi2,[scaleFactor * size(sagi2,1),size(sagi2,2)],'bicubic');

end
