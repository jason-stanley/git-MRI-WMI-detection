% ReadMultipleFiles: 
% This function is used to read multiple inputted files and convert them to a single .raw file for future observation.

% Input:  	  dpath >>> the directory path.
% 		  	  fileNumber >>> number of inputted files.
% 			  inputsize >>> a matrix containing the size of the inputted files. such as [512 512] (default) or [1024 768]
%             inputformat >>> The postfix of the inputted files. The default number is 'raw'

% Output: 	  convertedRaw >>> The converted raw file.

% Author:	  Pengwei Wu
%		  	  Undergraduate student from Zhejiang University.

% Assumption: All raw files in that directory are stored in the name format %d.
% 			  starting from 1 to fileNumber.
%  			  The postfix of each files shall be given.
% 			  The size of each files are identical and be given.
function convertedRaw = readmultifiles(dpath,fileNumber,inputsize,inputformat)

	if (nargin < 4); inputformat = 'raw'; end
	if (nargin < 3); inputsize = [512 512]; end

	
	numberone = inputsize(1);
	numbertwo = inputsize(2);

	convertedRaw = zeros(numberone ,numbertwo, fileNumber);

	if (strcmp(inputformat, 'raw'))

		for i = 1:fileNumber
			fileName = strcat(num2str(i), '.raw');
			fid = fopen(strcat(dpath,fileName), 'rb', 'ieee-le');
			[singleRaw, ~] = fread(fid, inf, 'float32');
			fclose(fid);
			singleRaw = reshape(singleRaw, numberone, numbertwo);
			convertedRaw(:, :, i) = singleRaw;
		end

	elseif (strcmp(inputformat, 'dcm'))

		for i = 1:fileNumber
			fileName = strcat(num2str(i), '.dcm');
			fileNameTrue = strcat(dpath,fileName);
			singleDicom = dicomread(fileNameTrue);
			convertedRaw(:, :, i) = singleDicom;
		end
		
	else

		error('I do not know the format');
		
end
