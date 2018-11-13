suppressPackageStartupMessages(library(future.tests))

library(future)

#options(future.tests.timeout = 2)
#add_test_plan(plan(future.batchtools::batchtools_local))
#add_test_plan(plan(future.callr::callr))

add_test_plan(plan(future::sequential))
if (supportsMulticore()) add_test_plan(plan(future::multicore, workers = 2L))
add_test_plan(plan(future::multisession, workers = 2L))

test_plans <- test_plans()
for (pp in seq_along(test_plans)) {
  test_plan <- test_plans[[pp]]
  
  eval(test_plan)
  check(defaults = list(lazy = FALSE, globals = TRUE, stdout = TRUE))
  
  ## Shutdown current plan
  plan(sequential)
}

