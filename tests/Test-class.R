library(future.tests)
library(future)

tests <- load_tests()
message("Number of tests: ", length(tests))

message("Running all tests ...")

library(future)

lazy <- FALSE
global <- TRUE
value <- TRUE
recursive <- FALSE

ntests <- length(tests)

for (lazy in c(FALSE, TRUE)) {
  message(sprintf("Running tests that supports lazy = %s ...", lazy))

  tests_tt <- subset_tests_by_args(tests, args = list(lazy = lazy))
  ntests_tt <- length(tests_tt)
  message(sprintf(" - Number of tests: %d out of %d", ntests_tt, ntests))

  res_tt <- run_tests(tests_tt)
  print(res_tt)
  
  message(sprintf("Running tests that supports lazy = %s ... OK", lazy))
}

message("Running all tests ... DONE")


message("Running all tests across different future plans ...")

library(future)

value <- TRUE
recursive <- FALSE

ntests <- length(tests)

add_test_plan(plan(sequential))
add_test_plan(plan(multisession, workers = 1L))
add_test_plan(plan(multisession, workers = 2L))

test_plans <- test_plans()
print(test_plans)

res <- along_test_plans({
  res_plan <- list()
  for (lazy in c(FALSE, TRUE)) {
    for (global in c(FALSE, TRUE)) {
      args <- c(lazy = lazy, global = global)
      args_tag <- paste(sprintf("%s=%s", names(args), args), collapse = ",")
      message(sprintf("Running tests with (%s) ...", args_tag))
  
      tests_tt <- subset_tests_by_args(tests, args = args)
      ntests_tt <- length(tests_tt)
      message(sprintf(" - Number of tests: %d out of %d", ntests_tt, ntests))
    
      res_tt <- run_tests(tests_tt)
      print(res_tt)
  
      res_plan[[args_tag]] <- res_tt

      message(sprintf("Running tests with (%s) ... DONE", args_tag))
    }
  }

  res_plan
})
print(res)

message("Running all tests across different future plans ... DONE")
