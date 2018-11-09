library(future.tests)
library(future)

tests <- load_tests()

#tests <- subset_tests(tests, tags = "%<-%")

tests_tbl <- do.call(rbind, tests)
print(tests_tbl)
message("Number of tests: ", length(tests))
message("Minimal number of test combinations: ", nrow(tests_tbl))


message("Run all tests ...")

message("- Future backends:")
add_test_plan(plan(sequential))
if (supportsMulticore()) add_test_plan(plan(multicore, workers = 2L))
add_test_plan(plan(multisession, workers = 2L))

test_plans <- test_plans()
print(test_plans)

value <- TRUE
recursive <- FALSE

defaults <- list(lazy = FALSE, globals = TRUE, stdout = TRUE)

for (pp in seq_along(test_plans)) {
  test_plan <- test_plans[[pp]]
  eval(test_plan)
  
  for (lazy in c(FALSE, TRUE)) {
    for (globals in c(TRUE, FALSE)) {
      for (earlySignal in c(FALSE, TRUE)) {
        for (stdout in c(TRUE, FALSE)) {
          args <- list(lazy = lazy, globals = globals, stdout = stdout)
          args_tag <- paste(sprintf("%s=%s", names(args), unlist(args)), collapse = ", ")

          plan_str <- deparse(attr(plan(), "call"))
          cat(sprintf("\nArguments (%s) with %s:\n", args_tag, plan_str))
          
          tests_t <- subset_tests(tests, args = args, defaults = defaults)
    #      print(do.call(rbind, tests_t))
    
          results <- run_tests(tests_t, defaults = defaults)
          df_results <- do.call(rbind, results)
    #      df_results <- subset(df_results, !is.na(success))
          print(df_results)
        }
      }
    }
  }

  ## Shutdown current plan
  plan(sequential)
} ## for (pp ...)

message("\nRun all tests ... DONE")
