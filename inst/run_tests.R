#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(future.tests))
library(future)

## Parse optional CLI arguments
cmd_args <- commandArgs()
for (kk in seq_along(cmd_args)) {
  arg <- cmd_args[kk]
  if (grepl("--test-timeout=.*", arg)) {
    timeout <- as.numeric(gsub("--test-timeout=", "", arg))
    stopifnot(!is.na(timeout), timeout > 0)
    options(future.tests.timeout = timeout)
  } else if (grepl("--test-plan=.*", arg)) {
    plan <- gsub("--test-plan=", "", arg)
    expr <- parse(text = plan)
    add_test_plan(expr, substitute = FALSE)
  }
}

test_plans <- test_plans()
for (pp in seq_along(test_plans)) {
  test_plan <- test_plans[[pp]]
  
  eval(test_plan)
  check(defaults = list(lazy = FALSE, globals = TRUE, stdout = TRUE))
  
  ## Shutdown current plan
  plan(sequential)
}
