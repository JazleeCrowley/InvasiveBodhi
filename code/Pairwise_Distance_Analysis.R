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

# ---------------------------------------------------
# Load packages
# ---------------------------------------------------

library(ggplot2)
library(microbenchmark)
library(parallel)
library(doParallel)
library(foreach)

# ---------------------------------------------------
connectivity_gc <- function(df, scale = 20) {

  # Number of trees
  n_trees <- nrow(df)

  # Pairwise distance matrix
  distance_matrix <- matrix(
    NA_real_,
    n_trees,
    n_trees
  )

  # Connectivity matrix
  connectivity_matrix <- matrix(
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

      # Connectivity kernel
      connectivity_value <- exp(-distance_km / scale)

      # Fill symmetric connectivity matrix
      connectivity_matrix[i, j] <- connectivity_value
      connectivity_matrix[j, i] <- connectivity_value
    }
  }

  # Ignore self-connectivity
  diag(connectivity_matrix) <- NA_real_

  # Mean within-island distance
  mean_distance_same_island <- numeric(n_trees)

  for (i in seq_len(n_trees)) {

    same_island <- (
      df$island == df$island[i]
    )

    mean_distance_same_island[i] <- mean(
      distance_matrix[i, same_island],
      na.rm = TRUE
    )
  }

  # Mean connectivity
  mean_connectivity <- mean(
    connectivity_matrix,
    na.rm = TRUE
  )

  # Return results
  return(list(
    mean_connectivity = mean_connectivity,
    distance_matrix = distance_matrix,
    connectivity_matrix = connectivity_matrix,
    mean_distance_same_island =
      mean_distance_same_island
  ))
}

results <- connectivity_gc(df, scale = 20)

mean_connectivity <- results$mean_connectivity

distance_matrix <- results$distance_matrix

connectivity_matrix <- results$connectivity_matrix

mean_distance_same_island <-
  results$mean_distance_same_island

print(mean_connectivity)
print(mean(mean_distance_same_island, na.rm = TRUE))
print(mean(mean_distance_same_island[df$island == "Oahu"], na.rm = TRUE))
print(mean(mean_distance_same_island[df$island == "Kauai"], na.rm = TRUE))
print(distance_matrix[1:5, 1:5])
print(connectivity_matrix[1:5, 1:5])

# mask everything except same-island pairs
within_idx <- outer(df$island, df$island, FUN = "==")

mean_within_island_distance <- mean(
  distance_matrix[within_idx],
  na.rm = TRUE
)

mean_within_island_distance

distance_matrix <- results$distance_matrix

within_idx <- outer(df$island, df$island, "==")
diag(within_idx) <- FALSE
mean_within_island_distance <- mean(distance_matrix[within_idx], na.rm = TRUE)
mean_within_island_distance

#currently shows that everything is tightly clustered
