function raw_data = dicom2raw( dicom_data, water_flag )
%DICOM2RAW
%   This function is used to transfer dicom to raw data
%   file_path: (string)

dicom_data = double(dicom_data);
if(water_flag)
    raw_data = ((dicom_data - 1000) / 1000 + 1) * 0.021;
else
    raw_data = (dicom_data / 1000 + 1) * 0.021;
end

end

