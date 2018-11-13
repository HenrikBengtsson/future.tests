suppressPackageStartupMessages({
  library(future.tests)
  library(future)
  library(cli)
})

tests <- load_tests()
#tests <- subset_tests(tests, tags = "%<-%")

add_test_plan(plan(sequential))
if (supportsMulticore()) add_test_plan(plan(multicore, workers = 2L))
add_test_plan(plan(multisession, workers = 2L))

test_plans <- test_plans()
#print(test_plans)

defaults <- list(lazy = FALSE, globals = TRUE, stdout = TRUE)

spinner <- crayon::silver(cli::get_spinner("line")$frame)
ok <- crayon::green(cli::symbol[["tick"]])
error <- crayon::red(cli::symbol[["cross"]])

for (pp in seq_along(test_plans)) {
  test_plan <- test_plans[[pp]]
  
  eval(test_plan)
  plan_str <- deparse(attr(plan(), "call"))

  print(cli::rule(left = sprintf("Running %d tests with %s", length(tests), plan_str), col = "cyan"))

  total <- c(OK = 0L, ERROR = 0L)

  for (tt in seq_along(tests)) {
    test <- tests[[tt]]

    text <- sQuote(test$title)
    cat(sprintf("%s %s", spinner[1], text))
    
    ## Test arguments
    test_args <- defaults
    for (name in names(test$args)) test_args[[name]] <- test$args[[name]]

    ## All combinations of arguments to test over
    sets_of_args <- do.call(expand.grid, test_args)

    eraser <- ""
    status <- logical(length = nrow(sets_of_args))
    for (aa in seq_len(nrow(sets_of_args))) {
      step <- crayon::silver(sprintf("(%d/%d)", aa, nrow(sets_of_args)))
      eraser <- paste(rep(" ", length = nchar(step)), collapse = "")

      cat(sprintf("\r%s %s %s", spinner[aa %% length(spinner) + 1L], text, step))
      args <- as.list(sets_of_args[aa, ])
      args_tag <- paste(sprintf("%s=%s", names(args), unlist(args)), collapse = ", ")
      result <- suppressWarnings({
        run_test(test, args = args, defaults = defaults)
      })
      status[[aa]] <- !inherits(result$error, "error")
    }
    unit <- if (length(status) == 1) "test" else "tests"
    count <- crayon::silver(sprintf("(%d %s)", length(status), unit))
    if (all(status)) {
      cat(sprintf("\r%s %s %s\n", ok, text, count))
    } else {
      cat(sprintf("\r%s %s %s\n", error, text, count))
      for (aa in seq_len(nrow(sets_of_args))) {
        args <- as.list(sets_of_args[aa, ])
        args_tag <- paste(sprintf("%s=%s", names(args), unlist(args)), collapse = ", ")
	if (status[aa]) {
          cat(sprintf("  %s %s\n", ok, args_tag))
	  total["OK"] <- total["OK"] + 1L
	} else {
          cat(sprintf("  %s %s\n", error, args_tag))
	  total["ERROR"] <- total["ERROR"] + 1L
        }        
      }
    }    
  } ## for (tt ...)

  if (total["ERROR"] == 0L) {
    errors <- crayon::green("0 errors %s", cli::symbol[["tick"]])
  } else if (total["ERROR"] == 1L) {
    errors <- crayon::red("1 error %s", cli::symbol[["cross"]])
  } else {
    errors <- crayon::red(sprintf("%d errors %s", total["ERROR"], cli::symbol[["cross"]]))
  }
  cat(sprintf("\nResults: %s\n\n", errors))

  ## Shutdown current plan
  plan(sequential)
} ## for (pp ...)
