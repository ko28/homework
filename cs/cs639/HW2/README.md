Daniel Ko, 9080230908


challenge1a:
I used the built in edge function and experimented with various methods. For this assignment the "sobrel" method with a threshold of 0.02 worked best for me.

challenge1b:
I chose to use 2000 bins for both theta and rho because the extra resolution is useful and on a modern computer the function I implemented only takes a couple seconds. To fill up the accumulation array, I iterated over each edge pixel and calculated all the possible rho and theta values. Theta is measured clockwise with respect to the positive x axis so the equation I used was:
	rho = x*cos(theta) + y*sin(theta). 
With these rho and theta values, I converted it into indices of the accumulation array. Since there can be negative values for rho values, I split the accumulation array in half, where the 1st index represents -max_rho and the last index represents max_rho. I chose the voting method where each (rho, theta) pair gets one vote. I chose this method because it was simple to implement and got acceptable results. For scaling the values in the accumulation array to [0,255], I used the built in rescale function. 

challenge1c:
I used a threshold method. If a given pixel in the hough_img passed this threshold, I calculated the rho and theta values and then plotted the line from x = 0 to x = width of image. The threshold for hough_1, hough_2, hough_3 are as follows 130, 70, 60. 

challenge1d:
I used a threshold method. Instead of plotting lines from x = 0 to x = width of image, I plotted lines only along where edges existed. For each (rho, theta) pair, I computed the sections where continuous edges existed. I considered the 3x3 pixel grid around the corresponding (x,y) pixel to check if an edge existed to avoid not noticing an edge that is nearby but not the exact pixel. Interestly, the line segments were extracted well along the y dimension but there were some long lines along the x dimension. I think this may have to do with the fact where I computed the y coordinate from the (rho, theta) pair, but iterated over x values. The threshold for hough_1, hough_2, hough_3 are as follows 120, 60, 40.