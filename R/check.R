#' Run All Tests Across Future Plans
#'
#' @param args Character vector of command-line arguments.
#'
#' @return Nothing.
#'
#' @section Command-line interface (CLI):
#' Some examples on how to call this function from the command line:
#' \preformatted{
#' Rscript -e future.tests::check --args --test-plan=sequential
#' Rscript -e future.tests::check --args --test-plan=multicore,workers=2
#' Rscript -e future.tests::check --args --test-plan=sequential --test-plan=multicore,workers=2
#' }
#'
#' @importFrom crayon cyan
#' @importFrom cli rule
#' @importFrom sessioninfo session_info
#' @importFrom utils packageVersion
#' @export
check <- function(args = commandArgs()) {
  pkg <- "future"
  suppressPackageStartupMessages(require(pkg, character.only = TRUE)) || stop("Package not found: ", sQuote(pkg))
  
  test_plans("reset")

  tags <- NULL

  action <- "check"
  sections <- c("settings")
  
  ## Parse optional CLI arguments
  for (kk in seq_along(args)) {
    arg <- args[kk]
    if (grepl("--help", arg)) {
      action <- "help"
    } else if (grepl("--test-timeout=.*", arg)) {
      timeout <- as.numeric(gsub("--test-timeout=", "", arg))
      stopifnot(!is.na(timeout), timeout > 0)
      options(future.tests.timeout = timeout)
    } else if (grepl("--test-plan=.*", arg)) {
      plan <- gsub("--test-plan=", "", arg)
      if (!grepl("^plan(.*)$", plan)) plan <- sprintf("plan(%s)", plan)
      expr <- parse(text = plan)
      add_test_plan(expr, substitute = FALSE)
    } else if (grepl("--test-tags=.*", arg)) {
      tags_kk <- gsub("--test-tags=", "", arg)
      tags_kk <- unlist(strsplit(tags_kk, split = ",", fixed = TRUE))
      tags <- unique(c(tags, tags_kk))
    } else if ("--session-info" == arg) {
      sections <- c(sections, "session_info")
    } else if ("--debug" == arg) {
      sections <- c(sections, "debug")
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
    cat(" Rscript -e future.tests::check --args --test-plan=multisession,workers=2\n")
    
    return(invisible())
  }

  if ("settings" %in% sections) {
    print(rule(left = "Settings", col = "cyan"))
    cat(sprintf("- future.tests version      : %s\n", packageVersion("future.tests")))
    cat(sprintf("- R_FUTURE_TESTS_ROOT       : %s\n", Sys.getenv("R_FUTURE_TESTS_ROOT")))
    cat(sprintf("- Option 'future.tests.root': %s\n", getOption("future.tests.root", "NULL")))
    cat(sprintf("- Default test set folder   : %s\n", system.file("test-db", package = "future.tests", mustWork = TRUE)))
    cat("\n")
  }

  tests <- test_db()
  if (!is.null(tags)) tests <- subset_tests(tests, tags = tags)

  test_results <- list()
  for (pp in seq_along(test_plans)) {
    test_plan <- test_plans[[pp]]
    
    eval(test_plan)
    test_results[[pp]] <- check_plan(tests = tests, defaults = list(lazy = FALSE, globals = TRUE, stdout = TRUE))
    
    ## Shutdown current plan
    plan(sequential)
  }

  if ("session_info" %in% sections) {
    si <- session_info()
    print(si)
  }

  if ("debug" %in% sections) {
    print(test_results)
  }
  
  invisible()
}
