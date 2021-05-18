library(tidyverse)
library(assertthat)
library(BBmisc)
library(rexpokit)
library(LICORS)
library(stats)
library(here)
library(ggplot2)
here()

z <- runif(10, min=0, max=1)
constraint_maker <- function(z){
  ###Diagonal at 0.00, otherwise randomized. Symmetrical matrix
  c1<- c(0.0, z[1], z[2], z[3], z[4])
  c2 <- c(z[1], 0.0, z[5], z[6], z[7])
  c3 <- c(z[2], z[5], 0.0, z[8], z[9])
  c4 <- c(z[3], z[6], z[8], 0.0, z[10])
  c5 <- c(z[4], z[7], z[9], z[10], 0.0)
  
  #convert to matrix
  c_array <- array(c(c1, c2, c3, c4, c5), dim = c(5,5))
  c_matrix <- as.matrix(c_array)
  c_matrix
  
  #Normalize columns
  con <- rep(1, nrow(c_matrix)) # vector of constraints
  stand_dist <- Spbsampling::stsum(mat = c_matrix, con = con) # normalized matrix
  c_norm <- 0.75*stand_dist$mat # multiply times 0.75
  
  # Insert diagonal of 0.25
  diag(c_norm) <- 0.25
  
  # Input to the constraint array
  return(c_norm)
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

#Identify the index of the maximum entropy value of the _means_ of each replication
max_of_means <- match(max(unlist(mean_ent)), unlist(mean_ent))
mean_ent[max_of_means]

#unlist and plot distribution of means of entropy
mean_ent_unlist <- as.data.frame(unlist(mean_ent)) 
mean_ent_unlist <- mean_ent_unlist %>%
  rename(mean_max_ents = "unlist(mean_ent)")

max_mean_ent_plot <- mean_ent_unlist %>%
  ggplot(aes(x=max_mean_ents)) +
  geom_density(stat="density")
max_mean_ent_plot


#Identify the index of the maximum entropy value out of the _maximum entropy value_ of each replication
max_of_max <- match(max(unlist(max_ent)), unlist(max_ent))
max_ent[max_of_max]

#unlist and plot distribution of max of entropy
max_max_ent_unlist <- as.data.frame(unlist(max_ent)) 
max_max_ent_unlist <- max_max_ent_unlist %>%
  rename(max_max_ents = "unlist(max_ent)")

max_max_ent_plot <- max_max_ent_unlist %>%
  ggplot(aes(x=max_max_ents)) +
  geom_density(stat="density")
max_max_ent_plot


