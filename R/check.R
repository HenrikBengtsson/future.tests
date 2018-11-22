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
#' @export
check <- function(args = commandArgs()) {
  pkg <- "future"
  suppressPackageStartupMessages(require(pkg, character.only = TRUE)) || stop("Package not found: ", sQuote(pkg))
  
  test_plans("reset")

  tags <- NULL
  
  ## Parse optional CLI arguments
  for (kk in seq_along(args)) {
    arg <- args[kk]
    if (grepl("--test-timeout=.*", arg)) {
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
    }
  }

  tests <- test_db()
  if (!is.null(tags)) tests <- subset_tests(tests, tags = tags)
  
  test_plans <- test_plans()
  for (pp in seq_along(test_plans)) {
    test_plan <- test_plans[[pp]]
    
    eval(test_plan)
    check_plan(tests = tests, defaults = list(lazy = FALSE, globals = TRUE, stdout = TRUE))
    
    ## Shutdown current plan
    plan(sequential)
  }
}
