###Getting and Cleaning Data Course Project README

This readme covers the use of the `run_analysis.R script.R`

The script is standalone and can either be `source`d from within an R session, or run as an
executable from a \*nix-like system (requiring Rscript in the path specified on the first line).

The script assumes the UCI HAR Dataset has been unzipped in the current working directory, although
the path to the directory can be changed using the UCIHAR.datapath variable.

The script requires the plyr package to be installed on the user's system.
The script checks for the presence (in the specified location) of any required input files prior
to reading them, and stops with an error message to inform the user. It is assumed the user is
responsible for ensuring the data set exists in the correct location.

The script internally uses a single function to read in both the train and test data sets, as the
directory structures are parallel, and then concatenates them into a single data frame.

All variable names and character activity names are taken from the supplied files and are not
specified in the script.

Having combined train and test data into a single data frame, the subset of required variables is
taken and then summary statistic (mean) for each is calculated grouped over Subject and Activity.
This produces a new data frame which is written to text file.
