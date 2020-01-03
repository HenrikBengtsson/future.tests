#' Manage the Set of Future Plans to Test Against
#'
#' @param action ...
#'
#' @param expr ...
#'
#' @param substitute ...
#'
#' @return (invisibly) returns current list of test plans.
#'
#' @export
#' @keywords internal
test_plans <- local({
  db <- list()
  
  function(action = c("list", "add", "reset"), expr = NULL, substitute = TRUE) {
    action <- match.arg(action)
    if (substitute) expr <- substitute(expr)
    
    if (action == "list") {
      return(db)
    } else if (action == "reset") {
      db <<- list()
    } else if (action == "add") {
      stopifnot(is.language(expr))
      skip <- FALSE
      for (kk in seq_along(db)) {
        if (isTRUE(all.equal(expr, db[[kk]]))) {
	  skip <- TRUE
	  break
	}
      }
      if (!skip) {
#        message("Adding plan")
#	print(expr)
        new_plan <- list(expr)
        db <<- c(db, new_plan)
      }	 
    }

    invisible(db)
  }
})


#' Add a Future Plan to Test Against
#'
#' @param expr ...
#'
#' @param substitute ...
#'
#' @return (invisibly) returns current list of test plans.
#'
#' @export
add_test_plan <- function(expr, substitute = TRUE) {
  if (substitute) expr <- substitute(expr)
  test_plans("add", expr = expr, substitute = FALSE)
}


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
