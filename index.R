# R script
# NOTE: uncomment str({var}) to inspect var, use print.nc instead for NetCDF data
# Each different section separated by 3 newline


# Sys.setenv('MC_CORES' = 3L)

# required library
library('RNetCDF')
# library('parallel')
# library('dplyr')

# Read train data
train <- read.csv('./input/train.csv')
# str(train)

# The plan: train1 and train2 used as training data, train3 used as test data
# split train data
train1 <- train[floor(train$Date/10000)<1999,]
train2 <- train[floor(train$Date/10000)>=1999 & floor(train$Date/10000)<2004,]
train3 <- train[floor(train$Date/10000)>=2004,]
# nrow(train)
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
gefsLongitude <- var.get.nc(apcp_sfc, "lon")
gefsLatitude <- var.get.nc(apcp_sfc, "lat")


# Building station data
data <- as.data.frame(cbind(station_info$elon, station_info$nlat, station_info$elev))
colnames(data) <- c("stationLon", "stationLat", "stationLev")

# add 4 closest gefs from the station
# if neccessary (tradeoff between memory and processor)
# i choose to sacrifice memory for processor and ease of code
data$idLon1 <- sapply(data$stationLon, function(x) match(ceiling(x), gefsLongitude))
data$idLon2 <- data$idLon1+1
data$idLat1 <- sapply(data$stationLat, function(x) match(ceiling(x), gefsLatitude))
data$idLat2 <- data$idLat1+1

# add gefs latitude and longitude
data$gefsLon1 <- ceiling(data$stationLon)
data$gefsLon2 <- data$gefsLon1+1
data$gefsLat1 <- ceiling(data$stationLat)
data$gefsLat2 <- data$gefsLat1+1

# add each gefs levitation
helper <- function(lonId, latId) {
	var.get.nc(gefs_elevations, "elevation_control", c(lonId, latId), c(1,1))
}
data$gefsLev1 <- mapply(helper, data$idLon1, data$idLat1)
data$gefsLev2 <- mapply(helper, data$idLon1, data$idLat2)
data$gefsLev3 <- mapply(helper, data$idLon2, data$idLat1)
data$gefsLev4 <- mapply(helper, data$idLon2, data$idLat2)


