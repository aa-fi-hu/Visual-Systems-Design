# Lab 4 - Morphological Image Processing

**5 February 2026**

## Task 1: Dilation and Erosion

Matlab provides a collection of morphological functions.  Here is a list of them:

<p align="center"> <img src="Lab4assets/morphological_operators.jpg" /> </p>

### Dilation Operation
```
A = imread('assets/text-broken.tif');
B1 = [0 1 0;
     1 1 1;
     0 1 0];    % create structuring element
A1 = imdilate(A, B1);
montage({A,A1})
```
#### Result
<p align="center"> <img src="Lab4assets/1-1.png" /> </p>

> Change the structuring element (SE) to all 1's.  Instead of enumerating it, you can do that with the function _ones_:
```
B2 = ones(3,3);     % generate a 3x3 matrix of 1's
```

> Try making the SE larger.

#### Result
<p align="center"> <img src="Lab4assets/1-2.png" /> </p>

> Try to make the SE diagonal cross:
```
Bx = [1 0 1;
      0 1 0;
      1 0 1];
```

#### Result
<p align="center"> <img src="Lab4assets/1-3.png" /> </p>

> What happens if you dilate the original image with B1 twice (or more times)?

#### Answer
Dilating multiple times is mathematically equivalent to dilating once with a larger structuring element. Each pass will further "fatten" the text and fill in more gaps, but eventually, the characters may merge and become unrecognizable.

### Generation of structuring element

For spatial filtering, we used function _fspecial_ to generate our filter kernel.  For morphological operations, we use function _strel_ to generate different kinds of structuring elements.

Here is a list of SE that _strel_ can generate:

<p align="center"> <img src="Lab4assets/strel.jpg" /> </p>

For example, to generate a disk with radius r = 4:

```
SE = strel('disk',4);
SE.Neighborhood         % print the SE neighborhood contents
```

_strel_ returns not a matrix, but an internal data structure called _strel_. This speeds up the execution of the morphological functions by Matlab.


#### Answer

<p align="center"> <img src="Lab4assets/1-4.png" /> </p>

### Erosion Operation

Explore erosion with the following:

```
clear all
close all
A = imread('assets/wirebond-mask.tif');
SE2 = strel('disk',2);
SE10 = strel('disk',10);
SE20 = strel('disk',20);
E2 = imerode(A,SE2);
E10 = imerode(A,SE10);
E20 = imerode(A,SE20);
montage({A, E2, E10, E20}, "size", [2 2])
```
Comment on the results.

#### Answer

<p align="center"> <img src="Lab4assets/1-5.png" /> </p>

- Small SE (Radius 2): Removes very fine "hairs" or single-pixel noise from the edges without significantly altering the main shapes.
- Medium SE (Radius 10): Thin connections or narrow parts of the mask will disappear completely.
- Large SE (Radius 20): Only the very centers of the largest objects remain; most of the original structure is "eroded" away.

## Task 2 - Morphological Filtering with Open and Close

### Opening = Erosion + Dilation
In this task, you will explore the effect of using Open and Close on a binary noisy fingerprint image.

1. Read the image file 'finger-noisy.tif' into _f_.
2. Generate a 3x3 structuring element SE.
3. Erode _f_ to produce _fe_.
4. Dilate _fe_ to produce _fed_.
5. Open _f_ to produce _fo_.
6. Show _f_, _fe_, _fed_ and _fo_ as a 4 image montage.

Comment on the the results.

Explore what happens with other size and shape of structuring element.

Improve the image _fo_ with a close operation.

Finally, compare morphological filtering using Open + Close to spatial filter with a **Gaussian filter**. Comment on your comparison.

#### Answers

```
% Read the noisy fingerprint image
f = imread('fingerprint-noisy.tif');

% Make sure it's binary (in case it's not already logical)
f = logical(f);

% Generate a 3x3 structuring element
SE = strel('square', 3);

% Erosion
fe = imerode(f, SE);

% Dilation of eroded image
fed = imdilate(fe, SE);

% Opening (erosion followed by dilation)
fo = imopen(f, SE);

% Display results as a 4-image montage
figure;
montage({f, fe, fed, fo}, 'Size', [1 4]);
title('Original | Eroded | Eroded+Dilated | Opened');

```

