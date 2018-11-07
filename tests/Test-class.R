library(future.tests)

tests <- load_tests()
message("Number of tests: ", length(tests))

message("Running all tests ...")

library(future)
lazy <- FALSE
value <- TRUE
recursive <- FALSE

res <- run_tests(tests)
print(res)

message("Running all tests ... DONE")
