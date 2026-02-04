# Lab 2 - Colour and Perception

**22 January 2026**
---
## Part 1 - Seeing Colours and Shapes
---

### Task 1 - Find your blind spot

Play the video [here](http://www.ee.ic.ac.uk/pcheung/teaching/DE4_DVS/assets/blind_spot_test.mp4) and follow its instructions.  Make notes on what you found out.

#### Notes
We found our blind spots by covering one eye and moving back forth from the screen until we were not able to see the symbol.

<video src="Lab2assets/blind_spot_test.mp4" width="480" height="360" controls></video>

### Task 2 - Ishihara Colour Test

The Ishihara test is a colour vision test designed to detect deficiencies in the long and medium cones.  It consists of one set of pictures containing colour dots with a number embedded within.  Your goal is to identify the number you see in each of them.

You can start the test [here](Ishihara_test.md).

#### Notes
We are not colour blind.

### Task 3 - Reverse colour

1. Get hold of a white sheet of paper and hold it up next to your screen.  
2. Now stare at white dot in the centre of the American flag in funny colours shown below for 10 seconds or more.  
3. Suddenly switch your gaze to the white sheet of paper.

You should see the American flag in the normal red, white and blue colours.

<p align="center"> <img src="Lab2assets/american_flag.jpg" /> </p><BR>

Explain the reasons why this happens.

#### Notes
Staring at the altered colors overstimulates specific cone cells in the retina. When you look away to a white surface, those cones are temporarily fatigued and respond less, so the opposing cones dominate. The brain interprets this imbalance as the complementary colors, creating a negative afterimage of the normal red, white, and blue flag.


### Task 4 - Troxler's Fading

Here is another example to demonstrate the Opponent Process Theory.  Play the video [here](http://www.ee.ic.ac.uk/pcheung/teaching/DE4_DVS/assets/purple_dots.mp4) and follow the instruction.  

<video src="Lab2assets/purple_dots.mp4" width="640" height="320" controls></video>

Write down in your logbook the reason of what you see.  Read the wikipedia page on Troxler's fading [here](https://en.wikipedia.org/wiki/Troxler%27s_fading), which explains this phenomenon and relates it to the human visual system.

[Here](http://www.ee.ic.ac.uk/pcheung/teaching/DE4_DVS/assets/blue_circle.mp4) is another experiment to test the phenomenon.  Play the video and comment.

<video src="Lab2assets/blue_circle.mp4" width="640" height="320" controls></video>

#### Notes
Troxler’s fading is a visual effect where unchanging stimuli in your field of view gradually disappear when you fix your gaze on a single point. This happens because neurons in your visual system adapt to constant, unvarying input and stop responding, so the brain essentially filters it out of perception. When you then look at a plain white surface, the altered color signals and this neural adaptation help produce a complementary-colored afterimage of the original image.

### Task 5 - Brain sees what it expects

Our brain interprets what we see based on our expectation.  Here is an example.  The image below shows two tables with blue and red tops.  Which is the longer table?  Measure this on the screen with a ruler (or just marking on a sheet of paper).  Write in your logbook the reason for this phenomenon.

<p align="center"> <img src="Lab2assets/table.jpg" /> </p><BR>

Here is another example, where our brain see what it expects instead of what hits the retina.  Which square is darker, the one labelled A or B?  Why?

<p align="center"> <img src="Lab2assets/shadow.jpg" /> </p><BR>

To verify the result, you need to use an image editor app and cut out one square and put it next to the other for comparison.

#### Notes
We thought that the blue table is longer than the red one but they turned out to be of same length, and similarly we thought that A is darker than B but then in the image editor they turned out to be the same colour of the following code #6F6F6F. This is due to our expectations in our brain and our perception tricking us.

### Task 6 - The Grid Illusion

When you stare at the centre of the grid below, you should see black dots at the intersection appearing and disappearing.  You can read more about it [here](https://en.wikipedia.org/wiki/Grid_illusion).

<p align="center"> <img src="Lab2assets/grid.jpg" /> </p><BR>

#### Notes
A grid illusion is an optical trick where a pattern of intersecting lines makes you see dark or flickering spots at the intersections that aren’t really there. The most famous example is the Hermann grid, where ghost-like grey blobs appear at the crossings of a light grid on a dark background but vanish when you look directly at them. This happens because of how the visual system processes contrast across the pattern, neighboring light and dark areas influence each other in the brain, creating the illusory spots.

### Task 7 - Cafe Wall Illusion

Do you see the following brick wall layers are parallel?  Then measure the boundaries of each layer with a ruler.

<p align="center"> <img src="Lab2assets/bricks.jpg" /> </p><BR>

This phenomenon is not observed for the following image when the contrast is lower.

<p align="center"> <img src="Lab2assets/cbricks.jpg" /> </p><BR>

You can find out more about this [here](https://en.wikipedia.org/wiki/Café_wall_illusion).

#### Notes
At first the brick wall seemed wobbly, but then after measuring the distance between each 2 lines they were all 1 cm away everywhere so they were straight and parallel. The Café wall illusion makes straight, parallel horizontal lines appear tilted or sloped when they’re actually perfectly straight. This happens because alternating dark and light “bricks” with offset rows cause the visual system’s edge-detection signals to misinterpret the alignment — the contrast at the edges tricks the brain into perceiving a tilt that isn’t there.

### Task 8 - the Silhouette Illusion

[Here](http://www.ee.ic.ac.uk/pcheung/teaching/DE4_DVS/assets/dancer.m4v) is video of a spinning dancer.  Play the video and looking at it for some time, you may find that the dance would suddenly spinning in the opposite direction.  The explanation for this phenomenon can be found [here](https://en.wikipedia.org/wiki/Spinning_dancer).

<video src="Lab2assets/dancer.m4v" width="640" height="640" controls></video>

#### Notes
The Spinning Dancer illusion is a motion-based bistable image : a silhouette that can be seen rotating either clockwise or counterclockwise with no depth cues. Your brain makes a guess about the dancer’s rotation direction, and it can flip between interpretations because the 2D image doesn’t tell your visual system which way it’s actually turning.

### Task 9 - the Incomplete Triangles

The last task in part 1 is to consider the picture below.  How many triangles are in the picture?  What conclusions can you draw from this observation?

<p align="center"> <img src="Lab2assets/triangle.jpg" /> </p><BR>

#### Notes
The Kanizsa Triangle illusion is when you see a bright white triangle that isn’t actually drawn. Your brain fills in missing edges between the “Pac-Man” shapes and creates illusory contours. It happens because the visual system prefers simple, complete shapes, so it invents the triangle even though no real lines exist. So there is actually ZERO triangles.

---
## Part 2 - Exploring Colours in Matlab
---

In the second part of Lab 2, you will import a full colour image from a file and map this to various colour spaces.  You will then examine what each of the components (or channels) in these colour spaces.  

### Task 10 - Convert RGB image to Grayscale

Although full colour images contain more information than grayscale images, we often find that they contain too much information and require unnecessary calculations. Instead it may be better to turn the colour image into a grayscale image before we perform various processing such as feature extraction.

Run Matlab and navigate the current working folder to the matlab folder of Lab 2.  (You do this with the icon ![Alt text](Lab2assets/cwf_icon.jpg) at the top left of the Matlab window).  The photo **peppers.png** is already stored in this folder.  Find out information about this photo file with **imfinfo( )**:
```
imfinfo('peppers.png')
```
Matlab will return some information about this image file such as its size and the format of the image data.

Read the image data into the array RGB and display it:(*_Remember to add the semicolon at the end of the imread statement to suppress printing of all the image data read._*)
```
RGB = imread('peppers.png');  
imshow(RGB)
```
In this task, we will convert the RGB image into a grayscale image. The formula to perform this mapping is:
```
    I = 0.299 * R + 0.587 * G + 0.114 * B 
```

In matrix form, it is:

<p align="center"> <img src="Lab2assets/grayscale_eq.jpg" /> </p>

The function **rgb2gray( )** converts RGB values to grayscale values by forming a weighted sum of the R, G, and B components according to the equation above. 

```
I = rgb2gray(RGB);
figure              % start a new figure window
imshow(I)
```

It would easier to compare the two photo if we display them side-by-side with **imshowpair( )** and add a title. This can be done with:

```
imshowpair(RGB, I, 'montage')
title('Original colour image (left) grayscale image (right)');
```

### Task 11 - Splitting an RGB image into separate channels

Split the image into its red, green, and blue channels with **imsplit( )**. Then display all three images side-by-side as a montage.

```
[R,G,B] = imsplit(RGB);
montage({R, G, B},'Size',[1 3])
```

Note the following: Red peppers have a signal predominantly in the red channel. Yellow and green peppers have a signal in both the red and green channels. White objects, such as the garlic in the foreground, have a strong signal in all three channels.

Examine the information shown on the right side of the Matlab window. Explain their dimensions and data type of the variables RGB, R, G, B and I.

### Task 12 - Map RGB image to HSV space and into separate channels

Convert the RGB image to the HSV colorspace by using the **rgb2hsv( )** function.  Then split it into H, S and V components.

```
HSV = rgb2hsv(RGB);
[HSV] = imsplit(HSV);
montage({H,S,V}, 'Size', [1 3]))
```

### Task 13 - Map RGB image to XYZ space

Finally, map the RGB image to the XYZ colour space with the **rgb2xyz( )** function.  Examine what you get and comment.

#### Notes
X, Y, Z are not usual RGB colors; they are tristimulus values. Y relates to brightness, while X and Z combine with Y to reproduce true color in CIE 1931. Displaying them without normalization may look dark or washed out, since XYZ values can exceed 0–1.
 
```
Full Code:

clear all
clc
imfinfo('peppers.png')
RGB = imread('peppers.png');  
imshow(RGB)
I = rgb2gray(RGB);
figure              % start a new figure window
imshow(I)
imshowpair(RGB, I, 'montage')
title('Original colour image (left) grayscale image (right)');
[R,G,B] = imsplit(RGB);
montage({R, G, B},'Size',[1 3])
HSV = rgb2hsv(RGB);
[H,S,V] = imsplit(HSV);
montage({H,S,V}, 'Size', [1 3])

%% Assume RGB is your input image
% Example: RGB = imread('peppers.png');
%% --- HSV Conversion ---
HSV = rgb2hsv(RGB);           % Convert RGB to HSV
[H, S, V] = imsplit(HSV);     % Split into channels
figure('Name','HSV Channels');
montage({H, S, V}, 'Size', [1 3]);  % Display as 1x3 montage
title('H | S | V channels');

%% --- XYZ Conversion ---
XYZ = rgb2xyz(RGB);           % Convert RGB to XYZ
[X, Y, Z] = imsplit(XYZ);     % Split into channels

% Normalize for display (optional, keeps values between 0-1)
X_disp = X / max(X(:));
Y_disp = Y / max(Y(:));
Z_disp = Z / max(Z(:));

figure('Name','XYZ Channels');
montage({X_disp, Y_disp, Z_disp}, 'Size', [1 3]);  % Display as 1x3 montage
title('X | Y | Z channels');

%% --- Optional: inspect raw values ---
disp('XYZ channel ranges:');
fprintf('X: [%f, %f]\n', min(X(:)), max(X(:)));
fprintf('Y: [%f, %f]\n', min(Y(:)), max(Y(:)));
fprintf('Z: [%f, %f]\n', min(Z(:)), max(Z(:)));

```
<p align="center"> <img src="Lab2assets/solutions/grayscale image.png" /> </p><BR>
<p align="center"> <img src="Lab2assets/solutions/side by side 2x2.png" /> </p><BR>
<p align="center"> <img src="Lab2assets/solutions/3 images rbg.png" /> </p><BR>
<p align="center"> <img src="Lab2assets/solutions/3 images xyz.png" /> </p><BR>
