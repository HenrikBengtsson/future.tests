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


#' @export
print.Test <- function(x, head = Inf, tail = head, ...) {
  s <- sprintf("%s:", class(x)[1])
  
  s <- c(s, sprintf("- Title: %s", sQuote(x$title)))

  s <- c(s, sprintf("- Tags: %s", paste(sQuote(x$tags), collapse = ", ")))

  s <- c(s, sprintf("- Reset workers: %s", x$reset_workers))

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


#' @export
as.data.frame.Test <- function(x, ..., expand = TRUE, arg_names = NULL) {
  title <- x$title
  tags <- list(x$tags)
  
  args <- x$args
  nargs <- length(args)

  if (expand) {
    if (nargs == 0) {
      args <- NULL
    } else {
      args <- do.call(expand.grid, args)
      n <- nrow(args)
      title <- rep(title, times = n)
      tags <- rep(tags, times = n)
    }
  } else {  
    args <- data.frame(args = I(list(args)), stringsAsFactors = FALSE)
  }

  if (is.data.frame(args)) {
    data.frame(title = title, tags = I(tags), args, check.names = FALSE, stringsAsFactors = FALSE)
  } else {
    data.frame(title = title, tags = I(tags), check.names = FALSE, stringsAsFactors = FALSE)
  }
}

#' @export
rbind.Test <- function(...) {
  args <- list(...)
  df <- lapply(args, FUN = as.data.frame, ..., stringsAsFactors = FALSE)
  
  ## Intersection of all column names
  names <- unique(unlist(lapply(df, names)))

  ## Expand all data.frame:s to have the same set of columns
  df <- lapply(df, function(df) { df[setdiff(names, names(df))] <- NA; df })

  ## Reduce to one data.frame
  df <- Reduce(rbind, df)
  
  df
}
