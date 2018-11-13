#' Run All Tests
#'
#' @param tests A list of tests to subset.
#'
#' @param defaults (optional) Named list with default argument values.
#'
#' @return Nothing.
#'
#' @importFrom crayon green red silver
#' @importFrom cli get_spinner rule symbol
#' @export
check <- function(tests = test_db(), defaults = list()) {
  if (length(defaults) > 0) stopifnot(is.list(defaults), !is.null(names(defaults)))

  spinner <- silver(get_spinner("line")$frame)
  ok <- green(symbol[["tick"]])
  error <- red(symbol[["cross"]])

  plan_str <- deparse(attr(plan(), "call"))

  print(rule(left = sprintf("Running %d tests with %s", length(tests), plan_str), col = "cyan"))

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
      step <- silver(sprintf("(%d/%d)", aa, nrow(sets_of_args)))
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
    count <- silver(sprintf("(%d %s)", length(status), unit))
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
    errors <- green("0 errors %s", symbol[["tick"]])
  } else if (total["ERROR"] == 1L) {
    errors <- red("1 error %s", symbol[["cross"]])
  } else {
    errors <- red(sprintf("%d errors %s", total["ERROR"], symbol[["cross"]]))
  }
  cat(sprintf("\nResults: %s\n\n", errors))
} ## check()
