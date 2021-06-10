library(dplyr)
library(assertthat)
library(here)

### 1. load observed table and take out team names ###
obs <- read.csv("southeast_2013_practice.csv")
colnames(obs) <- (c("X", "t1", "t2", "t3", "t4", "t5"))
obs <- obs %>%
  select(-X)
obs <- as.matrix(obs)
obs

#observed table
#t1 t2 t3 t4 t5
#[1,]  0  3  2  2  1
#[2,]  1  0  0  2  3
#[3,]  2  4  0  4  2
#[4,]  2  2  0  0  0
#[5,]  3  1  2  4  0

# observed column sums. Note: These differ from rowSums because wins are complimentary to 4, not symmetrical
x1 <- sum(obs[,1])
x2 <- sum(obs[,2])
x3 <- sum(obs[,3])
x4 <- sum(obs[,4])
x5 <- sum(obs[,5])

# Constraint maker
a <- sample(min(4, x1):max(0, (4-x2)), 1)
b <- sample(min(4, x1-a):max(0,(4-x3)), 1)
c <- sample(min(4, x1-a-b):max(0,(4-x4)), 1) 
d <- sample(min(4, x2-a):max(0,(4-x3+b)),1)
e <- sample(min(4, x2-a-d):max(0,(4-x4+c)), 1)
f <- sample(min(4, x3-b-d):max(0, (4-x4+c+e)), 1)

# Make constraint matrix
c1 <- c(0, a, b, c, (x1 - a - b - c))
c2 <- c((4 - a), 0, d, e, (x2 - (4 - a) - d - e))
c3 <- c((4 - b), (4 - d), 0, f, (x3 - (4 - b) - (4 - d) - f))
c4 <- c((4 - c), (4 - e), (4 - f), 0, (x4 - (4 - c) - (4 - e) - (4 - f)))
c5 <- c((4 - (x1 - a - b - c)), (4 - (x2 - a - d - e)), (4 - (x3 - b - d - f)), (4 - (x4 - c - e - f)), 0)

c_array <- array(c(c1, c2, c3, c4, c5), dim = c(5,5))
c_matrix <- as.matrix(c_array)
c_matrix

### Mathematical checks###

#* x1 - x5 all >0
assert_that(x1 > 0)
assert_that(x2 > 0)
assert_that(x3 > 0)
assert_that(x4 > 0)
assert_that(x5 > 0)

#* x1 + x2 + x3 + x4 + x5 = 40
assert_that(x1 + x2 + x3 + x4 + x5 == 40)

#* all cells are [0, 4]
assert_that((min(c_matrix) >= 0) && (max(c_matrix) <= 4))

#* all columns sum to observed data columns
assert_that(sum(c_matrix) == 40)

#* all rows sum to observed data rows
assert_that(c(rowSums(c_matrix)) == c(rowSums(obs)))

#* all columns sum to rows
assert_that(rowSums(obs) == colSums(obs))

#* all diagonals are zero
assert_that(sum(diag(c_matrix)) == 0)

#* x5 = (x1 - a - b - c) + (x2 - a - d - e) +  (x3 - b - d - fg) +  (x4 - c - e - f)
assert_that(((x1 - a - b - c) + (x2 - a - d - e) + (x3 - b - d - f) + (x4 - c - e - f)) == x5)

