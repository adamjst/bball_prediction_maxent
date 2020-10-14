library(dplyr)                                            
library(here)                                            
library(reshape2)
library(tidyverse)                                            
library(tidyselect)                             


###Requires "total" dataset prepped from Step 1###

###PART I. Identify Winner

##Function identifies which team won and lost for each matchup
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

##bind together function output and original "total" dataset
total_winner <- cbind(total, winner)

##Convert Winner and loser labels to team names
total_winner$winner1 <- ifelse(total_winner$winner1 == "visitor", total_winner$Visitors, total_winner$Home)
total_winner$loser1 <- ifelse(total_winner$loser1 == "visitor", total_winner$Visitors, total_winner$Home)

################
##Part 2. Create matrix and fill using season-by-season win pct.

###Three arguments: dataset, Association (NBA, ABA, BAA), SeasonStart.
##Creates one matrix with teams in both rows and columns. Need to: 
##    1) divide by conference 
##    2) fill in matrix values based on wins/losses from the matchup count##
matrixmaker <- function(df, Association, year){
  ##Subset by association and Season Start year
  df_assoc_year <- df[ which(df$Association==Association & df$SeasonStart ==year),]
    
  ##Create matrix based on winning teams
  winner_count <- df_assoc_year %>%
    #group by matchup, then total number of occurences of a *win* for the *winning* team
    group_by(winner1, loser1) %>%
    summarise(wins=n()) %>%
    
    #create a matrix based on these matchups, and push the winner to rownames
    pivot_wider(names_from = loser1, values_from = wins, values_fill = 0) %>%
    column_to_rownames("winner1") %>%
    
    #sort by alphabetical order
    select(sort(peek_vars()))
  
  ##Create matrix based on losing teams
  loser_count <- df_assoc_year %>%
    #group by matchup, then total number of occurences of a *loss* for the *losing* team
    group_by(loser1, winner1)%>%
    summarise(losses=n()) %>%
    
    #create a matrix based on these matchups, and push the loses to rownames
    pivot_wider(names_from = winner1, values_from = losses, values_fill = 0) %>%
    column_to_rownames("loser1") %>%
    
    #sort by alphabetical order
    select(sort(peek_vars()))
  
  #Confirm matching population of teams in league
  overlap <- intersect(names(winner_count), names(loser_count))
  #calculate head-to-head winning pct of each team against every other team
  total_count <- winner_count[overlap] / (winner_count[overlap] + loser_count[overlap])
}

##Keep total_winner as dataframe. For association and year, 
##  follow these guides for filling in the second and third argument:

          ##BAA: 1946-1948
          ##NBA: 1949-2018
          ##ABA: 1967-1975
          ##WNBA: 1997-2018

x <- matrixmaker(total_winner, "WNBA", 2018)
x
