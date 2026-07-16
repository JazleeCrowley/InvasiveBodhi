#create a publishable supplementary table of all Hawaii coordinates
install.packages("readxl")
install.packages("gt")
library(gt)
library(readxl)
install.packages("webshot2")

#read in data

df <- read.csv("data/raw/AllHICoordinates.csv")
 

#create table
table <- df |>
  gt() |>
  tab_header(
    title = html("Supplementary Table 1: All occurence locations of <i>F. religiosa</i> in Kaua'i, O'ahu and Big Island study"),
    subtitle = "Generated from Excel in R"
  ) |>
  fmt_number(
    columns = where(is.numeric),
    decimals = 7,
    drop_trailing_zeros = TRUE
  ) |>
  tab_options(
    table.font.size = "small"
  )
print(table)

gtsave(table, "AllHICoordinates.html")
#save as a png file
webshot2::webshot(
  "AllHICoordinates.html",
  "AllHICoordinates.png",
  vwidth = 2000,
  vheight = 1500,
  zoom = 2
)
