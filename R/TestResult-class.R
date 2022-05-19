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
  
  df <- lapply(args, FUN = as.data.frame, ..., stringsAsFactors = FALSE)
  
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
