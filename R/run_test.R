#' Run a Test
#'
#' @param test A Test.
#'
#' @param envir The environment where tests are run.
#'
#' @param local Should tests be evaluated in a local environment or not.
#'
#' @param args Arguments used in this test.
#'
#' @param defaults (optional) Named list with default argument values.
#'
#' @param output If TRUE, standard output is captured, otherwise not.
#'
#' @param timeout Maximum time allowed for evaluation before a timeout error is produced.
#'
#' @return Value of test expression and benchmark information.
#'
#' @export
run_test <- function(test, envir = parent.frame(), local = TRUE, args = list(), defaults = list(), output = "stdout+stderr", timeout = getOption("future.tests.timeout", 30)) {
  stopifnot(inherits(test, "Test"))
  stopifnot(is.logical(local), length(local) == 1L, !is.na(local))
  if (length(args) > 0) stopifnot(is.list(args), !is.null(names(args)))
  if (length(defaults) > 0) stopifnot(is.list(defaults), !is.null(names(defaults)))
  stopifnot(is.numeric(timeout), length(timeout) == 1L, timeout > 0)
  
  if (local) envir <- new.env(parent = envir)
  for (name in names(defaults)) assign(name, defaults[[name]], envir = envir)
  for (name in names(args)) assign(name, args[[name]], envir = envir)

  arg_names <- unique(c(names(test$args), names(defaults)))
  ## Record arguments used
  if (length(arg_names) > 0L) {
    missing <- !sapply(arg_names, FUN = exists, envir = envir, inherits = TRUE)
    if (any(missing)) {
      names <- arg_names[missing]
      stop(sprintf("Cannot run test %s. One or more of the required arguments do not exist: %s", sQuote(test$title), paste(sQuote(names), collapse = ", ")))
    }
    args <- mget(arg_names, envir = envir, inherits = TRUE)
  } else {
    args <- NULL
  }

  ## Does the test support the test arguments?
  if (length(args) > 0 && length(test$args) > 0) {
    for (name in names(test$args)) {
      if (!args[[name]] %in% test$args[[name]]) {
        return(structure(list(test = test, args = args), class = "TestResult"))
      }	
    }
  }

  push_state(title = test$title)
  on.exit(pop_state())

  if (test$reset_workers) {
    future::resetWorkers(plan())
  }

  res <- evaluate_expr(test$expr, envir = envir, local = FALSE, output = output, timeout = timeout)

  structure(c(list(
    test     = test,
    local    = local,
    args     = args,
    defaults = defaults),
    res
  ), class = "TestResult")
}
