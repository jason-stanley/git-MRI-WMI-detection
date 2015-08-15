function imgHU = converttohu(imgRaw)

valMax = max(max(max(imgRaw)));
dim1 = size(imgRaw,1);
dim2 = size(imgRaw,2);
dim3 = size(imgRaw,3);
if (valMax > 1)
	disp('This image is in HU format already');
	imgHU = imgRaw;
else
	for i = 1:1:dim1
		for j = 1:1:dim2
			for loopK = 1:1:dim3
				imgHU(i,j,loopK) = (imgRaw(i,j,loopK)-0.02)/0.02*1000+1000;
			end
		end
	end
end

end

