challenge1a:
I estimated the points using the getPointsFromUser. In the backwardWarpImg function, I used the interp2 function to shift the original pixels to the new image using the homography. I generated the mask setting all the non zero values in the result img to 1. 

challenge1b:
In the runRANSAC function, I pick a random number of points. Using these points, I compute the homography and apply it to the original sample. Then I measure how many points are within the alignment error(ransac_eps). I do this ransac_n times and pick the best performing homography. I choose ransac_n = 100 and ransac_eps = 3 because that was recommended on piazza and it seemed to work well for this challenge.

challenge1c:
In the blendImagePair function, I used bwdist on the binary masks of the images to get a weighted mask. Then I applied each weighted mask on both images and averaged them out to get a final image made up of a linear combination of the two images.

challenge1d:
In the stitchImg function, I compute the homography from the middle image and the image I want to stick using ransac. I choose a fairly high ransac_n value (10000) because smaller values did not produce good performing homographies. Then I warped the image I want to stitch with the middle using the backwardWarpImg and then blended the images with blendImagePair. Finally, I updated mask to include the newly stitched image.  

challenge1e:
I took couple pictures and ran it through the stitchImg function. I tried using the original photos from my phone but those pictures had too high of a resolution and I would run out of ram on my computer. I think the sift library is very slow or is not optimized for my computer. I also realized that taking photos that were too far from each other will result it blurring or produce a terrible homography. I downscaled my photos and picked photos that were close to each other. So my final result does not have a super high fov but I think it is okay as toy implementation. 