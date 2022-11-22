#' Run All or a Subset of the Tests Across Future Plans
#'
#' @inheritParams run_test
#'
#' @param plan (character vector) One or more future strategy plans to be
#' validated.
#'
#' @param tags (character vector; optional) Filter test by tags. If NULL, all
#' tests are performed.
#'
#' @param timeout (numeric; optional) Maximum time (in seconds) each test may
#' run before a timeout error is produced.
#'
#' @param settings (logical) If TRUE, details on the settings are outputted
#' before the tests start.
#'
#' @param session_info (logical) If TRUE, session information is outputted
#' after the tests complete.
#'
#' @param debug (logical) If TRUE, the raw test results are printed.
#'
#' @param exit_value (logical) If TRUE, and in a non-interactive session,
#' then use [base::quit()] to quit \R with an exit code of 0 (zero) if all
#' tests passed with all OKs and otherwise 1 (one) if one or more test failed.
#'
#' @param .args (character vector; optional) Command-line arguments.
#'
#' @return (list; invisible) A list of test results.
#'
#' @section Command-line interface (CLI):
#' This function can be called from the shell. To specify an argument, use the
#' format `--test-<arg_name>=<value>`.  For example, `--test-timeout=600` will
#' set argument `timeout=600`, and `--tags=lazy,rng`, or equivalently,
#' `--tags=lazy --tags=rng` will set argument `tags=c("lazy", "rng")`.
#'
#' Here are some examples on how to call this function from the command line:
#' \preformatted{
#' Rscript -e future.tests::check --args --test-plan=sequential
#' Rscript -e future.tests::check --args --test-plan=multicore,workers=2
#' Rscript -e future.tests::check --args --test-plan=sequential --test-plan=multicore,workers=2
#' }
#' The exit code will be 0 if all tests passed, otherwise 1. You
#' can use for instance `exit_code=$?` to retrieve the exit code of the
#' most recent call.
#'
#' @examples
#' \dontrun{
#' results <- future.tests::check(plan = "sequential", tags = c("rng"))
#' exit_code <- attr(results, "exit_code")
#' if (exit_code != 0) stop("One or more tests failed")
#' }
#'
#' @importFrom cli rule
#' @importFrom sessioninfo session_info
#' @importFrom utils packageVersion
#' @importFrom future availableCores plan
#' @export
check <- function(plan = NULL, tags = character(), timeout = NULL, settings = TRUE, session_info = FALSE, envir = parent.frame(), local = TRUE, debug = FALSE, exit_value = !interactive(), .args = commandArgs()) {
  pkg <- "future"
  suppressPackageStartupMessages(require(pkg, character.only = TRUE)) || stop("Package not found: ", sQuote(pkg))

  if (is.null(plan)) {
  } else {
    stopifnot(is.character(plan), !anyNA(plan), all(nzchar(plan)))
  }

  if (is.null(tags)) {
  } else {
    stopifnot(is.character(tags), !anyNA(tags), all(nzchar(tags)))
  }

  if (is.null(timeout)) {
  } else {
    stopifnot(is.numeric(timeout), length(timeout) == 1L, !is.na(timeout), timeout > 0)
  }

  test_plans("reset")

  action <- "check"
  
  ## Parse optional CLI arguments
  for (kk in seq_along(.args)) {
    arg <- .args[kk]
    if (grepl("--help", arg)) {
      action <- "help"
    } else if (grepl("--test-timeout=.*", arg)) {
      timeout <- as.numeric(gsub("--test-timeout=", "", arg))
      stopifnot(!is.na(timeout), timeout > 0)
    } else if (grepl("--test-plan=.*", arg)) {
      value <- gsub("--test-plan=", "", arg)
      stopifnot(nzchar(value))
      plan <- c(plan, value)
    } else if (grepl("--test-tags=.*", arg)) {
      tags_kk <- gsub("--test-tags=", "", arg)
      tags_kk <- unlist(strsplit(tags_kk, split = ",", fixed = TRUE))
      tags <- unique(c(tags, tags_kk))
    } else if ("--session-info" == arg) {
      session_info <- TRUE
    } else if ("--debug" == arg) {
      debug <- TRUE
    }
  }

  ## Add test plans?
  if (is.character(plan) && length(plan) >= 1L) {
    plan <- unique(plan)
    for (value in plan) {
      if (!grepl("^plan(.*)$", value)) value <- sprintf("plan(%s)", value)
      expr <- parse(text = value)
      add_test_plan(expr, substitute = FALSE)
    }
  }

  test_plans <- test_plans()
  if (length(test_plans) == 0L) {
    action <- "help"
  }

  if (action == "help") {
    cat("Usage: Rscript -e future.tests::check --args <options>\n")
    cat("\n")
    cat("Options:\n")
    cat(" --help                   Display this help\n")
    cat(" --test-timeout=<seconds> Sets per-test timeout in seconds\n")
    cat(" --test-tags=<tags>       Comma-separated tags specifying tests to include\n")
    cat(" --test-plan=<plan>       Future plan to test against\n")
    cat(" --session-info           Output session information at the end\n")
    cat("\n")
    cat("Example:\n")
    cat(" Rscript -e future.tests::check --args --help\n")
    cat(" Rscript -e future.tests::check --args --test-plan=sequential\n")
    cat(" Rscript -e future.tests::check --args --test-plan=multisession,workers=4\n")
    
    return(invisible())
  }

  if (settings) {
    print(rule(left = "Settings", col = "cyan"))
    cat(sprintf("- future.tests version      : %s\n", packageVersion("future.tests")))
    cat(sprintf("- R_FUTURE_TESTS_ROOT       : %s\n", Sys.getenv("R_FUTURE_TESTS_ROOT")))
    cat(sprintf("- Option 'future.tests.root': %s\n", getOption("future.tests.root", "NULL")))
    cat(sprintf("- Default test set folder   : %s\n", system.file("test-db", package = "future.tests", mustWork = TRUE)))
    cat(sprintf("- Max number of workers     : %s\n", availableCores()))
    cat(sprintf("- Timeout                   : %s\n", if (is.numeric(timeout)) sprintf("%g seconds", timeout) else "N/A"))
    cat("\n")
  }

  tests <- test_db()
  if (!is.null(tags)) tests <- subset_tests(tests, tags = tags)

  ## Set 'timeout'?
  if (is.numeric(timeout)) options(future.tests.timeout = timeout)

  test_results <- list()
  for (pp in seq_along(test_plans)) {
    test_plan <- test_plans[[pp]]
    
    eval(test_plan)
    
    test_results[[pp]] <- check_plan(tests = tests, defaults = list(lazy = FALSE, globals = TRUE, stdout = TRUE), envir = envir, local = local)
    
    ## Shutdown current plan
    plan(sequential)
  }

  ## For each test plan, check if there were any errors
  has_errors <- lapply(test_results, FUN = function(results) {
    ## For each test, check if it produced an error
    lapply(results, FUN = function(sub_results) {
      ## For each tessub t, check if it produced an error
      lapply(sub_results, FUN = function(res) inherits(res$error, "error"))
    })
  })
  nbr_of_errors <- sum(unlist(has_errors, use.names = FALSE))
  attr(test_results, "exit_code") <- if (nbr_of_errors == 0L) 0L else 1L

  if (session_info) {
    si <- session_info()
    print(si)
  }

  if (debug) {
    print(test_results)
    cat(sprintf("Total number of errors: %d\n", nbr_of_errors))
  }

  ## Quit R with an exit value?
  if (exit_value && !interactive()) {
    quit(save = "no", status = attr(test_results, "exit_code"), runLast = TRUE)
  }
  
  invisible(test_results)
}
