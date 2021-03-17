library(here)                                            
library(reshape2)
library(readxl)
library(tidyverse)                                            
library(tidyselect)  

d0 <- read_excel(paste0(here(), "/odds", "/nba odds 2011-12.xlsx", sep = ""))

home <- d0 %>%
  filter(VH == "H") %>%
  mutate(op.rot = Rot-1)
  #function to load and clean odds data  to make matchups
d1 <- function(url){
  csv <- read_excel(url, sep = ",")
  clean <- csv %>%
    pivot_wider(names_from=Date, c(Rot:'2H'))
}