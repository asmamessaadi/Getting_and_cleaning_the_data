#http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#Here are the data for the project:
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

#Steps:
#   Merges the training and the test sets to create one data set.
#   Extracts only the measurements on the mean and standard deviation for each measurement.
#   Uses descriptive activity names to name the activities in the data set
#   Appropriately labels the data set with descriptive variable names.
#   From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject



#download dataset

#url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#dest_file<- paste(getwd(), "smartphone_dataset.zip", sep ="/")
#data_zip<- download.file(url, destfile = dest_file, method = "curl")
#unzip(dest_file,exdir= getwd())
#setwd("paste(getwd(), "UCI HAR Dataset", sep = "/")

library("data.table")
# Load: activity labels
activity_labels <- read.table("activity_labels.txt")[,2]


# Load: data column names
features <- read.table("features.txt")[,2]

# Load   data.
x_test <- read.table("test/X_test.txt")
y_test <- read.table("test/y_test.txt")
x_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")
subj_train <- read.table("train/subject_train.txt")

#View data
#head(x_test)
#head(y_test)
subj_test <- read.table("test/subject_test.txt")
#names(x_test)<- features

#  Merges the training and the test sets to create one data set.
my_dataSet <- rbind(x_train,x_test)

# Extracts only the measurements on the mean and standard deviation for each measurement. 
# Create a vector of only mean and std, use the vector to subset.
mean_std_vect <- grep("mean()|std()", features) 
dataSet <- my_dataSet[,mean_std_vect]

# Load activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subj_test) = "subject"
test_data <- cbind(as.data.table(subj_test), y_test, x_test)

train_data <- cbind(as.data.table(subj_train), y_train, x_train)

# Merge test and train data
data = rbind(test_data, train_data, fill =TRUE)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt")