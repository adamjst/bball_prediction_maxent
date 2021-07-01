library(dplyr)
library(assertthat)
library(here)

### 1. load observed table and take out team names ###
obs <- read.csv("northwest_2013_practice.csv")
obs <- read.csv("southeast_2013_practice.csv")
obs <- read.csv("atlantic_2013_practice.csv")
obs <- read.csv("pacific_2013_practice.csv")
obs <- read.csv("central_2013_practice.csv")
#4 by 5
#obs <- read.csv("southwest_2013_practice.csv")

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

rows <- list(x1,x2,x3,x4,x5)
# Generate random variables based on column sums
a <- sample(min(4, x1):max(4, (4-x2)), 1)
a
g <- 4-a
b <- sample(min(0, (x1-a)):max(4,(4-x3)), 1)
b
assert_that(a+b <= x1)
h <- 4-b
c <- sample(min(0, (x1-a-b)):max(4,(4-x4)), 1)
c
i <- 4-c
d <- sample(min(0, (x2-g)):max(4, (4-x3-b)),1)
d
j <- 4-d
e <- sample(min(0, (x2-g-d)):max(4, (4-x4-c)), 1)
e
k <- 4-e
f <- sample(min(0, (x3-h-j)):max(4, (4-x4-c-e)), 1)
l <- 4-f

values <- list(a,b,c,d,e,f,g,h,i,j,k,l)
#0  g  h  i  r1  
#a  0  j  k  r2
#b  d  0  l  r3
#c  e  f  0  r4
#c1 c2 c3 c4 0

# Make constraint matrix
c1 <- c(0, a, b, c, abs(x1 - a - b - c))
c2 <- c(g, 0, d, e, abs(x2 - g - d - e))
c3 <- c(h, j, 0, f, abs(x3 - h - j - f))
c4 <- c(i, k, l, 0, abs(x4 - i - k - l))
c5 <- c(4-abs(x1 - a - b - c), 4-abs(x2 - g - d - e), 4-abs(x3 - h - j - f), 4-abs(x4 - i - k - l),0)#* x5 = (x1 - a - b - c) + (x2 - a - d - e) +  (x3 - b - d - f) +  (x4 - c - e - f)

c_array <- array(c(c1, c2, c3, c4, c5), dim = c(5,5))
c_matrix <- as.matrix(c_array)
#c_matrix[lower.tri(c_matrix)] <- 4-c_matrix[upper.tri(c_matrix)]
c_matrix <- list(c_matrix)


### Mathematical checks###
math_checks <- function(rows, c_matrix) {
  
  #1. Check to ensure all values > 0
greater_than_zero <- function(rows){ 
  row_check <- tryCatch(
  {for (i in rows){
    assert_that(i > 0)
  }
  message("Each row total is greater than 0")
    },
  error=function(cond){
  message(paste(i, "is not less than 0"))
  }
  )}

 #2. Check to ensure all values sum to 40
sum_to_40 <- function(rows){
  forty_check <- tryCatch(
  {assert_that(x1 + x2 + x3 + x4 + x5 == 40)
  message("The sum of all rows is 40")
    },
  error = function(){
    message("The sum of all rows is NOT 40.")
  }
)
}

 #3. Check to ensure all values btwn 0 and 4
btwn_zero_40 <- function(c_matrix){
  matrix_check <- tryCatch(
  {for (i in list(c_matrix)){
    assert_that((i >= 0) && (i <= 4))
  }
  message("All values in matrix are integers between 0 and 4, inclusive")},
  error = function(){
    message("Not all values are integers between 0 and 4, inclusive.")
}
)
}

colSums_equal <- function(c_matrix){
  colCheck <- tryCatch(
    {assert_that(sum(colSums(c_matrix)) == sum(colSums(obs)))
      message("Sum of columns is equal to observed sum of columns.")},
    error = function(){
  message("Sum of columns DOES NOT equal the observed sum of columns.")
    }
)
}

rowSums_equal <- function(c_matrix){
  colCheck <- tryCatch(
    {assert_that(sum(rowSums(c_matrix)) == sum(rowSums(obs)))
      message("Sum of rows is equal to observed sum of rows.")},
    error = function(){
      message("Sum of rows DOES NOT equal the observed sum of rows.")
}
)
}

rows_equal_cols <- function(c_matrix){
  colCheck <- tryCatch(
    {assert_that(sum(rowSums(c_matrix)) == sum(colSums(c_matrix)))
      message("Sum of rows is equal to sum of rows.")},
    error = function(){
      message("Sum of rows DOES NOT equal the sum of columns.")
    }
  )
}

diag_zero <- function(c_matrix){
  colCheck <- tryCatch(
    {assert_that(sum(diag(c_matrix)) == 0)
      message("The diagonal consists of zeros.")},
    error = function(){
      message("The diagonal DOES NOT ist of zeros.")
    }
  )
}
greater_than_zero(rows)
sum_to_40(rows)
btwn_zero_40(c_matrix)
colSums_equal(c_matrix)
rowSums_equal(c_matrix)
rows_equal_cols(c_matrix)
diag_zero(c_matrix)
}
math_checks(rows, c_matrix)


checking8 <- function(x1, x2, x3, x4, x5, a, b, c, d, e, f, g, h, i, j, k, l){
  colCheck <- tryCatch(
    {assert_that(x5 == (abs(x1 - a - b - c) + abs(x2 - g - d - e) + abs(x3 - h - j - f) + abs(x4 - i - k - l)))
      message("The fifth column is equal to the fifth row.")},
    error = function(){
      message("The fifth column DOES NOT equal the fifth row.")
    }
  )
}
checking8(x1, x2, x3, x4, x5, a, b, c, d, e, f, g, h, i, j, k, l)
a
x5
abs(x1 - a - b - c) + abs(x2 - g - d - e) + abs(x3 - h - j - f) + abs(x4 - i - k - l)#* x5 = (x1 - a - b - c) + (x2 - a - d - e) +  (x3 - b - d - f) +  (x4 - c - e - f)
assert_that(x5 == abs(x1 - a - b - c) + abs(x2 - g - d - e) + abs(x3 - h - j - f) + abs(x4 - i - k - l))

