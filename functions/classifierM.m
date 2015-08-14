
function [boolInju] = classifierM(grayImg)    

    imgTemp = grayImg(:);         % transform the 2D matrix to 1D 
    idx = find(imgTemp<200);  
    img1d = double(imgTemp(idx));      % remove the white part pixel around the brain
    img1dstr =double(img1d-min(img1d))/double(max(img1d)-min(img1d))*255;
 %% Mahalanobi distance 

    miu= mean(img1dstr);
 %    imgOD=img1dstr-miu;

    sigma=std(img1dstr);
    imgMD=(img1dstr-miu)/sigma;

    maxim=max(imgMD);
    if (maxim>4.5)
        boolInju=1;
    else
        boolInju=0;
    end

end