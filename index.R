# R script

# required library
library('RNetCDF')

# read csv data
station_info <- read.csv('./input/station_info.csv')
train <- read.csv('./input/train.csv')

# check data
str(station_info)
str(train)

# split train data
train1 <- train[1:1704,]
train2 <- train[1705:3408,]
train3 <- train[3409:5113,]

# Read NetCDF data
gefs_elevations <- open.nc('./input/gefs_elevations.nc')
apcp_sfc <- open.nc('./input/train/apcp_sfc_latlon_subset_19940101_20071231.nc')

# to do split all data for 1994-1998, 1999-2003, 2004-2007