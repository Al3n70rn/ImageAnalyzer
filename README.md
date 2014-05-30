ImageAnalyzer
=============

MATLAB texture analysis tool for medical images


IMAGEANALYZER USER MANUAL
Version 1.0, May 2014



1.	Downloading the application and setting up MATLAB
2.	Creating new Study
3.	Creating new ImageSeries
4.	Drawing ROIs
5.	Calculating parameters
Adding new functionality with GUIDE
Document update history


1	Downloading the application and setting up MATLAB

NOTE: MATLAB installation is required to run ImageAnalyzer.
•	Download the program code from GitHub using the Download ZIP button: https://github.com/varjojukka/ImageAnalyzer
•	There are various options for setting up the MATLAB to locate ImageAnalyzer:
  o	Extract the ZIP file content to MATLAB path directory.
  o	Extract the ZIP file content to any preferred directory and locate that directory as the MATLAB path.
  o	Extract the ZIP file content to any preferred directory and edit MATLAB shortcut properties by adding the extracted folder path to the property field "Start in". This way MATLAB will automatically locate the correct directory in start-up.
•	In MATLAB the Current Folder view should now display the ImageAnalyzer files and entering ImageAnalyzer in the Command Window will start the application and display. the ImageAnalyzer main menu module.


2	Creating new Study

•	From the ImageAnalyzer Main menu –module select New study –option under File –menu.
•	Create new study –popup will appear requesting a name to be entered for the Study.
•	Entering the name and clicking Save will open Study manager –module.
  o	Loading previously saved Study is done by selecting Load study –option under File –menu and browsing to the folder named after the Study. Selecting the *.sty file and clicking Open will load the Study and display the Study manager –module and the Visualization –module.


3	Creating new ImageSeries

•	In the Study manager –module entering the name for ImageSeries enables the Load ImageSeries –button .
NOTE: All editable text fields have to be "submitted" by pressing enter after typing the value.
•	Clicking Load ImageSeries button will open window for locating the image files.
NOTE: If no image files are visible make sure the correct file type extension is selected.
NOTE: All files from the folder can be selected by shortcut CTRL + a.
NOTE: Minimum of 2 images needs to selected for loading 
•	Select all the images/slices required for the analysis by clicking Open. Adding or removing single slices is not possible afterwards.
•	After loading the images is complete the Visualization –module is displayed.
•	Repeating this Step 3 will create additional ImageSeries entries to the Study manager –module dropdown menu which can be used to switching between them.
NOTE: From the Study manager –module information regarding the ImageSeries can be viewed and slice thickness can be adjusted.


4	Drawing ROIs

•	In the Visualization ROIs can be added by clicking the Add ROI –button 
NOTE: ROI can be only drawn to the active image axes. Active axes is denoted by the coloured boarders. Active axes can be changed by adjusting the image sliders or by clicking the image.
•	After clicking the Add ROI –button the mouse cursor will turn into a crosshair above the active axes describing that drawing is possible
•	After creating the ROI in the active axes image ROI can be resized by dragging from the edges in any of the image axes
NOTE: ROI can also be relocated by dragging
•	Click Save ROI –button when the location and shape of the ROI is complete
NOTE: Adjusting ROI name, visibility and colour may be temporarily disabled by other functionalities
•	Clicking Edit ROI –button will allow same control over the active ROI as with Add ROI
•	Clicking Copy ROI –button will duplicate the ROI that is selected active
•	Clicking Delete ROI –button will delete the ROI that is selected active
•	Clicking Import ROI –button will open file browser allowing .roi files to be imported to active ImageSeries
•	From the dropdown menu active ROI can be changed. With All ROIs –option selected clicking the Delete ROI –button will delete all ROIs. ROI visibilities can be also set for all ROIs at once using the All ROIs –option 
•	Clicking 3D –button will open a 3D visualization window containing all ROIs
 
 
5	Calculating parameters

NOTE: Minimum of one ROI for the active ImageSeries is required for Feature Extraction to be enabled.
•	From the ImageAnalyzer Main menu –module click on Select Features –option under Feature Extraction –menu.
NOTE: Study will be automatically saved when entering Feature selection –window.
•	Feature selection –window will appear. Parameters to be calculated are selected by checking the checkboxes.
•	Clicking Compute –button will start the calculation process.
•	Results are automatically saved to a single .xls file located in the Study folder specified earlier. Results from calculations of different ImageSeries of the same Study are each saved to different sheets of the same file identified with ImageSeries name.
•	Results can be opened directly by clicking Yes from the dialog appearing after the calculation and saving process has succeeded.
 

Adding new functionality with GUIDE

•	Adding new functionality require changes mainly regarding Feature selection –window defined in features.m and features.fig files.
•	First step is to add a new graphical element to the .fig file with GUIDE.
•	GUIDE is started by entering guide features.fig in the MATLAB Command Window.
•	Simplest way of adding new checkbox is to copy existing checkbox element and change the Tag and String values in the Property Editor: Tag is unique and descriptive such as checkbox_parameter1 and String is the visible text next to the element such as 'Parameter1'.
NOTE: Property Editor can be accessed in the GUIDE view by double-clicking the element.
•	The callback function of the Compute –button element contains all the functionality related to the parameter calculations.
•	To access all callback functions of features.fig open the M-code file features.m in MATLAB Editor.
•	Locate the pushbutton_compute_Callback function.
•	The for-loop processes all the ROIs and the three-dimensional currentROI variable contains the values that can be used for calculations.
•	For complex parameter calculations it is suggested that a separate M-code file with additional functions is created and placed to the features folder located in the ImageAnalyzer folder. Files lbp.m and coo3d.m can be referenced for further syntax.
•	By calling the created function (or any function available in MATLAB) the result value can be directly inserted to the resultCell to the corresponding column.  
NOTE: Make sure that the parameter value is stored in the correct column by reviewing the result .xls file after adding your own functionality. 


DOCUMENT UPDATE HISTORY

Date	Update	Identification
18.5.2014	Initial version	Jukka Varjo
		
		
		
		
		

