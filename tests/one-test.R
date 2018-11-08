library(future.tests)
library(future)

lazy <- FALSE
global <- TRUE
stdout <- TRUE
value <- TRUE
recursive <- FALSE

tests <- load_tests()

test <- tests[[1]]
print(test)

result <- run_test(test)
print(result)
