# R script

#read csv data
station_info <- read.csv('./input/station_info.csv')
train <- read.csv('./input/train.csv')

#check data
str(station_info)
str(train)

#split train data
train1 <- train[1:1704,]
train2 <- train[1705:3408,]
train3 <- train[3409:5113,]

str(train1)
str(train2)
str(train3)
