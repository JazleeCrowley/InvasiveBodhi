# Do pairwise distance analsysis
# possibly including age

rm(list = ls())

# Load data
filename <- "data/raw/Kauai_Oahu_ages.csv"
df <- read.csv(filename)


# Hardcode in the island names
# and validate with an optional plot
df$island <- "Oahu"
df$island[503:nrow(df)] <- "Kauai"
do_plot <- FALSE
if (do_plot) {
  quartz(h = 4, w = 4)
  plot(df$X, df$Y, col = as.factor(df$island),   pch = 16,
    xlab = "Longitude",
    ylab = "Latitude",
    main = "Tree Locations")
}
  

# Make a function to calculate pairwise distances
# using great circle distance
great_circle_distance <- function(lat1, lon1, lat2, lon2, radius = 6371) {
  # Convert degrees to radians
  to_rad <- function(deg) deg * pi / 180

  lat1 <- to_rad(lat1)
  lon1 <- to_rad(lon1)
  lat2 <- to_rad(lat2)
  lon2 <- to_rad(lon2)

  # Differences
  dlat <- lat2 - lat1
  dlon <- lon2 - lon1

  # Haversine formula
  a <- sin(dlat / 2)^2 + cos(lat1) * cos(lat2) * sin(dlon / 2)^2
  c <- 2 * atan2(sqrt(a), sqrt(1 - a))

  # Distance
  distance <- radius * c

  return(distance)  # nolint
}

#Create a forloop to calculate pairwise distances between trees