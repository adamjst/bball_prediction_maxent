library(tidyverse)
library(rexpokit)
library(here)
here()

## Create constraints
z <- runif(20, min=0, max=1) 
constraint_maker <- function(z){
  ###Diagonal at 0.25, otherwise randomized
  c1 <- c(0.25, z[1], z[2], z[3], z[4])
  c2 <- c(z[5], 0.25, z[6], z[7], z[8])
  c3 <- c(z[9], z[10], 0.25, z[11], z[12])
  c4 <- c(z[13], z[14], z[15], 0.25, z[16])
  c5 <- c(z[17], z[18], z[19], z[20], 0.25)
  
  # Input to the constraint array
  return(array(c(c1, c2, c3, c4, c5), dim = c(5,5)))
}
# example constraints
constraint <- constraint_maker(z)
constraint

## read basketball game data, rename columns, and drop team name
#Practice division. Features 1e-10 as replacement for zeroes

div <- read.csv("southeast_2013_practice.csv")
colnames(div) <- (c("X", "t1", "t2", "t3", "t4", "t5"))
  
div1 <- div %>%
  select(-X)

## Maxent function adapted from https://rdrr.io/cran/rexpokit/man/maxent.html
#Will not except zeroes in data argument. Replaced above with 1e-10.
maxent_function <- function(data) {
  # set randomized constraints
  z <- runif(20, min=0, max=1)
  constraint <- constraint_maker(z)
  # run maxent on constraint and data
  solution <- maxent(constraint, data)
  return(solution)
}
# Run maxent function on division once
example <- maxent_function(div1)
example #Creates seven lists: $prob, $moments, $entropy, $iter, $constr, $states, $prior

# Run maxent function on division 10000 times
bootstrap <- replicate(10000, maxent_function(div1))

# Create list for finding the mean entropy/max entropy for each output 
#(In the 5x5 array, there are 5 entropy values)

mean_ent <- list()
max_ent <- list()
for(i in seq(3, 70000, 7)){
  mean_entropy <- mean(unlist(bootstrap[i]))
  max_entropy <- max(unlist(bootstrap[i]))
  mean_ent <- append(mean_ent, mean_entropy)
  max_ent <- append(max_ent, max_entropy)
}

#Identify the index of the maximum entropy value of the means of each replication
max_of_means <- match(max(unlist(mean_ent)), unlist(mean_ent))
max_of_means

#Identify the index of the maximum entropy value of the max of each replication
max_of_max <- match(max(unlist(max_ent)), unlist(max_ent))
max_of_max
