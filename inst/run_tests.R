library(future.tests)
library(future)

lazy <- FALSE
globals <- TRUE
stdout <- TRUE
value <- TRUE
recursive <- FALSE

tests <- load_tests()
message("Number of tests: ", length(tests))

tests <- subset_tests(tests, tags = "futureCall")

df_tests <- do.call(rbind, tests)
print(df_tests)

message("Run all tests ...")

library(future)
results <- run_tests(tests)
print(results)

df_results <- do.call(rbind, results)
print(df_results)

message("Run all tests ... DONE")
