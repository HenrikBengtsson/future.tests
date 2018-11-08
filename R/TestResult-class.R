#' Run a Test
#'
#' @param test A Test.
#'
#' @param envir The environment where tests are run.
#'
#' @param local Should tests be evaluated in a local environment or not.
#'
#' @return Value of test expression and benchmark information.
#'
#' @export
run_test <- function(test, envir = parent.frame(), local = TRUE) {
  stopifnot(inherits(test, "Test"))
  stopifnot(is.logical(local), length(local) == 1L, !is.na(local))
  
  ## Record arguments used
  if (length(test$args) > 0L) {
    names <- names(test$args)
    missing <- !sapply(names, FUN = exists, envir = envir, inherits = TRUE)
    if (any(missing)) {
      names <- names[missing]
      stop(sprintf("Cannot run test %s. One or more of the required arguments do not exist: %s", sQuote(test$title), paste(sQuote(names), collapse = ", ")))
    }
    args <- mget(names, envir = envir, inherits = TRUE)
  }

  res <- evaluate_expr(test$expr, envir = envir, local = local)

  structure(c(list(
    test = test,
    args = args
  ), res), class = "TestResult")
}


#' Run All Tests
#'
#' @param tests A list of tests to subset.
#'
#' @param \ldots (optional) Named arguments to test over.
#'
#' @param envir The environment where tests are run.
#'
#' @param local Should tests be evaluated in a local environment or not.
#'
#' @return List of test results.
#' 
#' @export
run_tests <- function(tests = test_db(), ..., envir = parent.frame(), local = TRUE) {
  args <- list(...)
  if (length(args) > 0) stopifnot(!is.null(names(args)))
  
  res <- vector("list", length = length(tests))
  for (kk in seq_along(tests)) {
    test <- tests[[kk]]
    res[[kk]] <- run_test(test, envir = envir, local = local)
  }

  res
}
