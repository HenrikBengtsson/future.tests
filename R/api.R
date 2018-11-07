#' Set Up and Tear Down of a Package Test
#' 
#' @param title A character string for the test title.
#' 
#' @param package Name of package tests.
#'
#' @param attach If TRUE, the package `pkg` is attached, otherwise
#' it only loaded.
#'
#' @param envir The environment from where tests are run.
#'
#' @return Nothing.
#'
#' @importFrom future plan sequential
#' @export
begin <- function(title, package = "future", attach = TRUE,
                  envir = parent.frame()) {
  assert_package(package)
  if (attach) attach_package(package) else load_package(package)
  push_state(title = title, envir = envir)

  ## Default options for tests
  options(
    ## Use at most two cores
    mc.cores = 2L,

    ## Warn immediately
    warn = 1L,

    ## Debug output
    future.debug = TRUE,
    
    ## Reset the following during testing in case
    ## they are set on the test system
    future.availableCores.system = NULL,
    future.availableCores.fallback = NULL,
    
    ## To be nicer to test environments (e.g. CRAN, Travis CI, AppVeyor CI, ...),
    ## timeout much earlier than the default 30 days.  This will also give a more
    ## informative error message produced by R itself, rather than whatever the
    ## test environment produces.
    future.makeNodePSOCK.timeout = 2 * 60 ## 2 minutes
  )
  
  ## Reset the following during testing in case they are set on the
  ## test system, cf. future::availableCores() and future::availableWorkers()
  Sys.unsetenv(c(
    "R_FUTURE_AVAILABLECORES_SYSTEM",
    "R_FUTURE_AVAILABLECORES_FALLBACK",
    
    ## SGE
    "NSLOTS", "PE_HOSTFILE",
    
    ## Slurm
    "SLURM_CPUS_PER_TASK",
    
    ## TORQUE / PBS
    "PBS_NUM_PPN", "PBS_NODEFILE", "PBS_NP", "PBS_NUM_NODES"
  ))

  ## Default future plan for tests
  plan(sequential)
}


#' @rdname begin
#' @export
end <- function() {
  pop_state()

  ## Explicit garbage collection because it looks like Travis CI might
  ## run out of memory during 'covr' testing. /HB 2017-01-11
  if (is_covr()) gc()
}


#' Run a Future Test
#' 
#' @param path A character string specifying a test script.
#'
#' @param \ldots Additional arguments passed to [base::source].
#'
#' @param root (internal) An alternative file directory from where
#' \pkg{future.tests} tests are sourced.
#'
#' @return Nothing
#'
#' @importFrom utils file_test
#' @export
test <- function(path, ..., root = getOption("future.tests.root", Sys.getenv("R_FUTURE_TESTS_ROOT", system.file("tests", package = "future.tests", mustWork = TRUE)))) {
  stop_if_not(file_test("-d", root))
  
  path <- file.path(root, path)
  stop_if_not(file_test("-f", path))
  
  source(path, ...)
}


#' @param msg A character string.
#' 
#' @rdname begin
#' @export
context <- function(msg) {
  message("* ", msg)
}


#' Checks Whether Tests are Run on Solaris or not
#'
#' @return TRUE if running on Solaris, otherwise FALSE
#' 
#' @export
is_solaris <- function() grepl("^solaris", R.version$os)


max_cores <- function(max) {
  stopifnot(is.numeric(max), length(max) == 1L, !is.na(max), max > 0)
  
  options(
    mc.cores = max,
    future.availableCores.fallback = max,
    future.availableCores.system = max
  )
  
  Sys.setenv(MC_CORES = max)
  Sys.setenv(R_FUTURE_AVAILABLECORES_SYSTEM = max)
  Sys.setenv(R_FUTURE_AVAILABLECORES_FALLBACK = max)
  
  if (max > 2) {
    chk <- tolower(Sys.getenv("_R_CHECK_LIMIT_CORES_", ""))
    chk <- (nzchar(chk) && (chk != "false"))
    if (chk) {
      Sys.setenv("_R_CHECK_LIMIT_CORES_" = "false")
      warning(sprintf("Overriding _R_CHECK_LIMIT_CORES_ to 'false' (to allow for max %d cores)", max))
    }
  }
}

#' @importFrom future availableCores
seq_along_cores <- function() seq_len(availableCores())

