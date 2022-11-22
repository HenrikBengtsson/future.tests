#' Evaluate an Expression Across A Set of Future Plans
#'
#' @param expr An \R expression.
#' 
#' @param substitute ...
#'
#' @param envir The environment where tests are run.
#'
#' @param local Should tests be evaluated in a local environment or not.
#'
#' @param plans A list of future plans.
#'
#' @return A list of results, one for each future plan tested against.
#' 
#' @importFrom future plan sequential
#' @export
along_test_plans <- function(expr, substitute = TRUE, envir = parent.frame(), local = TRUE, plans = test_plans()) {
  if (substitute) expr <- substitute(expr)
  stopifnot(is.list(plans))
  
  nplans <- length(plans)

  old_plan <- plan("list")
  on.exit(plan(old_plan))

  ## Reset any existing plan and cleanup if needed
  plan(sequential)

  res <- vector("list", length = nplans)
  names(res) <- names(plans)
  
  for (pp in seq_along(plans)) {
    name <- names(plans)[pp]
    mprintf("Evaluating expression under future plan #%d of %d ...", pp, length(plans))

    ## Set future plan
    eval(plans[[pp]])
    print(plan("next"))

    res_pp <- evaluate_expr(expr, envir = envir, local = local)
    
    res[[pp]] <- res_pp$value
    
    res_pp <- NULL
    mprintf("Evaluating expression under future plan #%d of %d ... DONE", pp, length(plans))
  }

  ## Reset any existing plan and cleanup if needed
  plan(sequential)

  res
}
