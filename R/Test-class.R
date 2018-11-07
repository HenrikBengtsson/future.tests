#' Make a Test
#'
#' @param .title (character) The title of the test.
#'
#' @param \ldots (optional) Named arguments.
#'
#' @param .expr,.substitute The expression to be tested and
#' whether it is passes as an expression already or not.
#'
#' @param .register If TRUE, the test is registered in the test database, otherwise not.
#'
#' @return (invisibly) A Test.
#'
#' @export
make_test <- function(.title = NA_character_, ..., .expr, .substitute = TRUE, .register = TRUE) {
  .title <- as.character(.title)
  stopifnot(length(.title) == 1L, nzchar(.title))
  args <- list(...)
  if (length(args) > 0) stopifnot(!is.null(names(args)))
  if (.substitute) .expr <- substitute(.expr)
  test <- structure(list(title = .title, args = args, expr = .expr), class = "Test")

  if (.register) register_test(test)

  invisible(test)
}


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




#' Run a Test
#'
#' @param test A Test.
#'
#' @param envir The environment where tests are run.
#'
#' @param local Should tests be evaluated in a local environment or not.
#'
#' @return Value of test expression and benchmark information.
#'
#' @export
run_test <- function(test, envir = parent.frame(), local = TRUE) {
  stopifnot(inherits(test, "Test"))
  stopifnot(is.logical(local), length(local) == 1L, !is.na(local))
  
  stats <- list(
    test = test,
    args = list(),
    local = local,
    error = NULL,
    value = NULL,
    visible = NA,
    time_start = Sys.time(), time_end = NULL
  )
  
  ## Record arguments used
  if (length(test$args) > 0L) {
    names <- names(test$args)
    missing <- !sapply(names, FUN = exists, envir = envir, inherits = TRUE)
    if (any(missing)) {
      names <- names[missing]
      stop(sprintf("Cannot run test %s. One or more of the required arguments do not exist: %s", sQuote(test$title), paste(sQuote(names), collapse = ", ")))
    }
    stats$args <- mget(names, envir = envir, inherits = TRUE)
  }

  ## Evaluate test in a local environment?
  if (local) envir <- new.env(parent = envir)
  
  result <- tryCatch({
    withVisible(eval(test$expr, envir = envir))
  }, error = identity)

  if (inherits(result, "error")) {
    stats$error <- result
  } else {
    stats["value"] <- list(result$value)
    stats$visible <- result$visible
  }
  
  stats$time_end <- Sys.time()

  stats
}


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
#' @return Number of tests added.
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
    print(pathnames)
    for (pathname in pathnames) source(pathname, local = TRUE)
  }

  invisible(test_db())
}


#' Run All Tests
#'
#' @param tests A list of tests to subset.
#'
#' @param \ldots (optional) Named arguments to test over.
#'
#' @param envir The environment where tests are run.
#'
#' @param local Should tests be evaluated in a local environment or not.
#'
#' @return List of test results.
#' 
#' @export
run_tests <- function(tests = test_db(), ..., envir = parent.frame(), local = TRUE) {
  args <- list(...)
  if (length(args) > 0) stopifnot(!is.null(names(args)))
  
  res <- vector("list", length = length(tests))
  for (kk in seq_along(tests)) {
    test <- tests[[kk]]
    res[[kk]] <- run_test(test, envir = envir, local = local)
  }

  res
}

#' Identify Subset of Tests that Support Specified Argument Settings
#'
#' @param tests A list of tests to subset.
#'
#' @param args Named arguments with sets of values to test against.
#'
#' @return A list of tests that support specified arguments.
#'
#' @export
subset_tests_by_args <- function(tests = test_db(), args) {
  ## Nothing to do?
  if (length(args) == 0) return(tests)
  
  names <- names(args)
  if (length(args) > 0) stopifnot(!is.null(names))
#  message("names = ", paste(sQuote(names), collapse = ", "))

  keep <- logical(length = length(tests))
  for (ii in seq_along(tests)) {
    test <- tests[[ii]]
    names_req <- intersect(names(test$args), names)
#    message("Test #", ii)
#    message("test_names = ", paste(sQuote(names(test$args)), collapse = ", "))
#    message("names_req = ", paste(sQuote(names_req), collapse = ", "))
    
    ## Test does not have any required arguments?
    if (length(names_req) == 0L) {
      keep[ii] <- TRUE
      next
    }

    ## Filter by value
    keep_ii <- TRUE
    for (jj in seq_along(names_req)) {
      name <- names_req[jj]
      values <- args[[name]]
      stopifnot(length(values) > 0L)

      values_test <- test$args[[name]]
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
  }

  tests[keep]
}
