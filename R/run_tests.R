#' Run All Tests
#'
#' @param tests A list of tests to subset.
#'
#' @param envir The environment where tests are run.
#'
#' @param local Should tests be evaluated in a local environment or not.
#'
#' @param defaults (optional) Named list with default argument values.
#'
#' @param output If TRUE, standard output is captured, otherwise not.
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
