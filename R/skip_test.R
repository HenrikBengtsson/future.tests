#' Skip The Current Test
#'
#' Signals a `TestSkipped` condition.
#'
#' @inheritParams base::message
#'
#' @return (invisible) A [base::condition] of class `TestSkipped`.
#'
#' @export
skip_test <- function(..., domain = NULL) {
  message <- .makeMessage(..., domain = domain)
  call <- sys.call()
  cond <- structure(list(
    message = message,
    call = call
  ), class = c("TestSkipped", "condition"))
  signalCondition(cond)
  invisible(cond)
}
