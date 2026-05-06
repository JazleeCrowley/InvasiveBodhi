# Clear environment
rm(list = ls())
data <- read.csv("data/raw/Oahu_ages_only.csv")
summary(data)


# Load data
data <- read.csv("data/raw/Oahu_ages_only.csv")

# Inspect data
summary(data)

# Plot all data
plot(data$X, data$Y,
     xlab = "Longitude",
     ylab = "Latitude",
     main = "Map of Points")

rm(list = ls())

#setwd("~/Desktop")
read.csv("../data/raw/Oahu_ages_only.csv")
summary("../data/raw/Oahu_ages_only.csv")

data <- read.csv("Oahu_ages_only.csv")

#Plot all data
plot(data$X, data$Y,
     xlab = "Longitude",
     ylab = "Latitude",
     main = "Map of Points")

#select area to show
filtered <- data[
  data$X > -157.86 & data$X < -157.79 &
    data$Y > 21.27 & data$Y < 21.40,
]
plot(filtered$X, filtered$Y)

#set NA as "1"
desc <- as.character(data$description)
desc[is.na(desc)] <- "1"

filtered$desc <- as.character(filtered$description)
filtered$desc[is.na(filtered$desc)] <- "1"

#color coordinate plot

cols <- c("1" = adjustcolor("red", alpha.f = 0.3),
          "5" = "darkorange",
          "10" = "darkgoldenrod1",
          "15" = "darkolivegreen",
          "30" = "lightgreen",
          "50" = "cornflowerblue",
          "100" = "purple"
          )


plot(filtered$X, filtered$Y,
     col = cols[desc],
     pch = 16)

legend("topright",
       legend = names(cols),
       col = cols,
       pch = 16)

#filtering ages
##only 100
only_100 <- filtered[filtered$description == 100, ]

plot(only_100$X, only_100$Y,
     col = "purple",
     pch = 16,
     main = "100+ Years")

##Only100 and 50
subset_100_50 <- filtered[filtered$description %in% c(100, 50), ]

plot(subset_100_50$X, subset_100_50$Y,
     col = ifelse(subset_100_50$description == 100, "purple", "cornflowerblue"),
     pch = 16,
     main = "Only 100 and 50")

##Only100 and 50 and 30
subset_100_50_30 <- filtered[filtered$description %in% c(100, 50, 30), ]

plot(subset_100_50_30$X, subset_100_50_30$Y,
     col = ifelse(subset_100_50_30$description == 100, "purple",
                  ifelse(subset_100_50_30$description == 50, "cornflowerblue", "darkolivegreen")),
     pch = 16,
     main = "Only 100, 50, and 30")

##Only100 and 50 and 30 and 15
subset_100_50_30_15 <- filtered[filtered$description %in% c(100, 50, 30, 15), ]

cols <- c("100" = "purple",
          "50" = "cornflowerblue",
          "30" = "darkolivegreen",
          "15" = "lightgreen")

plot(subset_100_50_30_15$X,
     subset_100_50_30_15$Y,
     col = cols[as.character(subset_100_50_30_15$description)],
     pch = 16,
     main = "100, 50, 30, 15")

##Only100 and 50 and 30 and 15 and 10
subset_100_50_30_15_10 <- filtered[filtered$description %in% c(100, 50, 30, 15, 10), ]

cols <- c("100" = "purple",
          "50" = "cornflowerblue",
          "30" = "darkolivegreen",
          "15" = "lightgreen",
          "10" = "goldenrod1")

plot(subset_100_50_30_15_10$X,
     subset_100_50_30_15_10$Y,
     col = cols[as.character(subset_100_50_30_15_10$description)],
     pch = 16,
     main = "100, 50, 30, 15, 10")

##Only100 and 50 and 30 and 15 and 10 and 5
subset_100_50_30_15_10_5 <- filtered[filtered$description %in% c(100, 50, 30, 15, 10, 5), ]

cols <- c("100" = "purple",
          "50" = "cornflowerblue",
          "30" = "darkolivegreen",
          "15" = "lightgreen",
          "10" = "goldenrod1",
          "5" = "darkorange")

plot(subset_100_50_30_15_10_5$X,
     subset_100_50_30_15_10_5$Y,
     col = cols[as.character(subset_100_50_30_15_10_5$description)],
     pch = 16,
     main = "100, 50, 30, 15, 10, 5")
     

##Everything
cols <- c("1" = adjustcolor("red", alpha.f = 0.3),
          "5" = "darkorange",
          "10" = "darkgoldenrod1",
          "15" = "darkolivegreen",
          "30" = "lightgreen",
          "50" = "cornflowerblue",
          "100" = "purple"
)


plot(filtered$X, filtered$Y,
     col = cols[desc],
     pch = 16,
     main = "Present") 
