#Team Hakken en Zagen
#12 Januari
#Mark ten Vregelaar, Jos Goris

#Import libraries
library(raster)
library(rgdal)
library(rasterVis)

#Set and create input and output folder
ifolder <- "./data"
ofolder <- "./output"
dir.create(ifolder, showWarnings = FALSE)
dir.create(ofolder, showWarnings = FALSE)

inputZip <- list.files(path = 'data', pattern = '^.*//.zip$')
if (length(inputZip)==0){
  #Download the NDVI's
  download.file(url = 'https://github.com/GeoScripting-WUR/VectorRaster/raw/gh-pages/data/MODIS.zip', destfile = './data/NDVI_data.zip', method = 'wget')
}
unzip('data/NDVI_data.zip', exdir = ifolder)

#Get the municipality boundaries
nlCity <- raster::getData('GADM',country='NLD', level=2, path = ifolder)

#remove rows with NA
nlCity@data <- nlCity@data[!is.na(nlCity$NAME_2),]

#List the NDVI files 
NDVIlist <- list.files(path = ifolder, pattern = '+.grd$', full.names = TRUE)

#Stack the NDVI's
NDVI_12 <- stack(NDVIlist)

#Reproject the municipailties to that of the NDVI's
nlCityRP <- spTransform(nlCity, CRS(proj4string(NDVI_12)))

#Mask
NDVI_12 <- mask(NDVI_12, nlCityRP)

#Select January, August and Mean
NDVI_jan <- NDVI_12[[1]]
NDVI_aug <- NDVI_12[[8]]
NDVI_mean <- calc(NDVI_12, mean)

#Extract the NDVIs
NDVIcali_jan <- extract(NDVI_jan, nlCityRP, df = TRUE, fun = mean, na.rm = TRUE)
NDVIcali_aug <- extract(NDVI_aug, nlCityRP, df = TRUE, fun = mean, na.rm = TRUE)
NDVIcali_mean <- extract(NDVI_mean, nlCityRP, df = TRUE, fun = mean, na.rm = TRUE)

#Combine the NDVI's to the cities
cities <- cbind(nlCityRP$NAME_2, NDVIcali_jan$January, NDVIcali_aug$August, NDVIcali_mean$layer)

#Name the columns
my_vars <- c("Cities","January","August","mean")
colnames(cities) <- my_vars

#Find max
max_jan <- cities[which.max(cities[,"January"]),1]
max_aug <- cities[which.max(cities[,"August"]),1]
max_mean <- cities[which.max(cities[,"mean"]),1]

