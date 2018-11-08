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
#' @param register If TRUE, the test is registered in the test database, otherwise not.
#'
#' @return (invisibly) A Test.
#'
#' @export
make_test <- function(expr, title = NA_character_, args = list(), tags = NULL, substitute = TRUE, register = TRUE) {
  title <- as.character(title)
  stopifnot(length(title) == 1L, nzchar(title))
  if (length(args) > 0) stopifnot(is.list(args), !is.null(names(args)))
  if (length(tags) > 0) stopifnot(is.character(tags))
  if (substitute) expr <- substitute(expr)
  test <- structure(list(title = title, args = args, tags = tags, expr = expr), class = "Test")

  if (register) register_test(test)

  invisible(test)
}


#' @export
print.Test <- function(x, head = Inf, tail = head, ...) {
  s <- sprintf("%s:", class(x)[1])
  
  s <- c(s, sprintf("- Title: %s", sQuote(x$title)))

  s <- c(s, "- Arguments:")
  args <- x$args
  nargs <- length(args)
  nalts <- lengths(args)
  ncombs <- prod(nalts)
  if (nargs == 0) {
      s <- c(s, "    <none>")
  } else {
    for (kk in seq_along(args)) {
      name <- names(args)[kk]
      alt <- args[[kk]]
      s <- c(s, sprintf("  %3d. %s: [n = %d] %s", kk, name, length(alt), deparse(alt)))
    }
  }
  
  if (nargs <= 1L) {
    s <- c(s, sprintf("  => Test combinations: %d", ncombs))
  } else {
    s <- c(s, sprintf("  => Test combinations: %d (= %s)", ncombs, paste(nalts, collapse = "*")))
  }
  
  s <- c(s, "- Expression:")
  code <- deparse(x$expr)
  names(code) <- sprintf("%3d", seq_along(code))
  if (length(code) > head + tail + 1L) {
    code <- c(head(code, head), "..." = "...", tail(code, tail))
  }
  code <- sprintf("  %3s: %s", names(code), code)
  s <- c(s, code)
  s <- paste(c(s, ""), collapse = "\n")
  cat(s)
}
