# Formatting BCS70 UKDS EUL Data Files

The purpose of this code is to take zipped Stata BCS70 files downloaded from the UK Data Service (End User Licence Version) and to arrange these files in a set of per-sweep folders to make using BCS70 data easier. The code further creates a lookup dictionary of BCS70 variables from the files (in csv and R formats), which can be used to search through the data efficiently - the R format lookup file contains a values label field which can be especially useful to use.

To use the code you will need R (https://cran.r-project.org/) and RStudio (https://posit.co/download/rstudio-desktop/) installed. You will only need to use R and RStudio once, so if you are unfamiliar with the programme, you can run the code and then work in Stata.

## Instructions
1. Go to the UKDS and download the individual zipped Stata folders. Keep these folders zipped and place them into the 'Zipped' folder.
2. Double click the 'BCS70 UKDS.Rproj' file. This will open RStudio and automatically set the working directory to the folder which contains the 'BCS70 UKDS.Rproj' file, so you won't need to change any file paths.
3. Run the code. You will need the 'tidyverse' and 'labelled' packages installed. If you do not have these installed, uncomment the first line and run it.

After the code is finished, you will have a set of new folders. The name of the folders refers to the sweep the data were collected. 'xwave' refers to the cross-wave files (e.g., bcs70_response_1970-2016.dta and bcs70_activity_histories_eul.dta). 'Zipped' contains the zipped folders. 'UKDS' contains the unzipped UKDS files (including user guides and other documentation).

This code was created using UKDS files downloaded on 26/05/2023. It works for UKDS assets 2666, 2690, 2699, 3535, 3723, 3833, 4715, 5225, 5558, 5585, 5641, 6095, 6557, 6941, 6943, 7064, 7473, 8288, 8547, 8611, 8618. 

If you have any issues using this code, please contact me at [liam.wright@ucl.ac.uk](mailto:liam.wright@ucl.ac.uk)