#' Run All Tests
#'
#' @param tests A list of tests to subset.
#'
#' @param defaults (optional) Named list with default argument values.
#'
#' @param timeout Maximum time allowed for evaluation before a timeout error is produced.
#'
#' @param envir The environment where tests are run.
#'
#' @return Nothing.
#'
#' @importFrom crayon cyan green red silver yellow
#' @importFrom cli get_spinner rule symbol
#' @importFrom prettyunits pretty_sec pretty_dt
#' @export
check_plan <- function(tests = test_db(), defaults = list(), timeout = getOption("future.tests.timeout", 30), envir = parent.frame()) {
  if (length(defaults) > 0) stopifnot(is.list(defaults), !is.null(names(defaults)))

  spinner <- silver(get_spinner("line")$frame)
  ok <- green(symbol[["tick"]])
  error <- red(symbol[["cross"]])
  info <- symbol[["info"]]
  timeout_error <- yellow("T")
  note <- yellow("N")

  plan <- plan("next")
  plan_str <- deparse(attr(plan, "call"))

  test_results <- list()
  attr(test_results, "plan") <- plan

  print(rule(left = sprintf("Running %d test sets with %s", length(tests), plan_str), col = "cyan"))
  pkg <- environment(plan)$.packageName
  if (!is.null(pkg)) {
    pkg_version <- packageVersion(pkg)
    cat(sprintf("%s Backend package: %s %s\n", info, pkg, pkg_version))
  } else {
    cat(sprintf("%s Package: ???\n", note))
  }  

  total <- c(OK = 0L, ERROR = 0L, TIMEOUT = 0L)

  time <- Sys.time()
  
  for (tt in seq_along(tests)) {
    test <- tests[[tt]]
    test_results[[tt]] <- list()

    text <- test$title
    preset(spinner[1], " ")
    pcat(text)
    
    ## All combinations of arguments to test over
    if (length(test$args) == 0) {
     sets_of_args <- as.data.frame(defaults)
    } else {
     sets_of_args <- do.call(expand.grid, test$args)
    }
    status <- rep("OK", times = nrow(sets_of_args))
    dts <- double(length = length(status))
    for (aa in seq_len(nrow(sets_of_args))) {
      step <- silver(sprintf("(%d/%d)", aa, nrow(sets_of_args)))
      preset(spinner[aa %% length(spinner) + 1L], " ")
      pcat(sprintf("%s %s", text, step))
      args <- as.list(sets_of_args[aa, , drop = FALSE])
      result <- suppressWarnings({
        run_test(test, args = args, defaults = defaults, timeout = timeout, envir = envir)
      })
      if (inherits(result$error, "TimeoutError")) {
        status[[aa]] <- "TIMEOUT"
      } else if (inherits(result$error, "error")) {
        status[[aa]] <- "ERROR"
      }
      dts[aa] <- difftime(result$time[length(result$time)], result$time[1], units = "secs")

      test_results[[tt]][[aa]] <- result
    }

    dt <- sum(dts, na.rm = TRUE)
    total_time <- cyan(sprintf("(%s)", pretty_sec(dt)))
    
    unit <- if (length(status) == 1) "test" else "tests"
    count <- silver(sprintf("(%d %s)", length(status), unit))
    perase()
    if (all(status == "OK")) {
      cat(sprintf("%s %s %s %s\n", ok, text, count, total_time))
      total["OK"] <- total["OK"] + length(status)
    } else {
      cat(sprintf("%s %s %s %s\n", error, text, count, total_time))
      for (aa in seq_len(nrow(sets_of_args))) {
        args <- as.list(sets_of_args[aa, , drop = FALSE])
        args_tag <- paste(sprintf("%s=%s", names(args), unlist(args)), collapse = ", ")
	if (status[aa] == "OK") {
          cat(sprintf("  %s %s\n", ok, args_tag))
	  total["OK"] <- total["OK"] + 1L
	} else if (status[aa] == "ERROR") {
          cat(sprintf("  %s %s\n", error, args_tag))
	  total["ERROR"] <- total["ERROR"] + 1L
	} else if (status[aa] == "TIMEOUT") {
          cat(sprintf("  %s %s %s\n", timeout_error, args_tag, yellow(sprintf("(> %s)", pretty_sec(timeout)))))
	  total["TIMEOUT"] <- total["TIMEOUT"] + 1L
        }        
      }
    }    
  } ## for (tt ...)

  cat(sprintf("\nNumber of tests: %d\n", sum(total)))

  time <- c(time, Sys.time())
  dt <- difftime(time[length(time)], time[1], units = "secs")
  if (total["TIMEOUT"] == 0) {
    cat(sprintf("\nDuration: %s\n", pretty_dt(dt)))
  } else {
    cat(sprintf("\nDuration: %s (including %s timeouts)\n", pretty_dt(dt), total["TIMEOUT"]))
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

  invisible(test_results)
}
