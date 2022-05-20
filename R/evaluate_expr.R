#' Evaluate an R Expression
#'
#' @param expr An expression
#'
#' @param envir The environment where tests are run.
#'
#' @param local Should tests be evaluated in a local environment or not.
#'
#' @param output Specifies whether standard output, standard error, or both should be captured or not.
#'
#' @param timeout Maximum time allowed for evaluation before a timeout error is produced.
#'
#' @return Value of test expression and benchmark information.
#'
#' @export
evaluate_expr <- function(expr, envir = parent.frame(), local = TRUE, output = c("stdout+stderr", "stdout", "none"), timeout = +Inf) {
  stopifnot(is.logical(local), length(local) == 1L, !is.na(local))
  output <- match.arg(output)
  stopifnot(is.numeric(timeout), length(timeout) == 1L, timeout > 0)
  
  res <- list(
    expr = expr,
    local = local,
    timeout = timeout,
    error = NULL,
    value = NULL,
    visible = NA,
    output = NULL,
    time = Sys.time()
  )
  
  ## Evaluate test in a local environment?
  if (local) envir <- new.env(parent = envir)

  ## Record in-going state
  old <- list(
    options = options(),
    envvars = Sys.getenv(),
    seed    = globalenv()$.Random.seed,
    rngkind = RNGkind()
  )
  
  on.exit({
    ## ----------------------------------------------------------------------
    ## 1. Undo options
    ## ----------------------------------------------------------------------
    ## (a) Removed added options
    added <- setdiff(names(options()), names(old$options))
    opts <- structure(vector("list", length = length(added)), names = added)
    options(opts)
    
    ## (b) Add back removed options
    removed <- setdiff(names(old$options), names(options()))
    opts <- old$options[removed]
    options(opts)

    ## (c) Undo modified options
    options(old$options)

    ## (d) Assert correctness
    stopifnot(identical(options(), old$options))
    
    ## ----------------------------------------------------------------------
    ## 2. Undo environment variables
    ## ----------------------------------------------------------------------
    ## (a) Removed added env vars
    added <- setdiff(names(Sys.getenv()), names(old$envvars))
    for (name in added) Sys.unsetenv(name)

    ## (b) Add back removed env vars
    missing <- setdiff(names(old$envvars), names(Sys.getenv()))
    if (length(missing) > 0) do.call(Sys.setenv, as.list(old$envvars[missing]))

    ## (c) Undo modified env vars
    envs <- Sys.getenv()
    for (name in intersect(names(envs), names(old$envvars))) {
      ## WORKAROUND: On Linux Wine, base::Sys.getenv() may
      ## return elements with empty names. /HB 2016-10-06
      if (nchar(name) == 0L) next
      if (!identical(envs[[name]], old$envvars[[name]])) {
        do.call(Sys.setenv, as.list(old$envvars[name]))
      }
    }
    
    ## (d) Assert correctness
    if (.Platform$OS.type == "windows") {
      ## Note: On MS Windows, one cannot unset environment variables,
      ## only set them to an empty value, i.e. Sys.unsetenv("FOO")
      ## is the same as Sys.setenv(FOO = "") on MS Windows. So, if
      ## a new environment variable is added during a test, it will
      ## remain afterwards with an empty value.
      ## (a) We can only assert that environment variables common
      ##     before and after are set:
      common <- intersect(names(Sys.getenv()), names(old$envvars))
      stopifnot(identical(Sys.getenv()[common], old$envvars[common]))
      ## (b) Everything else
      all <- union(names(Sys.getenv()), names(old$envvars))
      left <- setdiff(all, common)
      stopifnot(
        all(is.na(Sys.getenv()[left])),
        all(!is.na(old$envvars[left]))
      )
    } else {
      stopifnot(identical(Sys.getenv(), old$envvars))
    }

    ## ----------------------------------------------------------------------
    ## 3. Undo RNG state
    ## ----------------------------------------------------------------------
    ## (b) Undo RNG kind
    args <- as.list(old$rngkind)
    names(args) <- names(formals(RNGkind))
    do.call(RNGkind, args = args)
            
    ## (a) Undo .Random.seed
    if (is.null(old$seed)) {
      rm(list = ".Random.seed", envir = globalenv())
    } else {
      assign(".Random.seed", value = old$seed, envir = globalenv())
    }

    ## (c) Assert correctness
    stopifnot(identical(globalenv()$.Random.seed, old$seed))
    stopifnot(identical(RNGkind()[1:2], old$rngkind[1:2]))
  })
  
  if (output == "stdout") {
    output_con <- rawConnection(raw(), open = "w")
    sink(output_con, type = "output")
    on.exit({
      if (inherits(output_con, "connection")) {
        sink(type = "output")
        close(output_con)
      }
    }, add = TRUE)
  } else if (output == "stdout+stderr") {
    output_con <- rawConnection(raw(), open = "w")
    sink(output_con, type = "output")
    ## IMPORTANT: Note that capturing standard error (stderr) as done here will
    ## work throughout the full evaluation of the expression 'expr' if no code
    ## used by that expression also captures/sink the stderr.  If it does, then
    ## the capturing done here will stop working in that same moment.  See
    ## https://github.com/HenrikBengtsson/Wishlist-for-R/issues/55 for details.
    ## REAL EXAMPLE: 'clustermq' uses capture.output(type = "message")
    ## internally that breaks the sinking of stderr done here.
    ## WORKAROUND: Because of this, we use a suppressMessages() when running
    ## the tests.  It was specifically introduced due to 'future.clustermq'.
    sink(output_con, type = "message")
    on.exit({
      if (inherits(output_con, "connection")) {
        sink(type = "output")
        sink(type = "message")
        close(output_con)
      }
    }, add = TRUE)
  }

  if (timeout < Inf) {
    setTimeLimit(cpu = timeout, elapsed = timeout, transient = TRUE)
    on.exit({
      setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
    }, add = TRUE)
  }

  suppress_messages <- getOption("future.tests.suppress_messages", TRUE)
  result <- tryCatch({
    if (suppress_messages) {
      suppressMessages({
        withVisible(eval(expr, envir = envir))
      })
    } else {
      withVisible(eval(expr, envir = envir))
    }
  }, error = function(ex) {
    ex$traceback <- sys.calls()

    ## A timeout?
    if (timeout < Inf) {
      pattern <- sprintf("reached %s time limit", c("elapsed", "CPU"))
      pattern <- gettext(pattern, domain = "R")
      pattern <- paste(pattern, collapse = "|")
      if (grepl(pattern, conditionMessage(ex))) {
        attr(ex, "timeout") <- timeout
        class(ex) <- c("TimeoutError", class(ex))
      }	
    }	
       
    ex
  })

  if (output != "none") {
    sink(type = "output")
    if (output == "stdout+stderr") sink(type = "message")
    res$output <- rawToChar(rawConnectionValue(output_con))
    output_con <- close(output_con)
  }

  if (inherits(result, "error")) {
    res$error <- result
  } else {
    res["value"] <- list(result$value)
    res$visible <- result$visible
  }
  
  res$time <- c(res$time, Sys.time())

  res
}
