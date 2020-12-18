function dest_pts_nx2 = applyHomography(H_3x3, src_pts_nx2)
    n = size(src_pts_nx2, 1);
    src_pts_nx3 = [src_pts_nx2, ones(n, 1)];
    dest_pts_nx3 = (H_3x3 * src_pts_nx3')';
    dest_pts_nx2 = dest_pts_nx3(:,1:2) ./ repmat(dest_pts_nx3(:,3), 1, 2);
end