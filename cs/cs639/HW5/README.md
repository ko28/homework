debug1a:	
	For the computeFlow.m, I extracted the patch and template from each location, taking into consideration the boundaries (if the template went over the image I took the nearest pixel in the image as the last pixel for the template). Then I computed the correlation using normxcorr2. I noticed that all the flow in the edges were acting weird so I actually increased the size of the output grid by 1 on all sides, then removed the extra flow points at the end of my algorithm. All the weird points were removed this way. 
	params:
		search_radius = 15;     % Half size of the search window
		template_radius = 4;   % Half size of the template window
		grid_MN = [15, 10];     % Number of rows and cols in the grid

challenge1a:
	I messed around with the parameters and this was the best result I could obtain. There are some random points that are large and point in the wrong direction of the flow but the image is mostly correct.
	params:
		search_radius = 30;     % Half size of the search window
		template_radius = 20;   % Half size of the template window
		grid_MN = [20, 30];     % Number of rows and cols in the grid

challenge2a:
	For trackingTester.m, I compute the intensity historgram using the built in histcounts. In the tracking loop, I extract the search_window similiar to what I did in computeFlow.m. To find the best region, I used the mean squared error (immse) to compare the generated historgrams to the historgram of the object we are tracking. Before setting with the mean squared error, I tried to use the correlation coefficients function in matlab (corrcoef) but the results were not very good so I switched to immse.
	params:
		tracking_params.rect = [180 58 59 139];
		tracking_params.search_radius = 7;
		tracking_params.bin_n = 150;     
challenge2b:
	I realized that having too big of a tracking box caused many errors in finding the correct match. Making the box small, i.e. the whole ball is not tracked only the middle part of the ball, produced good results. 
	params:
		tracking_params.rect = [159 138 37 37];
		tracking_params.search_radius = 4;
		tracking_params.bin_n = 150; 
challenge2c:
	I had some trouble tracking the middle player using the previous techniques. When I tracked the player's whole body, 2/3 of the way through the pictures, it started to track a random area in the crowd. I decided to track only the top half of the player and I got much better results. Even though it tracks the bottom portion of his body at times, the algorithm was able to track the player throughout the entire clip.
	params:
		tracking_params.rect = [310 223 36 75];
		tracking_params.search_radius = 5;
		tracking_params.bin_n = 150;            
