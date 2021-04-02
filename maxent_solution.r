library(tidyverse)
library(here)

# read data and drop first column 
here()
div <- read.csv("southeast_2013.csv")

div1 <- div %>%
  select(-X)

####optim
# maxent solution from http://www.di.fc.ul.pt/~jpn/r/maxent/maxent.html
pmf_maxent <- function(x, lambda = 0.22) {
  (1-exp(-lambda))*exp(-lambda*x)
}

##Still working out how to apply this???

#result <- optim(x, pmf_maxent, control = list(maxit = 10000))

dist_wins <- div1 %>%
  lapply(pmf_maxent)





