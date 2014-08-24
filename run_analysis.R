#!/usr/bin/Rscript --vanilla

library(plyr)
#required for useful functions ddply (and colwise)

#set up path to top level of data
UCIHAR.datapath <- "./UCI HAR Dataset"

#we're dealing with some distributed files, so define a convenience function
#for easily testing for presence of a required file and notifying the user
#The user is expected to then resolve the issue.
fcheck <- function(filename) {
    if (!file.exists(filename)) {
        stop(sprintf("Cannot find file %s", filename))
    }
}

#feature names in
feature.name.file <- file.path(UCIHAR.datapath, "features.txt")
fcheck(feature.name.file)
#they will be useful for reading in data, so read them in now
feature.names <- read.table(feature.name.file, header=FALSE, colClasses="character", nrows=570)$V2

#define function for reading in training/test data
readData <- function(partition, maxn) {
    subject.labels.file     <- file.path(UCIHAR.datapath, partition, sprintf("subject_%s.txt", partition))
    activity.labels.file    <- file.path(UCIHAR.datapath, partition, sprintf("y_%s.txt", partition))
    features.file           <- file.path(UCIHAR.datapath, partition, sprintf("X_%s.txt", partition))
    fcheck(subject.labels.file)
    fcheck(activity.labels.file)
    fcheck(features.file)

#read data
#specifying colClasses and an appropriate nrows greatly speeds things up
#handy to name feature variables at the same time
#NB we retain the special characters in the feature names (especially minus signs) to retain consistency with the
#original data set. We do not use any formulas etc. that could have a problem with this, but
#this could change in the future (and check.names set to TRUE). This would not break this script, but results
#in "less appealing" variable names (without faffing about).
    features <- read.table(features.file, header=FALSE, col.names=feature.names, check.names=FALSE, 
                    colClasses="numeric", nrows=maxn)

    dims            <- dim(features)
    nrow.features   <- dims[1]
    ncol.features   <- dims[2]

#get the subject and activity labels
    subject.labels  <- scan(subject.labels.file, nmax=maxn, quiet=TRUE)
    activity.labels <- scan(activity.labels.file, nmax=maxn, quiet=TRUE)
    num.subjects <- length(subject.labels)
    num.activity <- length(activity.labels)
    if (nrow.features != num.subjects | nrow.features != num.activity) {
        stop(sprintf("inconsistent observations numbers in partition: %s", partition))
    }

#add the variables to the data frame
    features <- cbind(Subject=subject.labels, Activity=activity.labels, Partition=rep(partition, nrow.features), features)

#return data frame
    return(features)
}

#actually read in the train and test data
train.data  <- readData("train", 7500)
test.data   <- readData("test", 3000)
#and combine into a single data frame
all.data    <- rbind(train.data, test.data)
#remove the intermediate, separate data frames
rm(train.data, test.data)

#TODO get activity number to name conversions!
#now to give meaningful names to the activity labels (currently integers)
activity.names.file <- file.path(UCIHAR.datapath, "activity_labels.txt")
fcheck(activity.names.file)
activity.names      <- read.table(activity.names.file, header=FALSE, 
                                    colClasses=c("integer", "character"), nrows=max(all.data$Activity))
#now we can transform the data frame activities to the correct factor 
all.data$Activity <- factor(all.data$Activity, activity.names$V1, activity.names$V2)

#We only want the mean and sd (std) results, so
desired.names   <- names(all.data)[grepl("mean", names(all.data), ignore.case=TRUE) | 
                                    grepl("std", names(all.data), ignore.case=TRUE)]
#(no longer care about Partition and it makes the next step more straightforward
extract.names   <- c("Subject", "Activity", desired.names) 
all.data        <- all.data[, extract.names]


#uses ddply and colwise functions from package plyr
#ddply is just so damn convenient here!
#We get our grouping variables back as columns and the result is a data frame
summary.data <- ddply(all.data, .(Subject, Activity), colwise(mean))
#it's a good idea to rename the data variables to reflect the fact that we've applied 
#a transformation (mean) to them
output.names <- names(summary.data)
#(use unique in case there's already a var that combines mean and std)
to.change <- unique(c(grep("mean", names(all.data), ignore.case=TRUE),
                grep("std", names(all.data), ignore.case=TRUE)))
var.names <- output.names[to.change]
var.names <- sprintf("%s.Group_Mean", var.names)
output.names[to.change] <- var.names
names(summary.data) <- output.names
write.table(summary.data, row.name=FALSE, file="activitySubjectMeans.txt")
