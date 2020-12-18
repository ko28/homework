function line_detected_img = lineFinder(orig_img, hough_img, hough_threshold)
    fh1 = figure(); % Open a new figure and get its handle
    
    imshow(orig_img); % Can't quite see the labeled image...
    line_detected_img = orig_img;
    
    rho_step = 2 * hypot(size(orig_img, 1), size(orig_img, 2))/size(hough_img, 1);


    for rho_index = 1:size(hough_img , 1)
        for theta_index = 1:size(hough_img , 2)
            if hough_img(rho_index,theta_index) >= hough_threshold
                rho = rho_step*(rho_index - size(hough_img, 1)/2);
                theta = theta_index * (pi/size(hough_img, 2));
                %info      rho = x*cos(theta) + y*sin(theta);             
                x_1 = 0;
                y_1 = -x_1*cos(theta)/sin(theta) + rho/sin(theta);
                x_2 = size(orig_img, 1)-1;
                y_2 = -x_2*cos(theta)/sin(theta) + rho/sin(theta);
                line([y_1, y_2], [x_1, x_2], 'LineWidth', 1, 'Color', [0, 1, 0]);              
            end
        end
    end
end


    
    

