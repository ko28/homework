function cropped = bbox_crop(img)
%BBOX_CROP	Remove border rows and columns which are all zeros
	if size(img, 3) == 1
		gray_img = img;
	else
	    gray_img = rgb2gray(img);
	end
    [rows_nz, cols_nz] = find(gray_img ~= 0);
    cropped = img(min(rows_nz):max(rows_nz), min(cols_nz):max(cols_nz),:);
end