# Download file into /data directory
if(!file.exists("./data")){dir.create("./data")}
downloadUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(downloadUrl,destfile="./data/Dataset.zip")

# Unzip file
unzip(zipfile="./data/Dataset.zip",exdir="./data")

path_rf <- file.path("./data" , "UCI HAR Dataset")
files <- list.files(path_rf , recursive=TRUE)

# Read files
Y_Test <- read.table(file.path(path_rf,"test","y_test.txt"),header=FALSE)
Y_Train <- read.table(file.path(path_rf,"train","y_train.txt"),header=FALSE)
X_Test <- read.table(file.path(path_rf,"test","X_test.txt"),header=FALSE)
X_Train <- read.table(file.path(path_rf,"train","X_train.txt"),header=FALSE)
Sub_Test <-read.table(file.path(path_rf,"test","subject_test.txt"),header=FALSE)
Sub_Train <- read.table(file.path(path_rf,"train","subject_train.txt"),header=FALSE)

# Merge to create one dataset
data_Y <- rbind(Y_Test , Y_Train)
data_X <- rbind(X_Test,X_Train)
data_Sub <- rbind(Sub_Test , Sub_Train)

names(data_Sub) <- c("Subject")
names(data_Y) <- c("Activity")
data_X_names <- read.table(file.path(path_rf,"features.txt"),head=FALSE)
names(data_X) <- data_X_names$V2

Data <- cbind(data_Sub , data_Y)
All_Data <- cbind(data_X , Data)

# Extract only mean and standard deviation
Sub_Features_Names <- data_X_names$V2[grep("mean\\(\\)|std\\(\\)",data_X_names$V2)]
Selected_Names <- c(as.character(Sub_Features_Names),"Subject","Activity")
All_Data <- subset(All_Data,select=Selected_Names)

# Match activity names in dataset
Activity_Labels <- read.table(file.path(path_rf,"activity_labels.txt"),header=FALSE)
All_Data$Activity <- factor(All_Data$Activity);
All_Data$Activity <- factor(All_Data$Activity,labels=as.character(Activity_Labels$V2))

# Name dataset with descriptive variable names
names(All_Data) <- gsub("^t","time", names(All_Data))
names(All_Data) <- gsub("^f","frequency", names(All_Data))
names(All_Data) <- gsub("Acc","Accelerometer", names(All_Data))
names(All_Data) <- gsub("Gyro","Gyroscope", names(All_Data))
names(All_Data) <- gsub("Mag","Magnitude", names(All_Data))
names(All_Data) <- gsub("BodyBody","Body", names(All_Data))

# Create the tidy dataset
library(plyr);
Tidy_Data <- aggregate(. ~Subject + Activity, All_Data,mean)
Tidy_Data <- Tidy_Data[order(Tidy_Data$Subject,Tidy_Data$Activity),]

write.table(Tidy_Data,file= "TidyData.txt",row.name = FALSE)
