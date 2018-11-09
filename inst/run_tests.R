library(future.tests)
library(future)

tests <- load_tests()
tests_tbl <- do.call(rbind, tests)
print(tests_tbl)
message("Number of tests: ", length(tests))
message("Minimal number of test combinations: ", nrow(tests_tbl))

message("Run all tests ...")

library(future)

value <- TRUE
recursive <- FALSE

defaults <- list(lazy = FALSE, globals = TRUE, stdout = TRUE)

for (lazy in c(FALSE, TRUE)) {
  for (globals in c(TRUE, FALSE)) {
    for (stdout in c(TRUE, FALSE)) {
      args <- list(lazy = lazy, globals = globals, stdout = stdout)
      args_tag <- paste(sprintf("%s=%s", names(args), unlist(args)), collapse = ", ")
      cat(sprintf("Arguments (%s):\n", args_tag))
      
      tests_t <- subset_tests(tests, args = args, defaults = defaults)
#      print(do.call(rbind, tests_t))

      results <- run_tests(tests_t, defaults = defaults)
      df_results <- do.call(rbind, results)
#      df_results <- subset(df_results, !is.na(success))
      print(df_results)
    }
  }
}

message("Run all tests ... DONE")
