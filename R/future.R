#' Assert that future and regular evaluation give identical values
#' 
#' @param expr An \R \link[base]{expression} to be evaluated.
#' 
#' @param prepend (optional) An expression prepended to the future expression.
#' 
#' @param envir The \link{environment} from where global objects should be
#' identified.  Depending on the future strategy (the \code{evaluator}), it may
#' also be the environment in which the expression is evaluated.
#'
#' @param \dots (optional) Additional arguments pass to
#' \code{\link[future:future]{future()}.}
#' 
#' @param substitute If TRUE, argument \code{expr} is
#' \code{\link[base]{substitute}()}:ed, otherwise not.
#'
#' @return A named \link{list}.
#' 
#' @importFrom future plan future resolved value nbrOfWorkers
#' @importFrom utils capture.output
#' @export
assert_future_explicit <- function(expr, prepend = NULL, envir = parent.frame(), ..., substitute = TRUE) {
  if (substitute) {
    expr <- substitute(expr)
    prepend <- substitute(prepend)
  }
  
  v_truth <- eval(expr, envir = envir)

  ## To please R CMD check
  a <- b <- NULL
  f_expr <- substitute(
    { a; b },
    list(a = prepend, b = expr)
  )
  
  p <- plan("list")

  eval({
    f <- future(f_expr, substitute = FALSE, ...)
    stopifnot(
      inherits(f, "Future")
    )
    f_print <- capture.output(print(f))
    
    r <- resolved(f)
    stopifnot(
      is.logical(r),
      length(r) == 1L,
      !is.na(r)
    )

    v <- value(f)
    stopifnot(
      !inherits(v, "condition"),
      identical(v, v_truth)
    )
  
    invisible(list(
      expr = expr,
      value_truth = v_truth,
      future_expr = f_expr,
      future = f,
      future_print = f_print,
      resolved = r,
      value = v,
      plan = p,
      nbr_of_workers = nbrOfWorkers()
    ))
  }, envir = envir)
}
