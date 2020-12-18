function cropped_line_img = lineSegmentFinder(orig_img, hough_img, hough_threshold)
    edge_img = edge(orig_img, 'Sobel', 0.02);
    fh1 = figure(); % Open a new figure and get its handle
    
    imshow(orig_img); % Can't quite see the labeled image...
    cropped_line_img = orig_img;
    
    rho_step = 2 * hypot(size(orig_img, 1), size(orig_img, 2))/size(hough_img, 1);
    [width, length] = size(edge_img);

    for rho_index = 1:size(hough_img , 1)
        for theta_index = 1:size(hough_img , 2)
            if hough_img(rho_index,theta_index) >= hough_threshold
                rho = rho_step*(rho_index - size(hough_img, 1)/2);
                theta = theta_index * (pi/size(hough_img, 2));
                x_1 = -1;
                y_1 = -1;
                for x = 1 : width
                    y = round(-x*cos(theta)/sin(theta) + rho/sin(theta));
                    % make sure y is in bounds of the image
                    if y > 0 && y < length 
                        % find (x_1,y_1) start of line  
                        if contains_edge(edge_img, x, y) ~= 0 && x_1 == -1
                            x_1 = x;
                            y_1 = y;
                        end
                        
                        % find (x_2,y_2) end of line
                        if contains_edge(edge_img, x, y) == 0 && x_1 ~= -1
                            x_2 = x;
                            y_2 = y;
                            line([y_1, y_2], [x_1, x_2], 'LineWidth', 1, 'Color', [0, 1, 0]); 
                            % reset beginning of line 
                            x_1 = -1;
                            y_1 = -1;
                        end
                    end                     
                end           
            end
        end
    end   
end

% checks if 3x3 grid where middle pixel is (x,y) contains any edges
function has_edge = contains_edge(edge_img, x, y)
    has_edge = 0;
    [width, length] = size(edge_img);

    grid_indices = [[x-1,y-1]; [x-1,y]; [x-1,y+1]; 
                    [x,y-1];   [x,y];   [x,y+1]; 
                    [x+1,y-1]; [x+1,y]; [x+1,y+1];];

    for point = 1:size(grid_indices, 1)
        x_i = grid_indices(point, 1);
        y_i = grid_indices(point, 2);
        if x_i > 0 && width >= x_i && y_i > 0 && length >= y_i 
            if edge_img(x_i, y_i) ~= 0
                has_edge = 1;
            end
        end
    end
           
end