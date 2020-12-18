function runHw3(varargin)
% runHw3 is the "main" interface that lists a set of 
% functions corresponding to the problems that need to be solved.
%
% Note that this file also serves as the specifications for the functions 
% you are asked to implement. In some cases, your submissions will be autograded. 
% Thus, it is critical that you adhere to all the specified function signatures.
%
% Before your submssion, make sure you can run runHw3('all') 
% without any error.
%
% Usage:
% runHw3                       : list all the registered functions
% runHw3('function_name')      : execute a specific test
% runHw3('all')                : execute all the registered functions

% Settings to make sure images are displayed without borders
orig_imsetting = iptgetpref('ImshowBorder');
iptsetpref('ImshowBorder', 'tight');
temp1 = onCleanup(@()iptsetpref('ImshowBorder', orig_imsetting));

fun_handles = {@honesty,...
    @debug1, @challenge1a, @challenge1b,...
    @challenge1c, @challenge1d, @challenge1e};

% Call test harness
runTests(varargin, fun_handles);

%--------------------------------------------------------------------------
% Academic Honesty Policy
%--------------------------------------------------------------------------
%%
function honesty()
% Type your full name and uni (both in string) to state your agreement 
% to the Code of Academic Integrity.
signAcademicHonestyPolicy('Daniel Ko', '9080230908');

%--------------------------------------------------------------------------
% Tests for Challenge 1: Panoramic Photo App
%--------------------------------------------------------------------------

%%
function debug1()
% Test homography

orig_img = imread('portrait.png'); 
warped_img = imread('portrait_transformed.png');

% Choose 4 corresponding points (use getPointsFromUser)
[src_x, src_y] = getPointsFromUser(orig_img, 4, 'Click any 4 points');
[dst_x, dst_y] = getPointsFromUser(warped_img, 4, 'Click the corresponding locations of the previous 4 points');

src_pts_nx2 = [src_x, src_y];
dest_pts_nx2 = [dst_x, dst_y];

H_3x3 = computeHomography(src_pts_nx2, dest_pts_nx2);
% src_pts_nx2 and dest_pts_nx2 are the coordinates of corresponding points 
% of the two images, respectively. src_pts_nx2 and dest_pts_nx2 
% are nx2 matrices, where the first column contains
% the x coodinates and the second column contains the y coordinates.
%
% H, a 3x3 matrix, is the estimated homography that 
% transforms src_pts_nx2 to dest_pts_nx2. 


% Choose another set of points on orig_img for testing.
% test_pts_nx2 should be an nx2 matrix, where n is the number of points, the
% first column contains the x coordinates and the second column contains
% the y coordinates.
[test_x, test_y] = getPointsFromUser(orig_img, 5, 'Click any 5 points to visualize the homography');
test_pts_nx2 = [test_x, test_y];

% Apply homography
dest_pts_nx2 = applyHomography(H_3x3, test_pts_nx2);
% test_pts_nx2 and dest_pts_nx2 are the coordinates of corresponding points 
% of the two images, and H is the homography.

% Verify homography 
close all;
result_img = showCorrespondence(orig_img, warped_img, test_pts_nx2, dest_pts_nx2);

imwrite(result_img, 'homography_result.png');

%%
function challenge1a()
% Test warping

bg_img = im2double(imread('Osaka.png')); %imshow(bg_img);
portrait_img = im2double(imread('portrait_small.png')); %imshow(portrait_img);


%[test_x, test_y] = getPointsFromUser(bg_img, 4, 'Click any 5 points to visualize the homography');
% -------------------
% Estimate homography
% Choose 4 points (image corners work well) on the portrait image, and
% select their corresponding locations in the bg_img.
% You might find the getPointsFromUser function used in debug1a useful.
% -------------------
portrait_pts = [0 0; 327 0; 327 400;  0 400];
bg_pts = [100.0917 19.4835; 275.9387 71.4383; 284.7311 424.7311; 84.9049 438.3193];
     

H_3x3 = computeHomography(portrait_pts, bg_pts);

dest_canvas_width_height = [size(bg_img, 2), size(bg_img, 1)];

% Warp the portrait image
[mask, dest_img] = backwardWarpImg(portrait_img, inv(H_3x3), dest_canvas_width_height);

% mask should be of the type logical
% it represents where the portrait is present in the canvas
% we invert it because we need it to represent where the background image is present
mask = ~mask;

% Superimpose the image
result = bg_img .* cat(3, mask, mask, mask) + dest_img;
figure, imshow(result);
imwrite(result, 'Van_Gogh_in_Osaka.png');

%%  
function challenge1b()
% Test RANSAC -- outlier rejection

imgs = imread('mountain_left.png'); imgd = imread('mountain_center.png');
[xs, xd] = genSIFTMatches(imgs, imgd);
% xs and xd are the centers of matched frames
% xs and xd are nx2 matrices, where the first column contains the x
% coordinates and the second column contains the y coordinates

close all;
before_img = showCorrespondence(imgs, imgd, xs, xd);
%figure, imshow(before_img);
imwrite(before_img, 'before_ransac.png');

% Use RANSAC to reject outliers
ransac_n = 100; % Max number of iterations
ransac_eps = 3; %Acceptable alignment error 

[inliers_id, H_3x3] = runRANSAC(xs, xd, ransac_n, ransac_eps);

after_img = showCorrespondence(imgs, imgd, xs(inliers_id, :), xd(inliers_id, :));
figure, imshow(after_img);
imwrite(after_img, 'after_ransac.png');

%%
function challenge1c()
% Test image blending

[fish, fish_map, fish_mask] = imread('escher_fish.png');
[horse, horse_map, horse_mask] = imread('escher_horsemen.png');
blended_result = blendImagePair(fish, fish_mask, horse, horse_mask,...
    'blend');
figure, imshow(blended_result);
imwrite(blended_result, 'blended_result.png');

overlay_result = blendImagePair(fish, fish_mask, horse, horse_mask, 'overlay');
figure, imshow(overlay_result);
imwrite(overlay_result, 'overlay_result.png');

%%
function challenge1d()
% Test image stitching

% stitch three images
imgc = im2single(imread('mountain_center.png'));
imgl = im2single(imread('mountain_left.png'));
imgr = im2single(imread('mountain_right.png'));

% You are free to change the order of input arguments
% stitched_img = stitchImg(imgc, imgl, imgr);
stitched_img = stitchImg(imgl, imgc, imgr);

figure, imshow(stitched_img);
imwrite(stitched_img, 'mountain_panorama.png');

%%
function challenge1e()
% Your own panorama
% ADD YOUR CODE HERE
% (adapt from challenge1e -- call stitchImg with your own images and save
% the output using imwrite)
img0 = im2single(imread('my_panorama_img/0.jpg'));
img1 = im2single(imread('my_panorama_img/1.jpg'));
img2 = im2single(imread('my_panorama_img/2.jpg'));
stitched_img = stitchImg(img0, img1, img2);
figure, imshow(stitched_img);
imwrite(stitched_img, 'mypanorama.png');
%%
