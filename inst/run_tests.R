library(future.tests)
library(future)

tests <- load_tests()
message("Number of tests: ", length(tests))
print(do.call(rbind, tests))

message("Run all tests ...")

# tests <- subset_tests(tests, tags = "futureCall")

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
      print(df_results)
    }
  }
}

message("Run all tests ... DONE")
