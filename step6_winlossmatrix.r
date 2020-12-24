library(here)                                            
library(reshape2)
library(tidyverse)                                            
library(tidyselect)  
here()


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
winner_playoff <- winner_loser(playoff_data_div_intra)

##bind together function output and original "total" dataset
total_winner <- cbind(total_div_intra, winner)
total_playoff <- cbind(playoff_data_div_intra, winner_playoff)

##Convert Winner and loser labels to team names
total_winner$winner1 <- ifelse(total_winner$winner1 == "visitor", total_winner$Visitors, total_winner$Home)
total_winner$loser1 <- ifelse(total_winner$loser1 == "visitor", total_winner$Visitors, total_winner$Home)

################
##Part 2. Create matrix and fill using season-by-season win pct.

###Three arguments: dataset, Association (NBA, ABA, BAA), SeasonStart.
##Creates one matrix with teams in both rows and columns. Need to: 
##    1) divide by conference 
##    2) fill in matrix values based on wins/losses from the matchup count##

matrixmaker <- function(df = NULL, Association = NULL, year = NULL, division = NULL){
   ##Subset by association and Season Start year
   df_assoc_year <- df[ which(df$Association==Association & df$SeasonStart ==year),]
   ##Subset by teams in the same division in the year
   df_div_subset <- df_assoc_year[ which(df_assoc_year$Vis.Division==paste0("division_", division)),]
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
  
  #Confirm matching population of teams in league
  overlap <- intersect(names(winner_count), names(loser_count))
  #calculate head-to-head winning pct of each team against every other team
  total_count <- winner_count[overlap] / (winner_count[overlap] + loser_count[overlap])
  
  #win_loss <- list(winner_count[overlap], loser_count[overlap])
  #div_list <- apply(total_count, 1, as.tibble)
}



##Keep total_winner as dataframe. For association and year, 
##  follow these guides for filling in the second and third argument:

          ##BAA: 1946-1948
          ##NBA: 1949-2018
          ##ABA: 1967-1975
          ##WNBA: 1997-2018

##For the fourth argument, type a number 4-9 inclusive)
x <- matrixmaker(total_winner, "NBA", year = 2017, 4)
x[is.na(x)] <- 0
x
write.csv(x, file = "northwest.csv", row.names=TRUE)

##Attempt at iteration using tidy.
x2 <- total_winner %>%
  filter(Vis.Division == Home.Division)

x3 <- x2 %>%
  group_by(Year, Vis.Division, winner1, loser1) %>%
  summarise(outcomes = n()) %>%
  rename(Division = Vis.Division) #%>%
  apply(., 1, matrix(Year, Division))

x4 <
x4 <- x3 %>%
  mutate(wins = map(.x = x3$data, ~ summarise(.x$winner1, na.rm = T)))



###NOT DONE: Attempt at iteration using nested loops
x3 <- c()
yrs <- seq(1996, 2002, 1)
divisions <- seq(4, 9, 1)
for (yr in yrs){
  print(yr)
  for (d in divisions){
    print(d)
    x3[[d]] <-matrixmaker(df = total_winner, Association = "NBA", year = yr, division=d)
  }
  x3[[yr]] <- output %>% discard(function(x) nrow(x) == 0)
}

write.csv(x3, file = "nba_2003.csv", row.names=TRUE)


#iteration using apply

x2<- lapply(1:nrow(total_winner), function(x){
  print(yr)
  tempX <- total_winner_head[x, c("Year")]
  tempY <- total_winner_head[x, c("Vis.Division")]
  matrixmaker(total_winner, "NBA", tempX, tempY)
})
x3 <- unlist(x2)
x2
eg <- function(x, y) paste(x, y)
sapply(yrs, function(yr) sapply(divisions), function(d) eg(matrixmaker()))
