# From R.utils::CmdArgsFunction()
cli_fcn <- function(fcn) {
  stop_if_not(is.function(fcn))
  class(fcn) <- c("cli_fcn", class(fcn))
  fcn
}

#' @export
print.cli_fcn <- function(x, ..., call=!interactive(), envir=parent.frame()) {
  if (!call) return(NextMethod())
  
  # Call function...
  res <- withVisible(do.call(x, args = list(), envir=envir))

  # Should the result be printed?
  if (res$visible) {
    output <- attr(x, "output")
    if (is.null(output)) output <- print
    output(res$value)
  }

  # Return nothing
  invisible(return())
}

check <- cli_fcn(check)
