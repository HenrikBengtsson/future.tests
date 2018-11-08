#' Evaluate an R Expression
#'
#' @param expr An expression
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
evaluate_expr <- function(expr, envir = parent.frame(), local = TRUE, stdout = TRUE) {
  stopifnot(is.logical(local), length(local) == 1L, !is.na(local))
  
  res <- list(
    expr = expr,
    local = local,
    error = NULL,
    value = NULL,
    visible = NA,
    stdout = NULL,
    time_start = Sys.time(), time_end = NULL
  )
  
  ## Evaluate test in a local environment?
  if (local) envir <- new.env(parent = envir)

  if (stdout) {
    stdout_con <- rawConnection(raw(0L), open = "w")
    sink(stdout_con, type = "output")
  }
  result <- tryCatch({
    withVisible(eval(expr, envir = envir))
  }, error = identity)

  if (stdout) {
    res$stdout <- rawToChar(rawConnectionValue(stdout_con))
    sink(type = "output")
    close(stdout_con)
  }

  if (inherits(result, "error")) {
    res$error <- result
  } else {
    res["value"] <- list(result$value)
    res$visible <- result$visible
  }
  
  res$time_end <- Sys.time()

  res
}
