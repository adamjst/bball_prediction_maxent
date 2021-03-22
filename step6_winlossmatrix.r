library(here)                                            
library(reshape2)
library(tidyverse)                                            
library(tidyselect)  
here("division_data/")


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
winner <- winner_loser(total_div_intra)
winner_playoff <- data.frame(winner_loser(playoff_data_div_intra))

##bind together function output and original "total" dataset
total_winner <- cbind(total_div_intra, winner)
total_playoff <- data.frame(playoff_data_div_intra, winner_playoff)

##Make one replacement for naming idiosyncrasies
total_winner <- total_winner %>%
  mutate(Home = replace(Home, Home == "New Orleans/Oklahoma City Hornets" , "New Orleans Hornets")) %>%
  mutate(Visitors = replace(Visitors, Visitors == "New Orleans/Oklahoma City Hornets", "New Orleans Hornets"))%>%
  as.data.frame()
total_playoff <- total_playoff %>%
  mutate(Home = replace(Home, Home == "New Orleans/Oklahoma City Hornets" , "New Orleans Hornets")) %>%
  mutate(Visitors = replace(Visitors, Visitors == "New Orleans/Oklahoma City Hornets", "New Orleans Hornets"))%>%
  as.data.frame()

##Convert Winner and loser labels to team names
total_winner$winner1 <- ifelse(total_winner$winner1 == "visitor", total_winner$Visitors, total_winner$Home)
total_winner$loser1 <- ifelse(total_winner$loser1 == "visitor", total_winner$Visitors, total_winner$Home)
total_playoff$winner1 <- ifelse(total_playoff$winner1 == "visitor", as.character(total_playoff$Visitors), as.character(total_playoff$Home))
total_playoff$loser1 <- ifelse(total_playoff$loser1 == "visitor", as.character(total_playoff$Visitors), as.character(total_playoff$Home))

write.csv(total_winner, file="intra_div_reg.csv")
write.csv(total_playoff, file="intra_div_playoff.csv")

################
##Part 2. Create matrix and fill using season-by-season win pct.

###Three arguments: dataset, Association (NBA, ABA, BAA), SeasonStart, and division).
##Creates one matrix with teams in both rows and columns. Need to: 
##    1) divide by division
##    2) fill in matrix values based on wins/losses from the matchup count##

matrixmaker <- function(df = NULL, Association = NULL, year = NULL, division = NULL){
   ##Subset by association and Season Start year
   df_assoc_year <- df[ which(df$Association==Association & df$SeasonStart ==year),]
   ##Subset by teams in the same division in the year
   df_div_subset <- df_assoc_year[ which(df_assoc_year$Vis.Division==division),]
   print(df_div_subset)
   
   ##Create matrix based on winning teams
  winner_count <- df_div_subset %>%
    #group by matchup, then total number of occurences of a *win* for the *winning* team
    group_by(winner1, loser1) %>%
    summarise(wins=n()) %>%
    
    #create a matrix based on these matchups, and push the winner to rownames
    pivot_wider(names_from = loser1, values_from = wins, values_fill = 0) %>%
    column_to_rownames("winner1") %>%
    
    #sort by alphabetical order
    select(sort(peek_vars()))
  print(winner_count)
  
  ##Create matrix based on losing teams
  loser_count <- df_div_subset %>%
    #group by matchup, then total number of occurences of a *loss* for the *losing* team
    group_by(loser1, winner1)%>%
    summarise(losses=n()) %>%
    
    #create a matrix based on these matchups, and push the losers to rownames
    pivot_wider(names_from = winner1, values_from = losses, values_fill = 0) %>%
    column_to_rownames("loser1") %>%
    
    #sort by alphabetical order
    select(sort(peek_vars()))
  print(loser_count)
  #Confirm matching population of teams in league
  overlap <- union(names(winner_count), names(loser_count))

  #print(overlap)
  #calculate head-to-head winning pct of each team against every other team
  total_count <- winner_count[overlap]/ (winner_count[overlap] + loser_count[overlap])
  #print(total_count)
  #win_loss <- list(winner_count[overlap], loser_count[overlap])
  #div_list <- apply(total_count, 1, as_tibble)
}
x <- matrixmaker(total_winner, "NBA", year =yr, division= "division_6")

yrs <- seq(1995, 2004, 1)
yrs2 <- seq(2006, 2017, 1)

##Guide for the fourth argument: type a number 5-8 inclusive for 1995-2004;
#division_5: Atlantic Division; #division_6: Central; #division_7: Midwest #division_: Pacific
#Type a number #4-9 inclusive for 2005-2017)
#division_4: Northwest Division; #division_5: Pacific; #division_6: Southwest; #division_7: Atlantic; #division_8: Central; #division_9: Southeast
for (yr in yrs2){
  x <- matrixmaker(total_winner, "NBA", year =yr, "division_9")
  x[is.na(x)] <- 0
  x
  write.csv(x, file = here("bball_prediction_maxent", "step7_divisions", paste0("southeast_", yr, ".csv")), row.names=TRUE)
}

