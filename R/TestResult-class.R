#' Run a Test
#'
#' @param test A Test.
#'
#' @param envir The environment where tests are run.
#'
#' @param local Should tests be evaluated in a local environment or not.
#'
#' @param stdout If TRUE, standard output is captured, otherwise not.
#'
#' @return Value of test expression and benchmark information.
#'
#' @export
run_test <- function(test, envir = parent.frame(), local = TRUE, stdout = TRUE) {
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
  } else {
    args <- NULL
  }

  res <- evaluate_expr(test$expr, envir = envir, local = local, stdout = stdout)

  structure(c(list(
    test = test,
    args = args
  ), res), class = "TestResult")
}




#' @export
as.data.frame.TestResult <- function(x, arg_names = NULL, ...) {
  res <- list(title = x$test$title)
  if (is.null(arg_names)) arg_names <- names(x$args)
  for (name in arg_names) res[[name]] <- x$args[[name]]
  res$time <- difftime(x$time_end, x$time_start, units = "secs")
  res$success <- !inherits(x$error, "error")
  as.data.frame(res)
}

#' @export
rbind.TestResult <- function(...) {
  args <- list(...)
  
  df <- lapply(args, FUN = as.data.frame)
  
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

  s <- c(s, sprintf("- Success: %s", !inherits(x$error, "error")))

  dt <- difftime(x$time_end, x$time_start)
  s <- c(s, sprintf("- Processing time: %s", sprintf("%.3f %s", dt, attr(dt, "units"))))
  
  s <- paste(c(s, ""), collapse = "\n")
  cat(s)
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
#' @param stdout If TRUE, standard output is captured, otherwise not.
#'
#' @return List of test results.
#' 
#' @export
run_tests <- function(tests = test_db(), ..., envir = parent.frame(), local = TRUE, stdout = TRUE) {
  args <- list(...)
  if (length(args) > 0) stopifnot(!is.null(names(args)))
  
  res <- vector("list", length = length(tests))
  for (kk in seq_along(tests)) {
    test <- tests[[kk]]
    res[[kk]] <- run_test(test, envir = envir, local = local, stdout = stdout)
  }

  res
}
