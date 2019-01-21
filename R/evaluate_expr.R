#' Evaluate an R Expression
#'
#' @param expr An expression
#'
#' @param envir The environment where tests are run.
#'
#' @param local Should tests be evaluated in a local environment or not.
#'
#' @param output Specifies whether standard output, standard error, or both should be captured or not.
#'
#' @param timeout Maximum time allowed for evaluation before a timeout error is produced.
#'
#' @return Value of test expression and benchmark information.
#'
#' @export
evaluate_expr <- function(expr, envir = parent.frame(), local = TRUE, output = c("stdout+stderr", "stdout", "none"), timeout = +Inf) {
  stopifnot(is.logical(local), length(local) == 1L, !is.na(local))
  output <- match.arg(output)
  stopifnot(is.numeric(timeout), length(timeout) == 1L, timeout > 0)

  res <- list(
    expr = expr,
    local = local,
    timeout = timeout,
    error = NULL,
    value = NULL,
    visible = NA,
    output = NULL,
    time = Sys.time()
  )
  
  ## Evaluate test in a local environment?
  if (local) envir <- new.env(parent = envir)

  if (output == "stdout") {
    output_con <- rawConnection(raw(), open = "w")
    sink(output_con, type = "output")
    on.exit({
      if (inherits(output_con, "connection")) {
        sink(type = "output")
        close(output_con)
      }
    })
  } else if (output == "stdout+stderr") {
    output_con <- rawConnection(raw(), open = "w")
    sink(output_con, type = "output")
    ## IMPORTANT: Note that capturing standard error (stderr) as done here will
    ## work throughout the full evaluation of the expression 'expr' if no code
    ## used by that expression also captures/sink the stderr.  If it does, then
    ## the capturing done here will stop working in that same moment.  See
    ## https://github.com/HenrikBengtsson/Wishlist-for-R/issues/55 for details.
    ## REAL EXAMPLE: 'clustermq' uses capture.output(type = "message")
    ## internally that breaks the sinking of stderr done here.
    ## WORKAROUND: Because of this, we use a suppressMessages() when running
    ## the tests.  It was specifically introduced due to 'future.clustermq'.
    sink(output_con, type = "message")
    on.exit({
      if (inherits(output_con, "connection")) {
        sink(type = "output")
        sink(type = "message")
        close(output_con)
      }
    })
  }

  if (timeout < Inf) {
    setTimeLimit(cpu = timeout, elapsed = timeout, transient = TRUE)
    on.exit({
      setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
    }, add = TRUE)
  }

  result <- tryCatch({
    suppressMessages({
      withVisible(eval(expr, envir = envir))
    })
  }, error = function(ex) {
    ex$traceback <- sys.calls()

    ## A timeout?
    if (timeout < Inf) {
      pattern <- sprintf("reached %s time limit", c("elapsed", "CPU"))
      pattern <- gettext(pattern, domain = "R")
      pattern <- paste(pattern, collapse = "|")
      if (grepl(pattern, conditionMessage(ex))) {
        attr(ex, "timeout") <- timeout
        class(ex) <- c("TimeoutError", class(ex))
      }	
    }	
       
    ex
  })

  if (output != "none") {
    sink(type = "output")
    if (output == "stdout+stderr") sink(type = "message")
    res$output <- rawToChar(rawConnectionValue(output_con))
    output_con <- close(output_con)
  }

  if (inherits(result, "error")) {
    res$error <- result
  } else {
    res["value"] <- list(result$value)
    res$visible <- result$visible
  }
  
  res$time <- c(res$time, Sys.time())

  res
}
