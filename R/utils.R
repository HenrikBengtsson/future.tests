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


stop_if_not <- function(...) {
  res <- list(...)
  for (ii in 1L:length(res)) {
    res_ii <- .subset2(res, ii)
    if (length(res_ii) != 1L || is.na(res_ii) || !res_ii) {
        mc <- match.call()
        call <- deparse(mc[[ii + 1]], width.cutoff = 60L)
        if (length(call) > 1L) call <- paste(call[1L], "....")
        stop(sprintf("%s is not TRUE", sQuote(call)),
             call. = FALSE, domain = NA)
    }
  }
  
  NULL
}


mdebug <- function(..., appendLF = TRUE) {
  if (!getOption("future.tests.debug", FALSE)) return()
  msg <- sprintf(...)
  msg <- paste(msg, collapse = "\n")
  message(msg, appendLF = appendLF)
}

#' @importFrom utils capture.output str
mstr <- function(..., appendLF = appendLF) {
  if (!getOption("future.tests.debug", FALSE)) return()
  msg <- capture.output(str(...))
  msg <- paste(msg, collapse = "\n")
  message(msg, appendLF = appendLF)
}

