function [x,y] = getPointsFromUser(img, npts, message)
%GETPOINTSFROMUSER displays an image and obtains 'npts' points on it from the user using ginput
    fig = figure;
    imshow(img);
    if nargin == 3
        set(fig, 'Name', message, 'NumberTitle', 'off');
    end
    [x, y] = ginput(npts);
    close(fig);
end