#' Evaluate Tests Emulating One, Two, ... Cores
#'
#' @param expr An \R expression.
#' 
#' @param envir The environment from where tests are run.
#'
#' @return (invisible) A named list where each element holds the
#' value of the expression evaluated with a given number of cores.
#' 
#' @importFrom future availableCores
#' @export
along_cores <- function(expr, envir = parent.frame()) { 
  expr <- substitute(expr)
  res <- list()

  ncores <- availableCores()
  original_cores <- ncores
  on.exit(set_cores(original_cores))
  
  for (cores in seq_len(ncores)) {
    set_cores(cores)
    
    mprintf("Testing with %d cores out of %d ...", cores, ncores)
    mprintf("- Updated availableCores(): %d", availableCores())
    stopifnot(availableCores() == cores)

    res[[sprintf("cores=%d", cores)]] <- test_eval(expr, envir = envir)
    
    mprintf("Testing with %d cores ... DONE", cores)
  }

  invisible(res)
}


#' Gets R Options by Name Matching
#' 
#' @param pattern A regular expression or a fixed string.
#'
#' @param fixed If TRUE, the `pattern` is matched as a fixed string,
#' otherwise as a regular expression.
#'
#' @return A named list of zero or more options.
#' 
#' @export
get_options <- function(pattern = NULL, fixed = FALSE) {
  opts <- options()
  if (is.null(pattern)) return(opts)
  opts[grepl(pattern, names(opts), fixed = fixed)]
}


#' Get and Set Future Strategies to Test Over
#'
#' @param cores (integer) The number of cores.
#'
#' @param excl A character vector of strategies to _not_ test.
#'
#' @param \ldots (optional) Arguments passed to
#' `future:::supportedStrategies()`.
#' 
#' @return A character vector of zero or more future strategies.
#' 
#' @export
strategies <- function(cores = availableCores(),
                       excl = c("multiprocess", "cluster"), ...) {
  stopifnot(is.numeric(cores), length(cores) == 1L, !is.na(cores), cores >= 1L)
  
  strategies <- future:::supportedStrategies(...)
  strategies <- setdiff(strategies, excl)
  
  ## Drop single-core strategies?
  if (cores > 1L)
    strategies <- setdiff(strategies, c("sequential", "uniprocess"))

  unique(strategies)
}


#' Evaluate Tests Across A Set of Future Strategies
#'
#' @param expr An \R expression.
#' 
#' @param envir The environment from where tests are run.
#'
#' @return (invisible) A named list where each element holds the
#' value of the expression evaluated with a given strategy.
#' 
#' @importFrom future plan
#' @export
along_strategies <- function(expr, envir = parent.frame()) {
  expr <- substitute(expr)
  res <- list()

  original_strategy <- plan()
  on.exit(plan(original_strategy))
  
  for (strategy in strategies()) {
    mprintf("Testing with future plan %s ...", sQuote(strategy))
    set_plan(strategy)

    res[[sprintf("strategy=%s", strategy)]] <- test_eval(expr, envir = envir)
    
    mprintf("Testing with future plan %s ... DONE", sQuote(strategy))
  }

  invisible(res)
}


#' @importFrom utils capture.output
#' @importFrom future plan nbrOfWorkers
test_eval <- function(expr, envir) {
  tryCatch({
    eval(expr, envir = envir)
  }, error = function(ex) {
    msg <- c(
      "plan():",
      paste(capture.output(plan()), collapse="\n"),
      sprintf("nbrOfWorkers(): %d", nbrOfWorkers()),
      "Error message:",
      conditionMessage(ex)
    )
    msg <- paste(sprintf("%s", msg), collapse = "\n")
    ruler <- paste(rep("*", times = getOption("width", 80) - 2), collapse = "")
    msg <- sprintf("%s\nTEST ERROR:\n%s\n%s", ruler, msg, ruler)
    ex$message <- msg
    stop(ex)
  })
}    


set_cores <- function(cores) {
  options(
    mc.cores = cores,
    future.availableCores.fallback = cores,
    future.availableCores.system = cores
  )
  Sys.setenv(MC_CORES = cores)
  Sys.setenv(R_FUTURE_AVAILABLECORES_SYSTEM = cores)
  Sys.setenv(R_FUTURE_AVAILABLECORES_FALLBACK = cores)
}


#' @importFrom future plan
set_plan <- function(strategy) {
  plan(strategy)
}
