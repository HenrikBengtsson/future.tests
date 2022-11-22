#' Make a Test
#'
#' @param expr,substitute The expression to be tested and
#' whether it is passes as an expression already or not.
#'
#' @param title (character) The title of the test.
#'
#' @param tags (optional) Character vector of tags.
#'
#' @param args (optional) Named arguments.
#'
#' @param reset_workers (optional) Specifies whether background workers should
#  be reset or not.  Background workers are reset but resolving all active
#' futures.
#'
#' @param register If TRUE, the test is registered in the test database,
#' otherwise not.
#'
#' @return (invisibly) A Test.
#'
#' @export
make_test <- function(expr, title = NA_character_, args = list(), tags = NULL, substitute = TRUE, reset_workers = FALSE, register = TRUE) {
  title <- as.character(title)
  stopifnot(length(title) == 1L, nzchar(title))
  if (length(args) > 0) stopifnot(is.list(args), !is.null(names(args)))
  if (length(tags) > 0) stopifnot(is.character(tags))
  if (substitute) expr <- substitute(expr)
  stopifnot(is.logical(reset_workers), length(reset_workers) == 1L, !is.na(reset_workers))
  
  test <- structure(list(title = title, args = args, tags = tags, reset_workers = reset_workers, expr = expr), class = "Test")

  if (register) register_test(test)

  invisible(test)
}
