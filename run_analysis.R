#!/usr/bin/Rscript --vanilla

#set up path to top level of data
UCIHAR.datapath <- "./UCI HAR Dataset"

#feature names in
feature.name.file <- file.path(UCIHAR.datapath, "features.txt")
#they will be useful for reading in data, so read them in now
feature.names <- read.table(feature.name.file, header=FALSE, colClasses="character", nrows=570)$V2

#define function for reading in training/test data
readData <- function(partition, maxn) {
    subject.labels.file     <- file.path(UCIHAR.datapath, partition, sprintf("subject_%s.txt", partition))
    activity.labels.file    <- file.path(UCIHAR.datapath, partition, sprintf("y_%s.txt", partition))
    features.file           <- file.path(UCIHAR.datapath, partition, sprintf("X_%s.txt", partition))

#read data
#specifying colClasses and an appropriate nrows greatly speeds things up
#handy to name feature variables at the same time
    features <- read.table(features.file, header=FALSE, col.names=feature.names, colClasses="numeric", nrows=maxn)
    dims <- dim(features)
    nrow.features <- dims[1]
    ncol.features <- dims[2]

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

#set up training file names to read
training.subject.labels.file    <- "UCI HAR Dataset/train/subject_train.txt"
training.activity.labels.file   <- "UCI HAR Dataset/train/y_train.txt"
training.features.file          <- "UCI HAR Dataset/train/X_train.txt"

train.data  <- readData("train", 7500)
test.data   <- readData("test", 3000)
all.data    <- rbind(train.data, test.data)
rm(train.data, test.data)

#TODO get activity number to name conversions!
