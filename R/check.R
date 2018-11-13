#' Run All Tests
#'
#' @param tests A list of tests to subset.
#'
#' @param defaults (optional) Named list with default argument values.
#'
#' @param timeout Maximum time allowed for evaluation before a timeout error is produced.
#'
#' @return Nothing.
#'
#' @importFrom crayon green red silver yellow
#' @importFrom cli get_spinner rule symbol
#' @export
check <- function(tests = test_db(), defaults = list(), timeout = getOption("future.tests.timeout", 30)) {
  if (length(defaults) > 0) stopifnot(is.list(defaults), !is.null(names(defaults)))

  spinner <- silver(get_spinner("line")$frame)
  ok <- green(symbol[["tick"]])
  error <- red(symbol[["cross"]])
#  timeout_error <- yellow(symbol[["info"]])
  timeout_error <- yellow("T")

  plan_str <- deparse(attr(plan(), "call"))

  print(rule(left = sprintf("Running %d tests with %s", length(tests), plan_str), col = "cyan"))

  total <- c(OK = 0L, ERROR = 0L, TIMEOUT = 0L)

  time <- Sys.time()
  
  for (tt in seq_along(tests)) {
    test <- tests[[tt]]

    text <- sQuote(test$title)
    cat(sprintf("%s %s", spinner[1], text))
    
    ## Test arguments
    test_args <- defaults
    for (name in names(test$args)) test_args[[name]] <- test$args[[name]]

    ## All combinations of arguments to test over
    sets_of_args <- do.call(expand.grid, test_args)

    status <- rep("OK", times = nrow(sets_of_args))
    for (aa in seq_len(nrow(sets_of_args))) {
      step <- silver(sprintf("(%d/%d)", aa, nrow(sets_of_args)))
      cat(sprintf("\r%s %s %s", spinner[aa %% length(spinner) + 1L], text, step))
      args <- as.list(sets_of_args[aa, ])
      args_tag <- paste(sprintf("%s=%s", names(args), unlist(args)), collapse = ", ")
      result <- suppressWarnings({
        run_test(test, args = args, defaults = defaults, timeout = timeout)
      })
      if (inherits(result$error, "TimeoutError")) {
        status[[aa]] <- "TIMEOUT"
      } else if (inherits(result$error, "error")) {
        status[[aa]] <- "ERROR"
      }
    }
    unit <- if (length(status) == 1) "test" else "tests"
    count <- silver(sprintf("(%d %s)", length(status), unit))
    if (all(status == "OK")) {
      cat(sprintf("\r%s %s %s\n", ok, text, count))
    } else {
      cat(sprintf("\r%s %s %s\n", error, text, count))
      for (aa in seq_len(nrow(sets_of_args))) {
        args <- as.list(sets_of_args[aa, ])
        args_tag <- paste(sprintf("%s=%s", names(args), unlist(args)), collapse = ", ")
	if (status[aa] == "OK") {
          cat(sprintf("  %s %s\n", ok, args_tag))
	  total["OK"] <- total["OK"] + 1L
	} else if (status[aa] == "ERROR") {
          cat(sprintf("  %s %s\n", error, args_tag))
	  total["ERROR"] <- total["ERROR"] + 1L
	} else if (status[aa] == "TIMEOUT") {
          cat(sprintf("  %s %s %s\n", timeout_error, args_tag, yellow(sprintf("(> %gs)", timeout))))
	  total["TIMEOUT"] <- total["TIMEOUT"] + 1L
        }        
      }
    }    
  } ## for (tt ...)

  time <- c(time, Sys.time())
  dt <- difftime(time[length(time)], time[1], units = "secs")
  if (total["TIMEOUT"] == 0) {
    cat(sprintf("\nDuration: %.0fs\n", dt))
  } else {
    cat(sprintf("\nDuration: %.0fs (including %.0fs timeouts)\n", dt - total["TIMEOUT"], timeout))
  }
  
  if (total["ERROR"] == 0L) {
    errors <- green("0 errors", ok)
  } else if (total["ERROR"] == 1L) {
    errors <- red("1 error", symbol[["cross"]])
  } else {
    errors <- red(total["ERROR"], "errors", error)
  }

  if (total["TIMEOUT"] == 0L) {
    timeouts <- green("0 timeouts", symbol[["tick"]])
  } else if (total["TIMEOUT"] == 1L) {
    timeouts <- red("1 timeout", symbol[["info"]])
  } else {
    timeouts <- red(total["TIMEOUT"], "timeouts", error)
  }

  cat(sprintf("\nResults: %s | %s\n\n", errors, timeouts))
} ## check()
