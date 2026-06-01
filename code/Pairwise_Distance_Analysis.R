# Do pairwise distance analsysis
# possibly including age

rm(list = ls())
graphics.off()

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
  plot(df$X, df$Y,
    col = as.factor(df$island), pch = 16,
    xlab = "Longitude",
    ylab = "Latitude",
    main = "Tree Locations"
  )
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

  return(distance) # nolint
}

# Create a forloop to calculate pairwise distances between trees

# ---------------------------------------------------
# Load packages
# ---------------------------------------------------

library(ggplot2)
library(microbenchmark)
library(parallel)
library(doParallel)
library(foreach)

# ---------------------------------------------------
get_distance <- function(df) {
  # Number of trees
  n_trees <- nrow(df)

  # Pairwise distance matrix
  distance_matrix <- matrix(
    NA_real_,
    n_trees,
    n_trees
  )

  # Pairwise calculations
  for (i in seq_len(n_trees)) {
    # Progress update
    if (i %% 50 == 0) {
      cat("Processing tree", i, "of", n_trees, "\n")
    }

    # Only compute upper triangle
    for (j in i:n_trees) {
      # Skip self-distance
      if (i == j) {
        next
      }

      # Great-circle distance
      distance_km <- great_circle_distance(
        lat1 = df$Y[i],
        lon1 = df$X[i],
        lat2 = df$Y[j],
        lon2 = df$X[j]
      )

      # Fill symmetric distance matrix
      distance_matrix[i, j] <- distance_km
      distance_matrix[j, i] <- distance_km
    }
  }
  return(distance_matrix)
}

# Get distance matrices
d_oahu <- get_distance(df[df$island == "Oahu", ])
d_kauai <- get_distance(df[df$island == "Kauai", ])

image(d_oahu)

# Look at distributions of distances within each island


# Prepare to compare distance distributions

## make vectors of distances for each island
d_vec_oahu <- c(d_oahu[upper.tri(d_oahu)])
d_vec_kauai <- c(d_kauai[upper.tri(d_kauai)])
n_oahu <- length(d_vec_oahu)
n_kauai <- length(d_vec_kauai)

## plot histograms of distances for each island
quartz(h = 4, w = 8)
par(mfrow = c(1, 2))
breaks <- seq(0, max(c(d_vec_oahu, d_vec_kauai), na.rm = TRUE) + 1, by = 1)
hist(c(d_vec_oahu), breaks = breaks, main = "Oahu", xlab = "Distance (km)")
hist(c(d_vec_kauai), breaks = breaks, main = "Kauai", xlab = "Distance (km)")

# get ks statistic
get_ks_stat <- function(x, y) {
  suppressWarnings(ks.test(x, y)$statistic)
}

ks <- get_ks_stat(d_vec_oahu, d_vec_kauai)
print(ks)

nperm <- 1000
ks_perm <- rep(NA, nperm)

for (i in seq_len(nperm)) {
  pooled <- c(d_vec_oahu, d_vec_kauai)
  idx_oahu <- sample.int(length(pooled), n_oahu, replace = FALSE)
  idx_kauai <- setdiff(seq_along(pooled), idx_oahu)
  ks_perm[i] <- get_ks_stat(pooled[idx_oahu], pooled[idx_kauai])
}

#generate null graphs of ks statistic
graphics.off()
> quartz()
> hist(ks_perm)
> hist(ks_perm,xlim = c(0, 0.5))
> points(ks, 0, cex = 10, col = 'red')
> hist(ks_perm,xlim = c(0, 0.5))
> points(ks, 0, cex = 5, pch=19, col = 'red')

#chatgpt how to get a p-value out of this?
#repeat this analysis with different ages, look at ks across each age (3x3)=9
#spatial age structure on the two islands are different or the same