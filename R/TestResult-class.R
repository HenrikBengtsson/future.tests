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
    if (packageVersion("future") > "1.15.0") future::resetWorkers(plan())
  }

  res <- evaluate_expr(test$expr, envir = envir, local = FALSE, output = output, timeout = timeout)

  structure(c(list(
    test     = test,
    args     = args,
    defaults = defaults),
    res
  ), class = "TestResult")
}




#' @export
as.data.frame.TestResult <- function(x, ..., arg_names = NULL) {
  res <- list(title = x$test$title)
  if (is.null(arg_names)) arg_names <- names(x$args)
  for (name in arg_names) res[[name]] <- x$args[[name]]
  if (length(x$time) < 2) {
    res$time <- Sys.time() - Sys.time() + NA
    res$success <- NA
  } else {
    res$time <- difftime(x$time[length(x$time)], x$time[1], units = "secs")
    res$success <- !inherits(x$error, "error")
  }
  as.data.frame(res, check.names = FALSE, stringsAsFactors = FALSE)
}

#' @export
rbind.TestResult <- function(...) {
  args <- list(...)
  
  df <- lapply(args, FUN = as.data.frame, ...)
  
  ## Intersection of all column names
  names <- unique(unlist(lapply(df, names)))

  ## Expand all data.frame:s to have the same set of columns
  df <- lapply(df, function(df) { df[setdiff(names, names(df))] <- NA; df })

  ## Reduce to one data.frame
  df <- Reduce(rbind, df)
  
  df
}


#' @importFrom utils capture.output
#' @export
print.TestResult <- function(x, head = Inf, tail = head, ...) {
  s <- sprintf("%s:", class(x)[1])
  
  s_test <- capture.output(print(x$test))
  prefix <- rep("  ", times = length(s_test)); prefix[1] <- "- "
  s <- c(s, paste0(prefix, s_test))

  s <- c(s, "- Arguments tested:")
  args <- x$args
  nargs <- length(args)
  if (nargs == 0) {
      s <- c(s, "    <none>")
  } else {
    for (kk in seq_along(args)) {
      name <- names(args)[kk]
      value <- args[[kk]]
      s <- c(s, sprintf("  %3d. %s: %s", kk, name, deparse(value)))
    }
  }

  s <- c(s, sprintf("- Local evaluation: %s", x$local))
  
  s <- c(s, sprintf("- Result:"))
  if (inherits(x$error, "error")) {
    s <- c(s, sprintf("  - Error: %s", conditionMessage(x$error)))
  } else {
    s <- c(s, sprintf("  - Value: %s", hpaste(deparse(x$value))))
    s <- c(s, sprintf("  - Visible: %s", x$visible))
  }

  s <- c(s, sprintf("- Captured output:"))
  output <- x$output
  if (length(output) > 0) {
    if (nzchar(output)) {
      output <- unlist(strsplit(output, split = "\n", fixed = TRUE))
    }
    s <- c(s, sprintf("  %3d: %s", seq_along(output), sQuote(output)))
  } else {
    s <- c(s, "    <none>")
  }

  s <- c(s, sprintf("- Success: %s", !inherits(x$error, "error")))

  dt <- difftime(x$time[length(x$time)], x$time[1])
  s <- c(s, sprintf("- Processing time: %s", sprintf("%.3f %s", dt, attr(dt, "units"))))
  
  s <- paste(c(s, ""), collapse = "\n")
  cat(s)
}


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
