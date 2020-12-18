function hough_img = generateHoughAccumulator(img, theta_num_bins, rho_num_bins)
    theta_step = pi/theta_num_bins;
    rho_step = 2 * hypot(size(img, 1), size(img, 2))/rho_num_bins; 
    
    accumulator = zeros(rho_num_bins, theta_num_bins);
    %generate accumulator
    for x = 1:size(img, 1)
        for y = 1:size(img, 2)
            if img(x,y) ~= 0 
                for theta_index = 1:theta_num_bins
                    theta = theta_step * theta_index;
                    rho = x*cos(theta) + y*sin(theta);
                    rho_index = round(rho/rho_step + rho_num_bins/2);
                    accumulator(rho_index, theta_index) = accumulator(rho_index, theta_index) + 1;
                end
            end
        end
    end

    %scale accumulator
    hough_img = rescale(accumulator, 0, 255);
end