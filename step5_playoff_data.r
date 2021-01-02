library(dplyr)                                          
library(here)                                             

here()
##read data from csv.##
total_playoffs <- read.csv(here('total_playoff_data.csv'))

playoff_data <- total_playoffs %>%
  select(-c(1:2)) %>%
  mutate(SeasonStart = if_else(total_playoffs$Month < 10, -1, 0))

playoff_data$SeasonStart <- playoff_data$Year + playoff_data$SeasonStart

##Separates calendar year from season year. If month number is less than 10 (October, then subtract one from given year).##
playoff_data$Association <- as.character(playoff_data$Association)

##Creates Season string to represent the whole season.##
playoff_data$Season <- paste(playoff_data$SeasonStart, "-", playoff_data$SeasonStart+1)

##Drop id columns and adjust column names.##
names(playoff_data)[2] <- 'Visitors'
names(playoff_data)[3] <- 'Vis.Pts'
names(playoff_data)[4] <- 'Home'
names(playoff_data)[5] <- 'Home.Pts'
names(playoff_data)[6] <- 'Box Score'
names(playoff_data)[7] <- 'URL'

#Merge division data with win/loss results
playoff_data_div_merged_vis <- merge(playoff_data, div_data, by.x = c("Visitors", "SeasonStart"), by.y = c("Teams", "SeasonStart"),
                              all.x = FALSE, all.y = FALSE)
playoff_data_div_merged_both <- merge(playoff_data_div_merged_vis, div_data, by.x = c("Home", "SeasonStart"), by.y = c("Teams", "SeasonStart"),
                               all.x = FALSE, all.y = FALSE)

#Clean and rename division columns
playoff_data_div_clean <- playoff_data_div_merged_both %>%
  select(-c(17, 19)) %>%
  rename(Vis.Division = 16,
         Home.Division = 17)

#Reduce to only intra-divisional games
playoff_data_div_intra <- playoff_data_div_clean %>%
  filter(Vis.Division == Home.Division) %>%
  group_by(Home, Visitors, Year)

write.csv(playoff_data_div_intra, file = "playoff_intradivision_1995_2017.csv", row.names=TRUE)


