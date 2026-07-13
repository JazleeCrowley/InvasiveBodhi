#create a publishable table of average values for Kauai data
install.packages("readxl")
install.packages("gt")
library(gt)
library(readxl)
install.packages("webshot2")

#read in data
#read in data from numbers file

df <- read.csv("data/raw/Kaua'i_Averages(Sheet1).csv")



#create table
table <- df |>
  gt() |>
  tab_header(
    title = html("Total Recorded Occurrences of <i>F. religiosa</i> on Three Hawaiian Islands"),
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

gtsave(table, "Total_Hawaii_trees.html")
#save as a png file
webshot2::webshot("Total_Hawaii_trees.html", "Total_Hawaii_trees.png", vwidth = 600, vheight = 800, zoom = 3)
