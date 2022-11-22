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
