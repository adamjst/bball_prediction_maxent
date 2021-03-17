library(here)                                            
library(reshape2)
library(readxl)
library(tidyverse)                                            
library(tidyselect)  

#function to read data
read_odds <- function(season){
  read_excel(paste0(here(), "/odds", season, ".xlsx", sep = ""))
}


nba_odds11_12 <- read_odds("/nba odds 2011-12")

#NOT DONE. COnverting dataset to same format as basketball reference wide form.
#Currently, subsetting home teams
home <- nba_odds11_12 %>%
  filter(VH == "H") %>%
  mutate(op.rot = Rot-1)
