Data mining project
Gemastik 10
Dataset will be taken from kaggle competition repository AMS 2013-2014 Solar Energy Prediction Contest
link : https://www.kaggle.com/c/ams-2014-solar-energy-prediction-contest

Input data is huge, please download in kaggle instead.
Put input data in ./input/

train.csv contain the table of daily incoming solar energy in (J m-2)
The column represent 98 mesonet (solar plant) site
The row represent date

station_info.csv contain the latitude, longitude and elevation for each mesonet

gefs_elevations.nc contain elevation for each GEFS grid point

anything in gefs_train.zip/tar.gz contain variable (apcp_sfc, dlwrf_sfc, etc) in 5 dimentional array
1st dimension is time (date of measurement)
2nd dimension is latitude (latitude of the grid)
3rd dimension is longitude (longitude of the grid)
4th dimension is ensemble (what the fuck is this?)
5th dimension is hour (5 in a day)