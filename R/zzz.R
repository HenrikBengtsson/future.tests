## covr: skip=all
#' @importFrom future availableCores
.onLoad <- function(libname, pkgname) {
  debug <- isTRUE(as.logical(Sys.getenv("R_FUTURE_TESTS_DEBUG", FALSE)))
  options(future.tests.debug = debug)

  value <- getOption("future.tests.undo")
  if (is.null(value)) {
    value <- Sys.getenv("R_FUTURE_TESTS_UNDO", "envvars,graphics,objects,options,rng")
    value <- unlist(strsplit(value, split = ","))
    value <- gsub(" ", "", value)
    options(future.tests.undo = value)
  }

  args <- parseCmdArgs()
  cores <- args$cores
  if (is.null(cores)) {
    ## Use at most two cores by default
    cores <- min(2L, availableCores())
  } else {
    if (debug) mdebug("R command-line argument: --cores=%s", cores)
  }
  options(mc.cores = cores)
  if (debug) mdebug("Available cores: %d", availableCores())
  
  ## Pre-load all tests
  load_tests()

  register_vignette_engine_during_build_only(pkgname)
}
