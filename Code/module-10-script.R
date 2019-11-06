########################################################################################
# Summary: Analyzing GAGES-II data
# Date: October 30, 2019
# Exercise created by Dr. Sheila Saia, http://sheilasaia.rbind.io/,
# https://github.com/sheilasaia/sf-workshop-bae590, and modified by Dr. Natalie Nelson
########################################################################################

#Update R
install.packages("installr")
library(installr)
updateR()


# Clear workspace, install, and load packages ----
rm(list=ls(all=TRUE))
install.packages("sf")
install.packages("ggspatial")
library(tidyverse)
library(sf)
library(ggspatial)
library(ggplot2)

# Load and inspect data ----
# Load the southeast states shapefile: note that you only need to read the .shp file, but the other two shapefile files (.shx, .dbf) need to be in the same directory as the .shp file. R is reading .shp, .shx, and .dbf behind the scenes.
se_states <- read_sf("Data/spatial_data/southeast_state_bounds_SIMPLE.shp")
#only call the .shp file when you call in a shapefile

### Inspect se_states
se_states
str(se_states)
class(se_states)
colnames(se_states)
head(se_states)
view(se_states)

## Use st_crs() to check coordinate reference system (CRS)

st_crs(se_states)

## Let's re-project se_states to EPSG = 32019
## https://epsg.io/

se_states <- st_transform(se_states, 32019)

## Use st_crs() again to check CRS
st_crs(se_states)

## Plot SE state boundaries

ggplot() +
  geom_sf(data = se_states, aes(fill = ALAND), color = "red") +
  theme_bw()

## Create a spatial tibble that only includes NC
unique(se_states$NAME) #see the unique values in column NAME to see how NC is spelled

nc <- se_states %>%
  filter(NAME == "North Carolina")

str(nc)

### Read NC river basin boundaries shapefile
nc_basins <- read_sf("Data/spatial_data/river_basins_SIMPLE.shp") %>% 
  st_transform(32019)
## Use st_crs() to check CRS

st_crs(nc_basins)

## Inspect
head(nc_basins)
str(nc_basins)

## Plot NC river basins

ggplot() +
  geom_sf(data = nc_basins) +
  theme_bw()

## Create a spatial tibble that only includes the Cape Fear River basin

cape_fear <- nc_basins %>%
  filter(Name == "Cape Fear")

## Plot the Cape Fear basin on top of NC

ggplot() +
  geom_sf(data = nc) +
  geom_sf(data = cape_fear, color = "red")

### Read stream gage shapefile and define projection and set CRS
gages <- 
  read_sf("Data/spatial_data/gagesII_9322_sept30_2011.shp") %>%
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
climate_data <- read_csv("Data/tabular_data/conterm_climate.txt")
# geology_data <- read_csv("tabular_data/conterm_geology.txt")
# hydrology_data <- read_csv("tabular_data/conterm_hydro.txt")
# topo_data <- read_csv("tabular_data/conterm_topo.txt")

## Inspect climate attribute data
str(climate_data) #just a tibble, not geospacial
head(climate_data)
# The main column we're interested in is PPTAVG_BASIN (average precipitation in gage sub-basin)

# Using sf functions for geospatial data manipulation ----
### Separate geometry using st_geometry()

se_states_geom <- st_geometry(se_states)

### Separate attributes using st_set_geometry(NULL)
#convert spacial tibble to regular tibble

se_states %>%
  st_set_geometry(NULL) -> se_states_attribs
#basically sets geometry column to NULL, completely removes the column
head(se_states_attribs)
str(se_states_attribs)

#### Let's save the geometry for the NC shapefile separately
nc_geom <- st_geometry(nc)

### Calculate areas of nc_geom and se_states using st_area()
st_area(nc_geom)
st_area(se_states_geom)
#now we can add our areas to our table
se_states %>%
  mutate(area = st_area(geometry))


### Calculate buffer using st_buffer()
nc_buffer <- st_buffer(nc_geom, dist = 10^5)

## Plot the buffer 
nc %>%
  ggplot() +
  geom_sf() +
  geom_sf(data = nc_buffer, fill = NA, color = "red") +
  theme_bw()

### Remove a state from se_states using st_difference()
se_states %>%
  filter(NAME == "Georgia") -> ga
se_states_wo_ga <- st_difference(se_states, ga)
str(se_states_wo_ga)

## Create a map without GA
se_states_wo_ga %>%
  ggplot() +
  geom_sf() +
  theme_bw()

### Create a tibble that includes the gages and NC river basins
# Could be useful for determining which river basins each of the points are in
# Spatial join! (join two different spacial tibbles based on similar geometries)

nc_basins %>%
  st_join(gages) ->nc_basins_gages
view(nc_basins_gages)

## How many gages are there per NC river basin?
nc_basins_gages %>%
  group_by(Name) %>%
  count()

### Select gages in NC using st_intersection()
#we just want gages in NC

nc_gages <- st_intersection(gages, nc)
## Plot nc_gages
ggplot() +
  geom_sf(data = nc_basins) +
  geom_sf(data = nc_gages, size = 2, alpha = 0.5) +
  theme_bw()

### Select gages inside the Cape Fear River watershed
cape_fear_gages <- st_intersection(gages, st_geometry(cape_fear))

## Plot gages in the Cape Fear River basin
ggplot() +
  geom_sf(data = nc_geom) +
  geom_sf(data = cape_fear, color = "red") +
  geom_sf(data = cape_fear_gages, size = 2, alpha = 0.5) +
  theme_bw()

## Plot Cape Fear River basin gages colored by reference or non-reference
# reference = minimal to no human impact on streamflow (e.g., forested with no development)
# non-reference = human impact on streamflow (e.g., has an urban area or town)

ggplot() +
  geom_sf(data = cape_fear) +
  geom_sf(data = cape_fear_gages, aes(color = CLASS, fill = CLASS )) +
  theme_bw()

### Use left_join() to join gage spatial data with gage attributes


## Plot gages colored by average precipitiation of watershed

?annotation_north_arrow
  