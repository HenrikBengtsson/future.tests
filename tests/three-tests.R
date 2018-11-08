library(future.tests)
library(future)

lazy <- FALSE
global <- TRUE
stdout <- TRUE
value <- TRUE
recursive <- FALSE

tests <- load_tests()
tests <- tests[1:3]
summary <- do.call(rbind, tests)
print(summary)

results <- run_tests(tests)

summary <- do.call(rbind, results)
print(summary)
