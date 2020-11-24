library(dplyr)                                          
library(here)                                             

here()
##read data from csv.##
total <- read.csv(here('total_data.csv'))

##read division data from other csv
div_data <- read.csv(here('total_division_data.csv'))
div_data <- div_data[-c(1)]
names(div_data)[1] <- "Division"


##Separates calendar year from season year. If month number is less than 10 (October, then subtract one from given year).##
total <- total %>%
  mutate(SeasonStart = if_else(total$Month < 10, -1, 0))

total$SeasonStart <- total$Year + total$SeasonStart

total$Association <- as.character(total$Association)

##Creates Season string to represent the whole season.##
total$Season <- paste(total$SeasonStart, "-", total$SeasonStart+1)

##Drop id columns and adjust column names.##
total <- total[ -c(1,2) ]
names(total)[2] <- 'Visitors'
names(total)[3] <- 'Vis.Pts'
names(total)[4] <- 'Home'
names(total)[5] <- 'Home.Pts'
names(total)[6] <- 'Box Score'
names(total)[7] <- 'URL'

##convert points to numeric.##
total$Vis.Pts <- as.numeric(total$Vis.Pts)
total$Home.Pts <- as.numeric(total$Home.Pts)
total$Home <- as.character(total$Home)
total$Visitors <- as.character(total$Visitors)

#Merge division data with win/loss results
total_div_merged_vis <- merge(total, div_data, by.x = c("Visitors", "SeasonStart"), by.y = c("Teams", "SeasonStart"),
                              all.x = FALSE, all.y = TRUE)
total_div_merged_both <- merge(total_div_merged_vis, div_data, by.x = c("Home", "SeasonStart"), by.y = c("Teams", "SeasonStart"),
                               all.x = FALSE, all.y = TRUE)

#Clean and rename division columns
total_div_clean <- total_div_merged_both[-c(17,19)]
names(total_div_clean)[16] <- "Vis.Division"
names(total_div_clean)[17] <- "Home.Division"

#Reduce to only intra-divisional games
total_div_intra <- total_div_clean %>%
  filter(Vis.Division == Home.Division)
  
