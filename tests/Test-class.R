library(future.tests)
library(future)

lazy <- FALSE
global <- TRUE
stdout <- TRUE
value <- TRUE
recursive <- FALSE

tests <- load_tests()
message("Number of tests: ", length(tests))

message("Run first three tests ...")

library(future)
res <- run_tests(head(tests, 3L))
print(res)

message("Run first three tests ... DONE")


message("Run all tests across different future plans ...")

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
      for (stdout in c(FALSE, TRUE)) {
        args <- c(lazy = lazy, global = global, stdout = stdout)
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
  }
  res_plan
})
print(res)

message("Run all tests across different future plans ... DONE")
