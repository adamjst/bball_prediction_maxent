library(tidyverse)
library(BBmisc)
library(rexpokit)
library(LICORS)
library(stats)
library(here)
here()

## Create constraints
z <- runif(10, min=0, max=1) 
constraint_maker <- function(z){
  ###Diagonal at 0.00, otherwise randomized. Symmetrical matrix
  c1<- c(0.0, z[1], z[2], z[3], z[4])
  c2 <- c(z[1], 0.0, z[5], z[6], z[7])
  c3 <- c(z[2], z[5], 0.0, z[8], z[9])
  c4 <- c(z[3], z[6], z[8], 0.0, z[10])
  c5 <- c(z[4], z[7], z[9], z[10], 0.0)
  
  #convert to matrix
  c_prac_array <- array(c(c1, c2, c3, c4, c5), dim = c(5,5))
  c_prac_matrix <- as.matrix(c_prac_array)
  c_prac_matrix
  
  #Normalize columns (does not seem to sum to 1)
  c_norm <- sweep(c_prac_matrix,MARGIN=2,FUN="/",STATS=colSums(c_prac_matrix))
  
  #Normalize rows (does not sum to 1)
  c_norm_2 <- sweep(c_norm,MARGIN=1,FUN="/",STATS=rowSums(c_prac_matrix))
  
  # Insert diagonal of 0.25
  diag(c_norm_2) <- 0.25
  
  # Input to the constraint array
  return(c_norm_2)
}
# example constraints
constraint <- constraint_maker(z)

# Row sums and column sums are equal, but do not sum to 1
constraint
rowSums(constraint)
colSums(constraint)

#Practice division. Features 1e-10 as replacement for zeroes

div <- read.csv("southeast_2013_practice.csv")
colnames(div) <- (c("X", "t1", "t2", "t3", "t4", "t5"))
  
div1 <- div %>%
  select(-X)

## Maxent function adapted from https://rdrr.io/cran/rexpokit/man/maxent.html
#Will not except zeroes in data argument. Replaced above with 1e-10.
maxent_function <- function(data) {
  # set randomized constraints
  z <- runif(10, min=0, max=1)
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
