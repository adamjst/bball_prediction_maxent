library(dplyr)                                            ####KEY####
library(here)                                             ###Three pound signs = a new section.###
                                                          ##Two pound signs = explanatory statement of code##       
                                                          #One pound sign = optional print point. Take off to see what is happening under the hood.
here()
##read data from giant csv.##
total <- read.csv(here('total_data.csv'))

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