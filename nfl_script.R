

# Use the 'pacman' library to load/install the necesary packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, data.table, highcharter, ggthemes, janitor, lubridate)

# set the working directory
setwd("./NFL")

# get the list of datasets to combine together
data_list <- list.files("data",pattern = ".csv")

# Read each file into a list
raw_data <- lapply(paste0("data/",data_list), fread)

# Collapse the list into a single data.table object
nfl_data <- rbindlist(raw_data, use.names = TRUE)

# Inspect the new object
str(nfl_data)

# It looks like some columns have a generic "V" column and there are NAs
# These is likely due to an error in the files somewhere
inspect_names <- names(nfl_data)[grep("V", names(nfl_data))]
inspect_cols <- nfl_data[, inspect_names, with = FALSE]
summary(inspect_cols)

# It looks like they're all NAs so we can remove them
nfl_data[, (inspect_names) := NULL]

# Convert the GameDate to date format
nfl_data[, GameDate := as.Date(parse_date_time(GameDate, c("Ymd", "mdY")))]



unique(nfl$OffenseTeam)
vikes <- nfl[OffenseTeam == "MIN" | DefenseTeam == "MIN",]

vikes[, unique(GameId)]

formations <- vikes[, .N, by = "Formation"]

ggplot(formations, aes(Formation, N)) + 
  geom_col() + 
  theme_fivethirtyeight() +
  ggtitle("MIN Vikings Offensive Plays by Type")

hchart(formations[Formation != ""], "column", hcaes(Formation, N), 
       color = "#4F2683", name = "Plays") %>%  
  hc_title(
    text = "Minnesota Vikings Offensive Plays by Type"
  ) %>%
  hc_subtitle(text = "2018 Season") %>%
  hc_add_theme(hc_theme_smpl())