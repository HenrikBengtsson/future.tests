library(future.tests)

tests <- load_tests()
message("Number of tests: ", length(tests))

message("Running all tests ...")

library(future)

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

add_test_plan(plan(future:::constant))
add_test_plan(plan(sequential))
add_test_plan(plan(multisession, workers = 1L))
add_test_plan(plan(multisession, workers = 2L))

test_plans <- test_plans()
print(test_plans)

res <- vector("list", length = length(test_plans))
names(res) <- names(test_plans)

for (pp in seq_along(test_plans)) {
  name <- names(test_plans)[pp]
  message(sprintf("- future plan #%d", pp))
  eval(test_plans[[pp]])
  print(plan())

  res_pp <- list()
  for (lazy in c(FALSE, TRUE)) {
    lazy_tag <- sprintf("lazy=%s", lazy)
    
    message(sprintf("Running tests that supports lazy = %s ...", lazy))
  
    tests_tt <- subset_tests_by_args(tests, args = list(lazy = lazy))
    ntests_tt <- length(tests_tt)
    message(sprintf(" - Number of tests: %d out of %d", ntests_tt, ntests))
  
    res_tt <- run_tests(tests_tt)
    print(res_tt)

    res_pp[[lazy_tag]] <- res_tt

    message(sprintf("Running tests that supports lazy = %s ... OK", lazy))
  }

  res[[pp]] <- res_pp
}

plan(sequential)

message("Running all tests across different future plans ... DONE")
