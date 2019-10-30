########################################################################################
# Summary: Analyzing GAGES-II data
# Date: October 30, 2019
# Exercise created by Dr. Sheila Saia, http://sheilasaia.rbind.io/,
# https://github.com/sheilasaia/sf-workshop-bae590, and modified by Dr. Natalie Nelson
########################################################################################

# Clear workspace, install, and load packages ----
rm(list=ls(all=TRUE))
# install.packages("sf")
# install.packages("ggpspatial")
library(tidyverse)
library(sf)
library(ggspatial)

# Load and inspect data ----
# Load the southeast states shapefile: note that you only need to read the .shp file, but the other two shapefile files (.shx, .dbf) need to be in the same directory as the .shp file. R is reading .shp, .shx, and .dbf behind the scenes.
se_states <- read_sf("spatial_data/southeast_state_bounds_SIMPLE.shp")

### Inspect se_states
se_states
str(se_states)
class(se_states)
colnames(se_states)
head(se_states)

## Use st_crs() to check coordinate reference system (CRS)


## Let's re-project se_states to EPSG = 32019
## https://epsg.io/

## Use st_crs() again to check CRS
st_crs(se_states)

## Plot SE state boundaries


## Create a spatial tibble that only includes NC


### Read NC river basin boundaries shapefile
nc_basins <- read_sf("spatial_data/river_basins_SIMPLE.shp") %>% 
  st_transform(32019)
## Use st_crs() to check CRS

## Inspect
head(nc_basins)
str(nc_basins)

## Plot NC river basins


## Create a spatial tibble that only includes the Cape Fear River basin


## Plot the Cape Fear basin on top of NC


### Read stream gage shapefile and define projection and set CRS
gages <- 
  read_sf("spatial_data/gagesII_9322_sept30_2011.shp") %>%
  st_transform(32019) 
## Use st_crs() to check CRS
st_crs(gages)
## Inspect gages object
head(gages)
str(gages)

## Plot gages
gages %>%
  ggplot() +
  geom_sf()

#### Read gage attribute data
# basin_id_data <- read_csv("tabular_data/conterm_basinid.txt")
climate_data <- read_csv("tabular_data/conterm_climate.txt")
# geology_data <- read_csv("tabular_data/conterm_geology.txt")
# hydrology_data <- read_csv("tabular_data/conterm_hydro.txt")
# topo_data <- read_csv("tabular_data/conterm_topo.txt")

## Inspect climate attribute data
str(climate_data)
head(climate_data)
# The main column we're interested in is PPTAVG_BASIN (average precipitation in gage sub-basin)

# Using sf functions for geospatial data manipulation ----
### Separate geometry using st_geometry()


### Separate attributes using st_set_geometry(NULL)


#### Let's save the geometry for the NC shapefile separately
nc_geom <- st_geometry(nc)

### Calculate areas of nc_geom and se_states using st_area()


### Calculate buffer using st_buffer()


## Plot the buffer 
nc %>%
  ggplot() +
  geom_sf() +
  geom_sf(data = nc_buffer, fill = NA, color = "red") +
  theme_bw()

### Remove a state from se_states using st_difference()


## Create a map without GA
se_states_geom_without_ga %>%
  ggplot() +
  geom_sf() +
  theme_bw()

### Create a tibble that includes the gages and NC river basins
# Could be useful for determining which river basins each of the points are in
# Spatial join!


## How many gages are there per NC river basin?


### Select gages in NC using st_intersection()


## Plot nc_gages
ggplot() +
  geom_sf(data = nc_basins) +
  geom_sf(data = nc_gages, size = 2, alpha = 0.5) +
  theme_bw()

### Select gages inside the Cape Fear River watershed
cape_fear_gages <- st_intersection(gages, st_geometry(cape_fear_basin))

## Plot gages in the Cape Fear River basin
ggplot() +
  geom_sf(data = nc_geom) +
  geom_sf(data = cape_fear_basin, color = "red") +
  geom_sf(data = cape_fear_gages, size = 2, alpha = 0.5) +
  theme_bw()

## Plot Cape Fear River basin gages colored by reference or non-reference
# reference = minimal to no human impact on streamflow (e.g., forested with no development)
# non-reference = human impact on streamflow (e.g., has an urban area or town)


### Use left_join() to join gage spatial data with gage attributes


## Plot gages colored by average precipitiation of watershed

?annotation_north_arrow
  