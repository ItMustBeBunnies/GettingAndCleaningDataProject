##UCI HAR dataset codebook

This describes the variables and the processing performing in analysis of the data.

Very simply, all input originates from the UCI HAR dataset itself.
Specifically, the file `features_info.txt` describes the meanings of each of the variable names.
These are the variable names (of the feature vector) given in the file `features.txt`.

The processing that has been applied is to:

1. extract all variables that describe a mean or standard deviation
of a quantity (feature variable names that contain "mean" or "std"),
2. group each of these over the subject and activity labels,
3. and calculate the mean of each group.

The column names in the output relate exactly to the input feature column names, but for
appending ".Group_Mean" to the variable name to denote that the quantity is the mean over
the subject/activity grouping.
