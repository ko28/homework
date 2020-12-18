function [inliers_id, H] = runRANSAC(Xs, Xd, ransac_n, eps)
%RUNRANSAC
    num_pts = size(Xs, 1);
    pts_id = 1:num_pts;
    inliers_id = [];
    
    for iter = 1:ransac_n
        % ---------------------------
        % START ADDING YOUR CODE HERE
        % ---------------------------
        % generate random indicices and get corresponding vals 
        inds = randperm(num_pts, randi(num_pts,1));
        src = []; dst = [];
        for i = 1:size(inds,2)
            src = [src; Xs(inds(i), :)];
            dst = [dst; Xd(inds(i), :)];
        end
        
        % homography
        H_3x3 = computeHomography(src, dst);
        dest_pts_nx2 = applyHomography(H_3x3,Xs);
        
        % measure model
        id_temp = [];
        for i = 1:num_pts
            A = Xd(i,:);
            B = dest_pts_nx2(i,:);
            % check distance, add point if within alignment error  
            if norm(Xd(i,:) - dest_pts_nx2(i,:)) < eps
                id_temp = [id_temp i];
            end
        end
        
        % update inliers_id if better homography 
        if size(id_temp,2) > size(inliers_id,2)
            inliers_id = id_temp;
            H = H_3x3;
        end

        %
        % ---------------------------
        % END ADDING YOUR CODE HERE
        % ---------------------------
    end    
end