<p align="center"> <img src="Lab4assets/tsk2.png" /> </p>

Original image (f):
The fingerprint contains salt-and-pepper–type noise and small spurious pixels that interfere with ridge continuity.

Eroded image (fe):
Erosion removes small bright noise effectively, but it also thins the fingerprint ridges and may break weak connections between them. Fine ridge details are partially lost.

Eroded + Dilated image (fed):
Dilation restores some of the ridge thickness removed by erosion. However, the result is not identical to the original, since noise removed during erosion is not recovered. Ridge gaps caused by erosion may remain.

Opened image (fo):
Opening produces a cleaner fingerprint with reduced noise while preserving the main ridge structure. Compared to simple erosion, opening gives a better balance between noise removal and shape preservation, which is why it is preferred in practice.


####
<p align="center"> <img src="Lab4assets/diff sizes.png" /> </p>

As the structuring element size increases, noise is increasingly removed, but important fingerprint details such as thin ridges and bifurcations are also lost. Small structuring elements (e.g. 3×3) provide the best compromise between noise suppression and preservation of ridge structure, while larger sizes lead to excessive smoothing.


####
<p align="center"> <img src="Lab4assets/closed.png" /> </p>

A larger, disk-shaped structuring element was used for the closing operation to better reconnect broken fingerprint ridges, as a 3×3 square produced minimal visible improvement after opening.

####
<p align="center"> <img src="Lab4assets/compare.png" /> </p>

The Open + Close morphological filtering preserves fingerprint ridge structure and reconnects broken lines, while Gaussian filtering smooths noise but blurs ridge edges and reduces structural clarity after thresholding.

## Task 3 - Boundary detection 

The grayscale image 'blobs.tif' consists of blobs or bubbles of different sizes in a sea of noise. Further, the bubbles are dark, while the background is white.  The goal of this task is to find the boundaries of the blobs using the boundary operator (Lecture 6, slide 17).

<p align="center"> <img src="Lab4assets/blobs.jpg" /> </p>

First we turn this "inverted" grayscale image into a binary image with white objects (blobs) and black background. Do the following:

