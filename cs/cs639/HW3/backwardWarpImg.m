function [mask, result_img] = backwardWarpImg(src_img, resultToSrc_H,...
                                              dest_canvas_width_height)
    src_height = size(src_img, 1);
	src_width = size(src_img, 2);
    src_channels = size(src_img, 3);
    dest_width = dest_canvas_width_height(1);
	dest_height	= dest_canvas_width_height(2);
    
    result_img = zeros(dest_height, dest_width, src_channels);
    mask = false(dest_height, dest_width);
    
    % this is the overall region covered by result_img
    [dest_X, dest_Y] = meshgrid(1:dest_width, 1:dest_height);
    
    % map result_img region to src_img coordinate system using the given
    % homography.
    src_pts = applyHomography(resultToSrc_H, [dest_X(:), dest_Y(:)]);
    src_X = reshape(src_pts(:,1), dest_height, dest_width);
    src_Y = reshape(src_pts(:,2), dest_height, dest_width);
    
    % ---------------------------
    % START ADDING YOUR CODE HERE
    % ---------------------------
    red = interp2(1:src_width, 1:src_height, src_img(:,:,1), src_X ,src_Y);
    green = interp2(1:src_width, 1:src_height, src_img(:,:,2), src_X ,src_Y);
    blue = interp2(1:src_width, 1:src_height, src_img(:,:,3), src_X ,src_Y);
    
    % fill the right region in 'result_img' with the src_img
    result_img(:, :, 1) = red;
    result_img(:, :, 2) = green;
    result_img(:, :, 3) = blue;
    result_img(isnan(result_img)) = 0;
    %imshow(result_img);
    
    % generate mask
    for r = 1:dest_height
        for c = 1:dest_width
            if sum(result_img(r,c,:)) ~= 0
                mask(r,c) = 1;
            end
        end
    end
    % ---------------------------
    % END YOUR CODE HERE    
    % ---------------------------
       
end
