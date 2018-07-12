tests_root <- function() {
  system.file("tests", package = "future.tests", mustWork = TRUE)
}

assert_package <- function(pkg) {
  find.package(pkg)
}

load_package <- function(pkg) {
  requireNamespace(pkg) || stop("Failed to load package: ", pkg)
  invisible(TRUE)
}

attach_package <- function(pkg) {
  require(pkg, character.only = TRUE) ||
    stop("Failed to attach package: ", pkg)
  invisible(TRUE)
}

is_covr <- function() "covr" %in% loadedNamespaces()
