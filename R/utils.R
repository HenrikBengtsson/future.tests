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


printf <- function(...) {
  cat(sprintf(...))
}

mprintf <- function(..., appendLF = TRUE) {
  message(sprintf(...), appendLF = appendLF)
}

#' @importFrom utils capture.output
mprint <- function(..., appendLF = appendLF) {
  msg <- capture.output(print(...))
  msg <- paste(msg, collapse = "\n")
  message(msg, appendLF = appendLF)
}

#' @importFrom utils capture.output str
mstr <- function(..., appendLF = appendLF) {
  msg <- capture.output(str(...))
  msg <- paste(msg, collapse = "\n")
  message(msg, appendLF = appendLF)
}

mdebug <- function(..., appendLF = TRUE) {
  if (!getOption("future.tests.debug", FALSE)) return()
  msg <- sprintf(...)
  msg <- paste(msg, collapse = "\n")
  message(msg, appendLF = appendLF)
}


## From R.utils 2.0.2 (2015-05-23)
hpaste <- function(..., sep = "", collapse = ", ", lastCollapse = NULL, maxHead = if (missing(lastCollapse)) 3 else Inf, maxTail = if (is.finite(maxHead)) 1 else Inf, abbreviate = "...") {
  if (is.null(lastCollapse)) lastCollapse <- collapse

  # Build vector 'x'
  x <- paste(..., sep = sep)
  n <- length(x)

  # Nothing todo?
  if (n == 0) return(x)
  if (is.null(collapse)) return(x)

  # Abbreviate?
  if (n > maxHead + maxTail + 1) {
    head <- x[seq_len(maxHead)]
    tail <- rev(rev(x)[seq_len(maxTail)])
    x <- c(head, abbreviate, tail)
    n <- length(x)
  }

  if (!is.null(collapse) && n > 1) {
    if (lastCollapse == collapse) {
      x <- paste(x, collapse = collapse)
    } else {
      xT <- paste(x[1:(n-1)], collapse = collapse)
      x <- paste(xT, x[n], sep = lastCollapse)
    }
  }

  x
} # hpaste()
