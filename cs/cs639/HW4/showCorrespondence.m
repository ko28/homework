function result_img = ...
    showCorrespondence(orig_img, warped_img, src_pts_nx2, dest_pts_nx2)
    n = size(src_pts_nx2);
    
    [Hs, Ws, ~] = size(orig_img);
    [Hd, Wd, ~] = size(warped_img);
    
    middle_space = 10;
    H = max(Hs, Hd);
    W = Ws + middle_space + Wd;
    result_img = uint8(zeros(H, W, size(orig_img, 3)));
    
    offset_s = [0, floor((H - Hs) / 2)];
    offset_d = [Ws + Wd, floor((H - Hd) / 2)];

    result_img(offset_s(2)+1:offset_s(2)+Hs, offset_s(1)+1:offset_s(1)+Ws,:) = orig_img;
    result_img(offset_d(2)+1:offset_d(2)+Hd, offset_d(1)+1:offset_d(1)+Wd,:) = warped_img;
    fig = figure;
    imshow(result_img);
    for i = 1:n
        xs = offset_s(1) + src_pts_nx2(i, 1);
        ys = offset_s(2) + src_pts_nx2(i, 2);
        xd = offset_d(1) + dest_pts_nx2(i, 1);
        yd = offset_d(2) + dest_pts_nx2(i, 2);
        hold on;
        line([xs xd], [ys, yd], 'LineWidth', 3);
    end
    result_img = saveAnnotatedImg(fig);
end
