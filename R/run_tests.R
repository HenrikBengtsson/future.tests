#' Run All Tests
#'
#' @inheritParams run_test
#'
#' @param tests A list of tests to subset.
#'
#' @return List of test results.
#' 
#' @export
run_tests <- function(tests = test_db(), envir = parent.frame(), local = TRUE, defaults = list(), output = "stdout+stderr") {
  if (length(defaults) > 0) stopifnot(is.list(defaults), !is.null(names(defaults)))

  ## Make use of default argument values?
  if (is.null(defaults)) {
    args <- test$args
  } else {
    args <- defaults
    for (name in names(args)) args[name] <- list(defaults[name])
  }

  res <- vector("list", length = length(tests))
  for (kk in seq_along(tests)) {
    test <- tests[[kk]]
    res[[kk]] <- run_test(test, envir = envir, local = local, defaults = defaults, output = output)
  }

  res
}
