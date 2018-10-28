# fiji_IMB_DualProjectionTypeScript

IMB_Brightfield-Fluorescence-Projection-Script

Developed by Dr Nicholas Condon 
ACRF:Cancer Biology Imaging Facility, 
Institute for Molecular Biosciences, The University of Queensland
Brisbane, Australia 2018

This script is written in the ImageJ1 Macro Language.


Background
----
This script is designed to project multiple dimension files that contain both bright-field and fluorescence channels. The logic for this is, Bright-field images should be ‘minimum’ projected because of their black foreground, while fluorescence images should be maximum/sum/average projected because they have a white foreground.

This script can work on multiple files within a single directory and as long as the format is Bio-formats compatible,  it should run fine. (TIP: Go windowless for the format which you plan to use. To do this, navigate to Plugins>Bio-Formats>Bioformats Configuration>Formats > Windowless.)

Images being imported can be 1/2/3/4 channel files. The script will split channels and treat each one with different projection parameters based upon the users input. If your images have 2 channels, turn off channel 3/4 by setting it to ‘No Data’


Running the script
----
The first dialog box to appear explains the script, acknowledges the creator and the ACRF:Cancer Biology Imaging Facility.

The second dialog to open will warn the user to select the working directory of your files and to take note of the file extension that they wish to process.

The script will prompt you for the channels in your images asking whether they have ‘Fluorescence’, ‘Brightfield’ or ‘No Data’ . Select the appropriate number of channels for your images. For fluorescence images you can choose the projection type, however for Brightfield designated images, minimum will be used.

The file extension is actually a file ‘filter’ running the command ‘ends with’ which means for example .tif may be different from .txt in your folder only opening .tif files. Perhaps you wish to process files in a folder containing <Filename>.tif and <Filename>+deconvolved.tif you could enter in the box here deconvolved.tif to select only those files.

The script will always give you individual channels saved out as a .tif file, however you can select other processes to be included, these include adding a scale bar, converting files to RGB before saving and Re-merging channels back into one tif. (Note ImageJ/FIJI sometimes struggles merging 4 channel images in macro mode).

If you select the option for adding a scale bar the following dialog will open. This loosely emulates the default scale bar menu in FIJI. It asks the user to include the width (in microns), height, colour and location of the scale bar. Note a warning will appear if the selected image format is .tif as if it has been converted from another format the scale information may have been lost. It still runs, however the user should be aware that a potential issue may arise.

The final dialog box is an alert to the user that the batch is completed. 


Output files
----
Files are put into a results directory called “Results+<date&time> within the chosen working directory. Files will be saved as either a .tif or .txt for the log file. Original filenames are kept and have tags appended to them based upon the chosen parameters.

A text file called log.txt is included which has the chosen parameters and date and time of the run.
