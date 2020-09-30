library(dplyr)                                            ####KEY####
library(here)                                             ###Three pound signs = a new section.###
library(reshape2)                                         ##Two pound signs = explanatory statement of code##       
                                                          #One pound sign = optional print point. Take off to see what is happening under the hood.#


###Requires total dataset prepped from Step 1

##Identifies which team won and lost by matchup
winner_loser <- function(matrix) {
  ##Determine which points total is greater and the margin of victory##
  won1 <- pmax(matrix$Vis.Pts, matrix$Home.Pts)
  margin1 <- abs(matrix$Vis.Pts - matrix$Home.Pts)
  
  ##Identify winner and loser##
  winner1 <- ifelse(won1 == matrix$Vis.Pts, "visitor", "home")
  loser1 <- ifelse(won1 != matrix$Vis.Pts, "visitor", "home")
  
  ##bind into columns
  cbind(winner1, loser1, margin1)
}
#Apply function to dataset
winner <- winner_loser(total)

##bind together function output and original dataset
total_winner <- cbind(total, winner)

##Convert Winner and loser labels to team names
total_winner$winner1 <- ifelse(total_winner$winner1 == "visitor", total_winner$Visitors, total_winner$Home)
total_winner$loser1 <- ifelse(total_winner$loser1 == "visitor", total_winner$Visitors, total_winner$Home)

##Summarise matchups by wins, year, association
matchup_count <- total_winner %>%
  group_by(winner1, loser1, SeasonStart, Association) %>%
  summarise(n=n())


###Three arguments: dataset, Association (NBA, ABA, BAA), SeasonStart.
##Creates one matrix with teams in both rows and columns. Need to: 
##    1) divide by conference 
##    2) fill in matrix values based on wins/losses from the matchup count##
matrixmaker <- function(df, Association, year){
  ##Subset by association
  df <- df[ which(df$Association == Association), ]
  ##Subset by Season
  season_year <- df[ which(df$SeasonStart == year), ]
  ##Derive unique teams from season and association
  teams <- as.character(unique(season_year$winner1))
  ##Create matrix rows/columns based on teams
  matrix <- matrix(nrow = length(teams), ncol=length(teams), dimnames = list(c(teams), c(teams)))
  
}
##sample run
x <- matrixmaker(matchup_count, "NBA", 2018)
x
