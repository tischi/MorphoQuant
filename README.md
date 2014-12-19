# Morphoquant

MATLAB-based software for detection and quantification of locally bright structures in fluorescence microscopy images (of cells). 

The software comes with a graphical user interface: no programming or MATLAB skills required!

The functionality of Morphoquant is very much "to the point" (if you need something more flexible I'd recommend CellProfiler on www.cellprofiler.org).


### Author & Contact information

Christian Tischer

tischitischer@gmail.com


## Prerequisites/Installation

- you need MATLAB installed on your computer
- download all files from GitHub [https://github.com/tischi/MorphoQuant/archive/master.zip]
- load MorphoQuant_091126_JCS.m into MATLAB and run it (select "Change Folder" when MATLAB asks you to)


## Usage

### Input data


Please check the ExampleData folder!

Once you start Morphoquant you need to browse to the folder that contains you data (Note: if MorphoQuant crashes at this point, please look for and remove the parameters.mat file from the respective folder).

The input data must be tif-stacks with the following naming scheme:


	MyData.tif
	MyData-mask.tif
	MyData-mask-bg.tif

	MyData02.tif
	MyData02-mask.tif
	MyData02-mask-bg.tif

	…


, where "MyData" and "MyData02" could be replaced by anything you like. 

Morphoquant (MQ) will analyse each slice in each tif stack and will compute information such as number of identified objects "per cell". In order for MQ to know where the cells and the image background are you must provide two additional files for each input file. The additional files must start with the same name as the corresponding input file but end on "-mask.tif" and "-mask-bg.tif" (see above). 


Both files must be single slice tif images where pixels with gray values larger than zero are assigned to cells (in the "mask" image) or background (in the "mask-bg" image).    Such images can easily produced with ImageJ. Note that there is no automated cell or background segmentation in Morphoquant. 



### Adjusting parameter settings

There are several parameters that need to be adapted to your images

##### Testing current settings

You can test the current paramaters by selecting a data set in the window on the left part of the graphical user interface (GUI) and by selecting the slice that you want to test (bottom part of GUI) and by clicking [Test].

A window with the segmentation results will pop up (you may need to zoom in to see all the lines properly); "large" structures will be painted red and "small" structures will be painted green. The cell outlines will be in blue.

##### Object detection: "Find structures" and "Find dots"

Morphoquant uses to distinct image analysis algorithms to detect (larger) structures of arbitray shape and (small) dot-like structures. For both kind of structures you need to specify the typical width in pixel units as well as a threshold. The units of the thresholds are in "signal/noise", where the signal is defined as how much brighter the object is than the local background and the noise measured as the random intensity fluctuations in the local object neighborhood. The values have to be entered separated by a space. Simply try different settings (see above). 

##### Line suppresion 

Morphoquant was developed for detecting local accumulations of proteins that are also partly localised to the endoplasmic reticulum (ER); thus there often was a bright signal localised to the nuclear envelope. To distinguish such "line-like" signal from more roundish structures I implemented a "line-detection" algorithm. The idea is that objects scoring high in the line-detection should be discarded. The lower you put the treshold, the more objects are discarded. 


Quite often you may actually *not* want to use this feature. To switch of the "Linear object suppression" simply put two zeros [0 0] as parameters.


##### Distinguish small and large

The parameter specifies the maximal size (in pixel area) for an object to be considered as "small"; accoring to this MorphoQuant will sort your results into small and large objects.

##### Reject 

Only objects within the specified range (pixel area) will be considered for the analysis. Typically one requires a minimal size of 4-6 pixels to reject noise. For the maximal parameter you could put something very large (1000000000) if you don't want to reject large objects at all.

##### Rescale the image by a factor

Often confocal images are oversampled and quite noisy. A nice trick to enhance object detection can be to down-sample the image by averaging neighboring pixels. This reduces noise and also enhances the processing time. Note: if you choose this option you have to adjust all parameters dealing with length, width or area accordingly.



### Output

To start the analysis click [Analyze]. The output will be stored in the same folder as the input data.

For each input file there be an output file containing segmentation images, ending on --MQ-seg.tif. The images are 8-bit with  "small" objects having gray values of 200 and the "large" objects having gray values of 100. The cell outlines are 50 gray values (to be viewed in ImageJ).

In addition, for each input file there will be a tab-delimited spreadsheet file ending on --MQ-results.txt (to be viewed in Excel).

The text file contain the following measurements (each row corresponds to one cell, ):

##### iImage	
Number of slice in the tif stack.

##### iCell
Number of cell, corresponding to numbers in segmentation images. If it says here "mean", "median", or "std", it means that these summary statistics are computed for all cells in the slice.


##### areaCell
Number of pixels in the cell.

##### intensTotCell
Sum-intensity in the cell after subtraction of median??? background intensity from whole image (measured in the region provided in the "-mask-bg" image).

##### nSegSmallForeground
Number of "small" structures detected in the cell.

##### areaFracSmallForeground	
Fraction of pixels positive for "small" structures. To obtain the pixel area you have to multiply with "areaCell". To get the mean pixel area of each object you have to multiply by "areaCell" and devide by nSegSmallForeground.

##### intensFracSmallForeground
Fraction of intensity in the with "small" structures, after subjecting the image to a top-hat filter, using the "Width" parameter in "Find structures" as diameter of the erosion and dilation operations. To obtain the average sum intensity area you have to multiply with "areaCell". To get the mean pixel area of each object you have to multiply by "areaCell" and devide by nSegSmallForeground.


##### nSegLargeForeground	
…as decribed for "small" objects, but now for "large objects"

##### areaFracLargeForeground
…as decribed for "small" objects, but now for "large objects"

##### intensFracLargeForeground
…as decribed for "small" objects, but now for "large objects"

##### areaFracLargestObject
Fraction of pixels occupied by the largest of all detected objects in the respective cell. 

##### intensFracLargestObjectForeground
The fraction of intensity in the largest detected object in the respective cell. The sum intensity in the largest object is measured in the "Foreground" image, i.e. after subjecting the image to a top-hat filter, using the "Width" parameter in "Find structures" as diameter of the erosion and dilation operations	.

##### intensFracBackground	
Fraction of intensity in the cellular "background" signal. The "background" signal in each cell is defined as the integrated intensity in the morphological opening of the background corrected raw data (using the "Width" parameter in "Find structures" as diameter of the erosion and dilation operations). Bascially, this is the fraction of intensity that is not localised to locally bright structures, e.g. the "unbound cytoplasmic signal".













 







