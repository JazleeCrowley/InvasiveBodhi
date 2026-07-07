#create a nice table for my total Hawaii tree occurrences 

#read packages
install.packages("readxl")
install.packages("gt")
library(gt)
library(readxl)

#read in data
df <- read_excel("data/raw/Env_Layers/Total Island Occurrences.xlsx", sheet = 1)


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
