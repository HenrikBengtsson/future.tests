## covr: skip=all
.onLoad <- function(libname, pkgname) {
  options(future.tests.debug = isTRUE(as.logical(Sys.getenv("R_FUTURE_TESTS_DEBUG", FALSE))))
}
