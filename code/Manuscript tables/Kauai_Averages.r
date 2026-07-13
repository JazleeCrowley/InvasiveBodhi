#create a publishable table of average values for Kauai data
install.packages("readxl")
install.packages("gt")
library(gt)
library(readxl)
install.packages("webshot2")

#read in data
#read in data from numbers file

df <- read.csv("data/raw/Kaua'i_Averages(Sheet1).csv", colClasses = c(Year = "character"))



#create table
table <- df |>
  gt() |>
  tab_header(
    title = html("Supplementary Table 2: Average Values of <i>F. religiosa</i> Distances on Kaua'i"),
    subtitle = "Generated from Excel in R"
  ) |>
  fmt_number(
    columns = where(is.numeric),
    decimals = 2,
    drop_trailing_zeros = TRUE
  ) |>
  tab_options(
    table.font.size = "small"
  )
print(table)

gtsave(table, "Kauai_Averages.html")
#save as a png file
webshot2::webshot("Kauai_Averages.html", "Kauai_Averages.png", vwidth = 600, vheight = 800, zoom = 3)