```
clear all
close all
I = imread('assets/blobs.tif');
I = imcomplement(I);
level = graythresh(I);
BW = imbinarize(I, level);
```
The Matlab function  _graythresh_ computes a global threshold _level_ from the grayscale image I, by finding a threshold that minimizes the variance of the thresholded black and white pixels. (This method is known as the [Otsu's method](https://cw.fel.cvut.cz/b201/_media/courses/a6m33bio/otsu.pdf).)  The function *_imbinarize_* turns the grayscale image to a binary image **BW**: those pixels above or equal to _level_ are made foreground (i.e. 1), otherwise they are background (0).


Now, use the boundary operation to compute the boundaries of the blobs. This is achieved by eroding BW  with SE, where SE is a 3x3 elements of 1's. The eroded image is subtract from BW. 

Diplay as montage {I, BW, erosed BW and boundary detected image}.  Comment on the result.

How can you improve on this result?

#### Answers
<p align="center"> <img src="Lab4assets/3.jpeg" /> </p>

Comment: The boundary operation successfully extracts the outer contours of the blobs, but the detected boundaries are thick and slightly irregular. Small blobs and noise also produce boundaries, and some edges appear fragmented due to the discrete nature of erosion with a square structuring element.

Improvement: The result can be improved by removing small noisy blobs before boundary extraction and by using a smoother structuring element (e.g. a disk) to obtain thinner, more regular boundaries.

##### Code
```
clear all
close all

% Read and invert image
I = imread('blobs.tif');
I = imcomplement(I);

% Binarization using Otsu
level = graythresh(I);
BW = imbinarize(I, level);

% Structuring element (3x3 ones)
SE = strel('square', 3);

% Erosion
BW_eroded = imerode(BW, SE);

% Boundary extraction
boundary = BW - BW_eroded;

% Display results
figure;
montage({I, BW, BW_eroded, boundary}, 'Size', [1 4]);
title('Inverted Grayscale | Binary | Eroded Binary | Blob Boundaries');

```

## Task 4 - Function bwmorph - thinning and thickening

Matlab's Image Processing Toolbox includes a general morphological function *_bwmorph_* which implements a variety of morphological operations based on combinations of dilations and erosions.  The calling syntax is:

```
g = bwmorph(f, operations, n)
```
where *_f_* is the input binary image, *_operation_* is a string specifying the desired operation, and *_n_* is a positive integer specifying the number of times the operation should be repeated. (n = 1 if omitted.)

The morphological operations supported by _bwmorph_ are:

<p align="center"> <img src="Lab4assets/bwmorph.jpg" /> </p>

To test function *_bwmorph_* on thinning operation, do the following:

1. Read the image file 'fingerprint.tif' into *_f_*.
2. Turn this into a good binary image using method from the previous task. 
3. Perform thinning operation 1, 2, 3, 4 and 5 times, storing results in g1, g2 ... etc.
4. Montage the unthinned and thinned images to compare.

What will happen if you keep thinning the image?  Try thinning with *_n = inf_*.  (_inf_ is reserved word in Matlab which means infinity.  However, for _bwmorph_, it means repeat the function until the image stop changing.)

Modify your matlab code so that the fingerprint is displayed black lines on white background instead of white on black.  What conclusion can you draw about the relationship between thinning and thickening?

#### Answers
##### Code 1st part
```
% Thinning using bwmorph

clear all
close all

% Read fingerprint image
f = imread('fingerprint-noisy.tif');

% Convert to grayscale if needed
if ndims(f) == 3
    f = rgb2gray(f);
end

% Convert to binary (same method as previous task)
f = im2double(f);
level = graythresh(f);
BW = imbinarize(f, level);

% Thinning operations
g1 = bwmorph(BW, 'thin', 1);
g2 = bwmorph(BW, 'thin', 2);
g3 = bwmorph(BW, 'thin', 3);
g4 = bwmorph(BW, 'thin', 4);
g5 = bwmorph(BW, 'thin', 5);

% Display comparison
figure;
montage({BW, g1, g2, g3, g4, g5}, 'Size', [1 6]);
title('Original | Thin 1 | Thin 2 | Thin 3 | Thin 4 | Thin 5');

```
<p align="center"> <img src="Lab4assets/4-1.jpeg" /> </p>

##### Code 2nd part
```
% Thinning using bwmorph

clear all
close all

% Read fingerprint image
f = imread('fingerprint-noisy.tif');

% Convert to grayscale if needed
if ndims(f) == 3
    f = rgb2gray(f);
end

% Convert to binary (same method as previous task)
f = im2double(f);
level = graythresh(f);
BW = imbinarize(f, level);

% Thinning operations
g1 = bwmorph(BW, 'thin', 1);
g2 = bwmorph(BW, 'thin', 2);
g3 = bwmorph(BW, 'thin', 3);
g4 = bwmorph(BW, 'thin', 4);
g5 = bwmorph(BW, 'thin', 5);

% Display comparison
figure;
montage({BW, g1, g2, g3, g4, g5}, 'Size', [1 6]);
title('Original | Thin 1 | Thin 2 | Thin 3 | Thin 4 | Thin 5');

```
<p align="center"> <img src="Lab4assets/4-2.jpeg" /> </p>

Comment: Thinning progressively reduces ridge thickness; using n = Inf produces the full skeleton with 1-pixel-wide ridges while preserving connectivity.

##### Code 2nd part
```
% Thinning fingerprint image with black ridges on white background

clear all
close all

% Read fingerprint image
f = imread('fingerprint-noisy.tif');

% Convert to grayscale if needed
if ndims(f) == 3
    f = rgb2gray(f);
end

% Convert to double for thresholding
f = im2double(f);

% Binarize using Otsu's method
level = graythresh(f);
BW = imbinarize(f, level);

% Perform thinning
g1 = bwmorph(BW, 'thin', 1);
g2 = bwmorph(BW, 'thin', 2);
g3 = bwmorph(BW, 'thin', 3);
g4 = bwmorph(BW, 'thin', 4);
g5 = bwmorph(BW, 'thin', 5);
g_inf = bwmorph(BW, 'thin', Inf);

% Convert logical images to uint8 for proper display
BW_disp    = uint8(BW) * 255;
g1_disp    = uint8(g1) * 255;
g2_disp    = uint8(g2) * 255;
g3_disp    = uint8(g3) * 255;
g4_disp    = uint8(g4) * 255;
g5_disp    = uint8(g5) * 255;
g_inf_disp = uint8(g_inf) * 255;

% Invert to get black ridges on white background
BW_disp    = 255 - BW_disp;
g1_disp    = 255 - g1_disp;
g2_disp    = 255 - g2_disp;
g3_disp    = 255 - g3_disp;
g4_disp    = 255 - g4_disp;
g5_disp    = 255 - g5_disp;
g_inf_disp = 255 - g_inf_disp;

% Display comparison
figure;
montage({ BW_disp, g5_disp, g_inf_disp}, 'Size', [1 3]);
title('Original | Thin 4 | Thin 5 | Thin Inf (Skeleton)');

```
<p align="center"> <img src="Lab4assets/4-3.jpeg" /> </p>

Comment: Thinning reduces ridge thickness progressively until a 1-pixel-wide skeleton is reached. Thickening would do the opposite — it expands ridges back toward their original width. Thus, thinning and thickening are complementary operations: one removes pixels to reduce width, the other adds pixels to restore it.


## Task 5 - Connected Components and labels

In processing and interpreting an image, it is often required to find objects in an image.  After binarization, these objects will form regions of 1's in background of 0's. These are called connected components within the image.  

Below is a text image containing many characters.  The goal is to find the **largest connected component** in this image, and then **erase it**.

<p align="center"> <img src="Lab4assets/text.png" /> </p>

This sounds like a very complex task. Fortunately Matlab provides in their Toolbox the function _bwconncomp_ which performs the morphological operation described in Lecture 6 slides 22 - 24. Try the following Matlab script:

```
t = imread('assets/text.png');
imshow(t)
CC = bwconncomp(t)
```

*_CC_* is a data structure returned by *_bwconncomp_* as described below.

<p align="center"> <img src="Lab4assets/cc.jpg" /> </p>

To determine which is the largest component in the image and then erase it (i.e. set all pixels within that componenet to 0), do this:

```
numPixels = cellfun(@numel, CC.PixelIdxList);
[biggest, idx] = max(numPixels);
t(CC.PixelIdxList{idx}) = 0;
figure
imshow(t)
```
These few lines of code introduce you to some cool features in Matlab.

1. **_cellfun_** applies a function to each element in an array. In this case, the function _numel_ is applied to each member of the list **_CC.PixelIdxList_**.  The kth member of this list is itself a list of _(x,y)_ indices to the pixels within this component.

2. The function **_numel_** returns the number of elements in an array or list.  In this case, it returns the number of pixels in each of the connected components.

3. The first statement returns **_numPixels_**, which is an array containing the number of pixels in each of the detected connected components in the image. This corresponds to the table in Lecture 6 slide 24.

4. The **_max_** function returns the maximum value in numPixels and its index in the array.

5. Once this index is found, we have identified the largest connect component.  Using this index information, we can retrieve the list of pixel coordinates for this component in **_CC.PixelIdxList_**.

#### Answers
<p align="center"> <img src="Lab4assets/5.jpeg" /> </p>

##### Code
```
% Clear workspace and close figures
clear all
close all

% Read the image
t = imread('text.png');

% Store original image for comparison
t_orig = t;

% Find connected components
CC = bwconncomp(t);

% Get the number of pixels in each component
numPixels = cellfun(@numel, CC.PixelIdxList);

% Find the largest component
[biggest, idx] = max(numPixels);

% Remove all other components (set them to 0)
t(CC.PixelIdxList{idx}) = 0;

% Display original and edited images side by side as a montage
figure;
montage({t_orig, t}, 'Size', [1 2]);
title('Original | Largest Component Only');
```

## Task 6 - Morphological Reconstruction

In morphological opening, erosion typlically removes small objects, and subsequent dilation tends to restore the shape of the objects that remains.  However, the accuracy of this restoration relies on the similarly between the shapes to be restored and the structuring element.

**_Morphological reconstruction_** (MR) is a better method that restores the original shapes of the objects that remain after erosion.  

The following exercise demonstrates the method described in Lecture 7 slide 10.  A binary image of printed text is processed so that the letters that are long and thin are kept, while all others are removed.  This is achieved through morphological reconstruction.

MR requires three things: an **input image** **_f_** to be processed called the **_mask**, a **marker image** **_g_**, and a structuring element **_se_**.  The steps are:

1. Find the marker image **_g_** by eroding the mask with an **_se_** that mark the places where the desirable features are located. In our case, the desired characters are all with long vertical elements that are 17 pixels tall.  Therefore the **_se_** used for erosion is a 17x1 of 1's.

2. Apply the reconstruction operation using Matlab's **_imreconstruct_** functino between the **marker** **_g_** and the **mask** **_f_**. 

The step are:

```
clear all
close all
f = imread('assets/text_bw.tif');
se = ones(17,1);
g = imerode(f, se);
fo = imopen(f, se);     % perform open to compare
fr = imreconstruct(g, f);
montage({f, g, fo, fr}, "size", [2 2])
```

Comment on what you observe from these four images.

Also try the function **_imfill_**, which will fill the holes in an image (Lecture 6 slides 19-21).

```
ff = imfill(f);
figure
montage({f, ff})
```

#### Answers
<p align="center"> <img src="Lab4assets/6-1.jpeg" /> </p>

##### Code
```
% Task 6 - Morphological Reconstruction

clear all
close all

% Read binary text image
f = imread('text_bw.tif');

% Ensure it's logical
f = logical(f);

% Create structuring element (17 pixels tall, 1 wide) for vertical features
se = ones(17,1);

% Step 1: Find marker by erosion
g = imerode(f, se);

% Step 2: Perform opening for comparison
fo = imopen(f, se);

% Step 3: Perform morphological reconstruction
fr = imreconstruct(g, f);

% Display mask, marker, open result, and reconstructed result
figure;
montage({f, g, fo, fr}, "Size", [2 2]);
title('Mask f | Marker g | Open fo | Reconstructed fr');
```
Comment: 
> f (Mask) – Original image with all text characters.
> g (Marker) – Only regions where the vertical structure is ≥17 pixels tall remain; smaller or short letters are mostly gone.
> fo (Opening) – Similar to marker but distorts or shrinks remaining letters because dilation cannot fully restore the original shapes.
> fr (Reconstructed) – Restores the original shapes of long vertical letters accurately, keeping them intact while removing short letters.

## Task 7 - Morphological Operations on Grayscale images

So far, we have only been using binary images because they vividly show the effect of morphological operations, turning black pixels to white pixels insted of just change the shades of gray.

In this task, we will explore the effect of erosion and dilation on grayscale images. 

Try the follow:

```
clear all; close all;
f = imread('assets/headCT.tif');
se = strel('square',3);
gd = imdilate(f, se);
ge = imerode(f, se);
gg = gd - ge;
montage({f, gd, ge, gg}, 'size', [2 2])
```
Comments on the results.

## Challenges

You may like to attemp one or more of the following challenges. Unlike tasks in this Lab where you were guided with clear instructions, you are required to find your solutions yourself based on what you have learned so far.  

1. The grayscale image file _'assets/fillings.tif'_ is a dental X-ray corrupted by noise.  Find how many fills this patient has and their sizes in number of pixels.

2. The file _'assets/palm.tif'_ is a palm print image in grayscale. Produce an output image that contains the main lines without all the underlining non-characteristic lines.

3. The file _'assets/normal-blood.png'_ is a microscope image of red blood cells. Using various techniques you have learned, write a Matlab .m script to count the number of red blood cells.

---
## DRAW Week Assessment
---

The first half of this module is assessed on your effort in completing Lab 1 to Lab 4.  This is done through your repo or "logbook", which should record what you have done in Lab 1 to Lab 4, including explanations and reflections on observations.  

This assessment accounts for 15% of the module.  The preferred route of submitting your logbook is through GitHub, but you may use other tools such as Notion or Obsidian.  You must complete the [SURVEY](https://forms.cloud.microsoft/e/mgcDRn9QdM) and grant me access to them.  My GitHub account name is 'pykc'.

The deadline for this is **16.00 on Friday 13 February 2026**.  
