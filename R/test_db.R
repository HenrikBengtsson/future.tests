#' Manage the Test Database
#'
#' @param action (character) What should be done.
#'
#' @param test A Test.
#'
#' @return (invisibly) the internal list of Test:s.
#'
#' @export
#' @keywords internal
test_db <- local({
  db <- list()
  
  function(action = c("list", "append", "reset"), test = NULL) {
    action <- match.arg(action)
    stopifnot(is.null(test) || inherits(test, "Test"))

    if (action == "reset") {
      db <<- list()
    } else if (action == "list") {
      return(db)
    } else if (action == "append") {
      ## Already registered?
      skip <- FALSE
      for (kk in seq_along(db)) {
        skip <- isTRUE(all.equal(test, db[[kk]]))
        if (skip) break
      }
      if (!skip) {
#        message(sprintf("Registering %s: %s", class(test)[1], sQuote(test$title)))
        db <<- c(db, list(test))
      }
    }

    invisible(db)
  }
})


#' Register a Test
#'
#' @param test A Test.
#'
#' @return (invisibly) The Test registered.
#'
#' @export
register_test <- function(test) {
  test_db("append", test = test)
  invisible(test)
}


#' Loads Future Tests
#' 
#' @param path A character string specifying a test script folder or file.
#'
#' @param recursive If TRUE, test-definition scripts are search recursively.
#'
#' @param pattern Regular expression matching filenames to include.
#'
#' @param root (internal) An alternative file directory from where
#' \pkg{future.tests} tests are sourced.
#'
#' @return (invisible) the value of `test_db()`.
#'
#' @importFrom utils file_test
#' @export
load_tests <- function(path = ".", recursive = TRUE, pattern = "[.]R$", root = getOption("future.tests.root", Sys.getenv("R_FUTURE_TESTS_ROOT", system.file("test-db", package = "future.tests", mustWork = TRUE)))) {
  stop_if_not(file_test("-d", root))
  
  path <- file.path(root, path)
  stop_if_not(file.exists(path))

  ## Load a single file or all files in a folder?
  if (file_test("-f", path)) {
    source(path, local = TRUE)
  } else if (file_test("-d", path)) {
    pathnames <- dir(path = path, recursive = recursive, pattern = pattern, full.names = TRUE)
    for (pathname in pathnames) source(pathname, local = TRUE)
  }

  invisible(test_db())
}


#' Identify Subset of Tests with Specified Tags and that Support Specified Argument Settings
#'
#' @param tests A list of tests to subset.
#'
#' @param tags (optional) A character vector of tags that tests must have.
#'
#' @param args Named arguments with sets of values to test against.
#'
#' @param defaults (optional) Named list with default argument values.
#'
#' @return A list of tests that support specified arguments.
#'
#' @export
subset_tests <- function(tests = test_db(), tags = NULL, args = NULL, defaults = list()) {
  if (!is.null(tags)) stopifnot(is.character(tags))
  names <- names(args)
  if (length(args) > 0) stopifnot(!is.null(names))
  if (length(defaults) > 0) stopifnot(is.list(defaults), !is.null(names(defaults)))

#  message("names = ", paste(sQuote(names), collapse = ", "))

  tests_subset <- tests
  keep <- logical(length = length(tests))
  for (ii in seq_along(tests)) {
    test <- tests[[ii]]

    ## Require tags?
    if (length(tags) > 0 && !all(tags %in% test$tags)) next

    test_args <- test$args
    if (length(defaults) > 0) {
      args_t <- defaults
      for (name in names(args)) args_t[name] <- args[name]
      test_args <- args_t
    }
  
    names_req <- intersect(names(test_args), names)
#    message("Test #", ii)
#    message("test_names = ", paste(sQuote(names(test_args)), collapse = ", "))
#    message("names_req = ", paste(sQuote(names_req), collapse = ", "))
    
    ## No arguments to subset against for this test?
    if (length(names_req) == 0L) {
      keep[ii] <- TRUE
      tests_subset[[ii]] <- test
      next
    }

    ## Filter by value
    keep_ii <- TRUE
    for (jj in seq_along(names_req)) {
      name <- names_req[jj]
      values <- args[[name]]
      stopifnot(length(values) > 0L)

      values_test <- test_args[[name]]
      stopifnot(length(values_test) > 0L)

      for (kk in seq_along(values)) {
        value <- values[[kk]]
	if (!value %in% values_test) {
	  keep_ii <- FALSE
	  break
	}
      }

      if (!keep_ii) break
    }
    keep[ii] <- keep_ii
    if (keep_ii) {
      tests_subset[[ii]] <- test
    }
  }

  tests_subset[keep]
}
