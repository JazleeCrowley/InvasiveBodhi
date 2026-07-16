Create a supplementary table for all Bodhi tree occurrences in Hawaii
library(sf)
library(readr)
install.packages("sf")
install.packages("readr")

# Unzip KMZ
unzip(
  "/Users/jazleecrowley/Git/InvasiveBodhi/data/raw/HI_Occurrences.kmz",
  exdir = "/Users/jazleecrowley/Git/InvasiveBodhi/data/raw/HI_Occurrences_unzipped"
)

# See what files were extracted
list.files(
  "/Users/jazleecrowley/Git/InvasiveBodhi/data/raw/HI_Occurrences_unzipped",
  recursive = TRUE,
  full.names = TRUE
)

# Read KML
trees <- st_read(
  "/Users/jazleecrowley/Git/InvasiveBodhi/data/raw/HI_Occurrences_unzipped/doc.kml"
)

# Extract coordinates
coords <- st_coordinates(trees)

trees$longitude <- coords[,1]
trees$latitude <- coords[,2]

# Remove geometry
trees_csv <- st_drop_geometry(trees)

# Save CSV
write_csv(trees_csv, "HI_Occurrences.csv")
setwd("/Users/jazleecrowley/Git/InvasiveBodhi")
getwd()
list.files()
write_csv(
  trees_csv,
  "/Users/jazleecrowley/Desktop/BodhiTrees.csv"
)

