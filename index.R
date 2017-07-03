# R script
# NOTE: uncomment str({var}) to inspect var, use print.nc instead for NetCDF data
# Each different section separated by 3 newline



# required library
library('RNetCDF')
# library('dplyr')



# Read train data
train <- read.csv('./input/train.csv')
# str(train)

# The plan: train1 and train2 used as training data, train3 used as test data
# split train data
train1 <- train[floor(train$Date/10000)<1999,]
train2 <- train[floor(train$Date/10000)>=1999 & floor(train$Date/10000)<2004,]
train3 <- train[floor(train$Date/10000)>=2004,]
# str(train1)
# str(train2)
# str(train3)



# Get station data
station_info <- read.csv('./input/station_info.csv')
# str(station_info)

# convert station longitude to use positive degrees from the Prime Meridian (GEFS use this)
station_info$elon <- station_info$elon+360



# Get GEFS Data
gefs_elevations <- open.nc('./input/gefs_elevations.nc')
# print.nc(gefs_elevations)

# Read attribute data from GEFS
# What is this? ans: use print.nc to find out
apcp_sfc <- open.nc('./input/train/apcp_sfc_latlon_subset_19940101_20071231.nc')
dlwrf_sfc <- open.nc('./input/train/dlwrf_sfc_latlon_subset_19940101_20071231.nc')
dswrf_sfc <- open.nc('./input/train/dswrf_sfc_latlon_subset_19940101_20071231.nc')
pres_msl <- open.nc('./input/train/pres_msl_latlon_subset_19940101_20071231.nc')
pwat_eatm <- open.nc('./input/train/pwat_eatm_latlon_subset_19940101_20071231.nc')
spfh_2m <- open.nc('./input/train/spfh_2m_latlon_subset_19940101_20071231.nc')
tcdc_eatm <- open.nc('./input/train/tcdc_eatm_latlon_subset_19940101_20071231.nc')
tcolc_eatm <- open.nc('./input/train/tcolc_eatm_latlon_subset_19940101_20071231.nc')
tmax_2m <- open.nc('./input/train/tmax_2m_latlon_subset_19940101_20071231.nc')
tmin_2m <- open.nc('./input/train/tmin_2m_latlon_subset_19940101_20071231.nc')
tmp_2m <- open.nc('./input/train/tmp_2m_latlon_subset_19940101_20071231.nc')
tmp_sfc <- open.nc('./input/train/tmp_sfc_latlon_subset_19940101_20071231.nc')
ulwrf_sfc <- open.nc('./input/train/ulwrf_sfc_latlon_subset_19940101_20071231.nc')
ulwrf_tatm <- open.nc('./input/train/ulwrf_tatm_latlon_subset_19940101_20071231.nc')
uswrf_sfc <- open.nc('./input/train/uswrf_sfc_latlon_subset_19940101_20071231.nc')

# Get GEFS longitude and latitude data
gefs_longitude <- var.get.nc(apcp_sfc, "lon")
gefs_latitude <- var.get.nc(apcp_sfc, "lat")

# Convert GEFS longitude and latitude data to data.frame
gefs_longitude <- as.data.frame(gefs_longitude)
gefs_latitude <- as.data.frame(gefs_latitude)
# str(gefs_longitude)
# str(gefs_latitude)


# TO DO, make a function to determine 4 closest GEFS from a station


# junk area, not important but don't delete it

# print.nc(gefs_elevations)
# var.get.nc(gefs_elevations, "latitude")
# var.get.nc(gefs_elevations, "longitude")

# apcp_sfc
# print.nc(apcp_sfc)
# att.get.nc(apcp_sfc, "lat", "actual_range")
# var.get.nc(apcp_sfc, "ens")
# var.get.nc(apcp_sfc, "lat")
# var.get.nc(apcp_sfc, "Total_precipitation", c(1,1,1,1,1), c(NA,NA,1,1,1))
# var.get.nc(apcp_sfc, "Total_precipitation", c(1,1,1,11,1), c(NA,NA,1,1,1))