dateId <- 1


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(apcp_sfc, "Total_precipitation", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # apcp_sfc{gefs}{hour}
# data$apcp_sfc11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$apcp_sfc12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$apcp_sfc13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$apcp_sfc14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$apcp_sfc15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$apcp_sfc21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$apcp_sfc22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$apcp_sfc23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$apcp_sfc24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$apcp_sfc25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$apcp_sfc31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$apcp_sfc32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$apcp_sfc33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$apcp_sfc34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$apcp_sfc35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$apcp_sfc41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$apcp_sfc42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$apcp_sfc43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$apcp_sfc44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$apcp_sfc45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(dlwrf_sfc, "Downward_Long-Wave_Rad_Flux", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # dlwrf_sfc{gefs}{hour}
# data$dlwrf_sfc11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$dlwrf_sfc12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$dlwrf_sfc13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$dlwrf_sfc14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$dlwrf_sfc15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$dlwrf_sfc21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$dlwrf_sfc22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$dlwrf_sfc23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$dlwrf_sfc24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$dlwrf_sfc25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$dlwrf_sfc31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$dlwrf_sfc32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$dlwrf_sfc33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$dlwrf_sfc34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$dlwrf_sfc35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$dlwrf_sfc41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$dlwrf_sfc42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$dlwrf_sfc43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$dlwrf_sfc44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$dlwrf_sfc45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(dswrf_sfc, "Downward_Short-Wave_Rad_Flux", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # dswrf_sfc{gefs}{hour}
# data$dswrf_sfc11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$dswrf_sfc12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$dswrf_sfc13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$dswrf_sfc14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$dswrf_sfc15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$dswrf_sfc21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$dswrf_sfc22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$dswrf_sfc23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$dswrf_sfc24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$dswrf_sfc25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$dswrf_sfc31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$dswrf_sfc32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$dswrf_sfc33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$dswrf_sfc34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$dswrf_sfc35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$dswrf_sfc41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$dswrf_sfc42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$dswrf_sfc43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$dswrf_sfc44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$dswrf_sfc45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(pres_msl, "Pressure", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # pres_msl{gefs}{hour}
# data$pres_msl11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$pres_msl12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$pres_msl13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$pres_msl14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$pres_msl15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$pres_msl21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$pres_msl22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$pres_msl23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$pres_msl24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$pres_msl25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$pres_msl31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$pres_msl32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$pres_msl33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$pres_msl34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$pres_msl35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$pres_msl41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$pres_msl42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$pres_msl43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$pres_msl44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$pres_msl45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)

# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(pwat_eatm, "Precipitable_water", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # pwat_eatm{gefs}{hour}
# data$pwat_eatm11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$pwat_eatm12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$pwat_eatm13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$pwat_eatm14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$pwat_eatm15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$pwat_eatm21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$pwat_eatm22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$pwat_eatm23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$pwat_eatm24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$pwat_eatm25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$pwat_eatm31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$pwat_eatm32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$pwat_eatm33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$pwat_eatm34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$pwat_eatm35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$pwat_eatm41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$pwat_eatm42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$pwat_eatm43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$pwat_eatm44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$pwat_eatm45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(spfh_2m, "Specific_humidity_height_above_ground", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # spfh_2m{gefs}{hour}
# data$spfh_2m11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$spfh_2m12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$spfh_2m13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$spfh_2m14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$spfh_2m15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$spfh_2m21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$spfh_2m22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$spfh_2m23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$spfh_2m24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$spfh_2m25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$spfh_2m31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$spfh_2m32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$spfh_2m33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$spfh_2m34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$spfh_2m35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$spfh_2m41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$spfh_2m42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$spfh_2m43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$spfh_2m44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$spfh_2m45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(tcdc_eatm, "Total_cloud_cover", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # tcdc_eatm{gefs}{hour}
# data$tcdc_eatm11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$tcdc_eatm12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$tcdc_eatm13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$tcdc_eatm14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$tcdc_eatm15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$tcdc_eatm21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$tcdc_eatm22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$tcdc_eatm23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$tcdc_eatm24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$tcdc_eatm25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$tcdc_eatm31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$tcdc_eatm32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$tcdc_eatm33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$tcdc_eatm34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$tcdc_eatm35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$tcdc_eatm41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$tcdc_eatm42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$tcdc_eatm43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$tcdc_eatm44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$tcdc_eatm45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(tcolc_eatm, "Total_Column-Integrated_Condensate", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # tcolc_eatm{gefs}{hour}
# data$tcolc_eatm11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$tcolc_eatm12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$tcolc_eatm13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$tcolc_eatm14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$tcolc_eatm15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$tcolc_eatm21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$tcolc_eatm22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$tcolc_eatm23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$tcolc_eatm24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$tcolc_eatm25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$tcolc_eatm31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$tcolc_eatm32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$tcolc_eatm33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$tcolc_eatm34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$tcolc_eatm35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$tcolc_eatm41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$tcolc_eatm42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$tcolc_eatm43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$tcolc_eatm44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$tcolc_eatm45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(tmax_2m, "Maximum_temperature", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # tmax_2m{gefs}{hour}
# data$tmax_2m11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$tmax_2m12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$tmax_2m13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$tmax_2m14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$tmax_2m15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$tmax_2m21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$tmax_2m22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$tmax_2m23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$tmax_2m24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$tmax_2m25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$tmax_2m31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$tmax_2m32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$tmax_2m33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$tmax_2m34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$tmax_2m35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$tmax_2m41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$tmax_2m42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$tmax_2m43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$tmax_2m44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$tmax_2m45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(tmin_2m, "Minimum_temperature", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # tmin_2m{gefs}{hour}
# data$tmin_2m11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$tmin_2m12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$tmin_2m13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$tmin_2m14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$tmin_2m15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$tmin_2m21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$tmin_2m22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$tmin_2m23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$tmin_2m24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$tmin_2m25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$tmin_2m31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$tmin_2m32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$tmin_2m33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$tmin_2m34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$tmin_2m35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$tmin_2m41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$tmin_2m42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$tmin_2m43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$tmin_2m44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$tmin_2m45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(tmp_2m, "Temperature_height_above_ground", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # tmp_2m{gefs}{hour}
# data$tmp_2m11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$tmp_2m12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$tmp_2m13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$tmp_2m14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$tmp_2m15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$tmp_2m21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$tmp_2m22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$tmp_2m23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$tmp_2m24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$tmp_2m25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$tmp_2m31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$tmp_2m32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$tmp_2m33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$tmp_2m34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$tmp_2m35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$tmp_2m41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$tmp_2m42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$tmp_2m43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$tmp_2m44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$tmp_2m45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(tmp_sfc, "Temperature_surface", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # tmp_sfc{gefs}{hour}
# data$tmp_sfc11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$tmp_sfc12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$tmp_sfc13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$tmp_sfc14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$tmp_sfc15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$tmp_sfc21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$tmp_sfc22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$tmp_sfc23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$tmp_sfc24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$tmp_sfc25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$tmp_sfc31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$tmp_sfc32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$tmp_sfc33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$tmp_sfc34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$tmp_sfc35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$tmp_sfc41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$tmp_sfc42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$tmp_sfc43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$tmp_sfc44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$tmp_sfc45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(ulwrf_sfc, "Upward_Long-Wave_Rad_Flux_surface", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # ulwrf_sfc{gefs}{hour}
# data$ulwrf_sfc11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$ulwrf_sfc12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$ulwrf_sfc13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$ulwrf_sfc14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$ulwrf_sfc15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$ulwrf_sfc21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$ulwrf_sfc22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$ulwrf_sfc23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$ulwrf_sfc24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$ulwrf_sfc25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$ulwrf_sfc31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$ulwrf_sfc32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$ulwrf_sfc33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$ulwrf_sfc34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$ulwrf_sfc35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$ulwrf_sfc41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$ulwrf_sfc42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$ulwrf_sfc43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$ulwrf_sfc44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$ulwrf_sfc45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(ulwrf_tatm, "Upward_Long-Wave_Rad_Flux", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # ulwrf_tatm{gefs}{hour}
# data$ulwrf_tatm11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$ulwrf_tatm12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$ulwrf_tatm13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$ulwrf_tatm14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$ulwrf_tatm15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$ulwrf_tatm21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$ulwrf_tatm22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$ulwrf_tatm23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$ulwrf_tatm24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$ulwrf_tatm25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$ulwrf_tatm31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$ulwrf_tatm32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$ulwrf_tatm33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$ulwrf_tatm34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$ulwrf_tatm35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$ulwrf_tatm41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$ulwrf_tatm42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$ulwrf_tatm43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$ulwrf_tatm44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$ulwrf_tatm45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)


# helper <- function(lonId, latId, hourId, ensId = 1) {
# 	var.get.nc(uswrf_sfc, "Upward_Short-Wave_Rad_Flux", c(lonId, latId, hourId, ensId, dateId), c(1,1,1,1,1))[1]
# }

# # uswrf_sfc{gefs}{hour}
# data$uswrf_sfc11 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 1)
# data$uswrf_sfc12 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 2)
# data$uswrf_sfc13 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 3)
# data$uswrf_sfc14 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 4)
# data$uswrf_sfc15 <- mapply(helper, lonId = data$idLon1, latId = data$idLat1, hour = 5)

# data$uswrf_sfc21 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 1)
# data$uswrf_sfc22 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 2)
# data$uswrf_sfc23 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 3)
# data$uswrf_sfc24 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 4)
# data$uswrf_sfc25 <- mapply(helper, lonId = data$idLon1, latId = data$idLat2, hour = 5)

# data$uswrf_sfc31 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 1)
# data$uswrf_sfc32 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 2)
# data$uswrf_sfc33 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 3)
# data$uswrf_sfc34 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 4)
# data$uswrf_sfc35 <- mapply(helper, lonId = data$idLon2, latId = data$idLat1, hour = 5)

# data$uswrf_sfc41 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 1)
# data$uswrf_sfc42 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 2)
# data$uswrf_sfc43 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 3)
# data$uswrf_sfc44 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 4)
# data$uswrf_sfc45 <- mapply(helper, lonId = data$idLon2, latId = data$idLat2, hour = 5)

# drops <- c(
# 	"stationLon",
# 	"stationLat",
# 	# "stationLev",
# 	"idLon1",
# 	"idLon2",
# 	"idLat1",
# 	"idLat2",
# 	"gefsLon1",
# 	"gefsLon2",
# 	"gefsLat1",
# 	"gefsLat2",
# 	"gefsLev1",
# 	"gefsLev2",
# 	"gefsLev3",
# 	"gefsLev4")

# # drops <- c("stationLon",
# # 	"stationLat",
# # 	"stationLev",
# # 	"idLon1",
# # 	"idLon2",
# # 	"idLat1",
# # 	"idLat2",
# # 	"gefsLon1",
# # 	"gefsLon2",
# # 	"gefsLat1",
# # 	"gefsLat2",
# # 	"gefsLev1",
# # 	"gefsLev2",
# # 	"gefsLev3",
# # 	"gefsLev4")

# data <- data[ , !(names(data) %in% drops)]

# saveRDS(data, file = "data.Rda")

# str(data)
proc.time()

# print.nc(uswrf_sfc)
# var.get.nc(apcp_sfc, "ens", c(1), c(1))
# 





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
# class(apcp_sfc)