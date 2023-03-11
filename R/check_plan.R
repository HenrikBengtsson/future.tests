#' Run All Tests
#'
#' @inheritParams run_test
#'
#' @param tests A list of tests to subset.
#'
#' @param timeout Maximum time allowed for evaluation before a timeout error is produced.
#'
#' @param envir The environment where tests are run.
#'
#' @return Nothing.
#'
#' @importFrom crayon blue cyan green red silver yellow
#' @importFrom cli get_spinner rule symbol
#' @importFrom prettyunits pretty_sec pretty_dt
#' @export
check_plan <- function(tests = test_db(), defaults = list(), timeout = getOption("future.tests.timeout", 30), envir = parent.frame(), local = TRUE) {
  if (length(defaults) > 0) stopifnot(is.list(defaults), !is.null(names(defaults)))

  spinner <- silver(get_spinner("line")$frame)
  ok <- green(symbol[["tick"]])
  error <- red(symbol[["cross"]])
  skip <- blue(symbol[["star"]])
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

  total <- c(OK = 0L, ERROR = 0L, SKIP = 0L, TIMEOUT = 0L)

  time <- Sys.time()
  
  for (tt in seq_along(tests)) {
    test <- tests[[tt]]
    test_results[[tt]] <- list()

    text <- test$title
    preset(spinner[1], " ")
    pcat(text)
    
    ## All combinations of arguments to test over
    if (length(test$args) == 0) {
     sets_of_args <- as.data.frame(defaults, stringsAsFactors = FALSE)
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
        run_test(test, args = args, defaults = defaults, timeout = timeout, envir = envir, local = local)
      })
      if (inherits(result$skipped, "TestSkipped")) {
        status[[aa]] <- "SKIP"
      } else if (inherits(result$error, "TimeoutError")) {
        status[[aa]] <- "TIMEOUT"
      } else if (inherits(result$error, "error")) {
        status[[aa]] <- "ERROR"
      }
      dts[aa] <- difftime(result$time[length(result$time)], result$time[1], units = "secs")

      test_results[[tt]][[aa]] <- result
    } ## for (aa ...)

    dt <- sum(dts, na.rm = TRUE)
    total_time <- cyan(sprintf("(%s)", pretty_sec(dt)))
    
    unit <- if (length(status) == 1) "test" else "tests"
    count <- silver(sprintf("(%d %s)", length(status), unit))
    perase()
    if (all(status == "OK")) {
      cat(sprintf("%s %2d. %s %s %s\n", ok, tt, text, count, total_time))
      total["OK"] <- total["OK"] + length(status)
    } else {
      reason <- if (any(status == "ERROR")) {
        "ERROR"
      } else if (any(status == "TIMEOUT")) {
        "TIMEOUT"
      } else if (any(status == "SKIP")) {
        "SKIP"
      } else {
        "OK"
      }

      reason <- c(OK = ok, ERROR = error, TIMEOUT = timeout_error, SKIP = skip)[reason]
      cat(sprintf("%s %2d. %s %s %s\n", reason, tt, text, count, total_time))
      for (aa in seq_len(nrow(sets_of_args))) {
        args <- as.list(sets_of_args[aa, , drop = FALSE])
        args_tag <- paste(sprintf("%s=%s", names(args), unlist(args)), collapse = ", ")
        msg <- NULL
	if (status[aa] == "OK") {
          cat(sprintf("  %s %s\n", ok, args_tag))
	  total["OK"] <- total["OK"] + 1L
	} else if (status[aa] == "ERROR") {
          cat(sprintf("  %s %s\n", error, args_tag))
	  total["ERROR"] <- total["ERROR"] + 1L
	  result <- test_results[[tt]][[aa]]
	  ex <- result$error
          msg <- c(sprintf("Error of class %s with message:", sQuote(class(ex)[1])),
                   conditionMessage(ex))
          call <- conditionCall(ex)
	  if (length(call) > 0) msg <- c(msg, "Call:", deparse(call))
	  if (length(result$output) > 0) msg <- c(msg, "Output:", result$output)
	} else if (status[aa] == "SKIP") {
          cat(sprintf("  %s %s\n", skip, args_tag))
	  total["SKIP"] <- total["SKIP"] + 1L
          msg <- conditionMessage(test_results[[tt]][[aa]]$skipped)
	} else if (status[aa] == "TIMEOUT") {
          cat(sprintf("  %s %s %s\n", timeout_error, args_tag, yellow(sprintf("(> %s)", pretty_sec(timeout)))))
	  total["TIMEOUT"] <- total["TIMEOUT"] + 1L
        }

        if (is.character(msg) && length(msg) > 0L && any(nzchar(msg) > 0L)) {
          msg <- unlist(strsplit(msg, split = "\n", fixed = TRUE))
          msg <- sprintf("    %s", msg)
          msg <- paste(msg, collapse = "\n")
          cat(sprintf("%s\n", msg))
        }
      }
    }    
  } ## for (tt ...)

  cat("\n")
  cat(sprintf("Number of tests: %d\n", length(tests)))
  cat(sprintf("Number of test steps: %d\n", sum(total)))

  time <- c(time, Sys.time())
  dt <- difftime(time[length(time)], time[1], units = "secs")
  if (total["TIMEOUT"] == 0) {
    cat(sprintf("Duration: %s\n", pretty_dt(dt)))
  } else {
    cat(sprintf("Duration: %s (including %s timeouts)\n", pretty_dt(dt), total["TIMEOUT"]))
  }

  oks <- green(total["OK"], "ok", ok)

  skips <- if (total["SKIP"] == 1L) {
    blue("1 skip", skip)
  } else {
    blue(total["SKIP"], "skips", skip)
  }

  errors <- if (total["ERROR"] == 1L) {
    red("1 error", error)
  } else {
    red(total["ERROR"], "errors", error)
  }

  timeouts <- if (total["TIMEOUT"] == 1L) {
    yellow("1 timeout", timeout_error)
  } else {
    yellow(total["TIMEOUT"], "timeouts", timeout_error)
  }

  cat(sprintf("Results: %s | %s | %s | %s\n\n", oks, skips, errors, timeouts))

  invisible(test_results)
}
