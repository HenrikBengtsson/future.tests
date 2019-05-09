preset <- function(...) {
  cat("\r", ..., sep = "", file = stderr())
}

pcat <- function(..., indent = 2L, max_width = getOption("width")) {
  line <- paste0(..., sep = "", collapse = "")
  if (indent + nchar(line) > max_width) {
    line <- substring(line, first = 1L, last = max_width - 3L - indent)
    line <- paste0(line, "...")
  }
  cat(line, file = stderr())
}

perase <- function() {
  preset(rep(" ", times = getOption("width")), "\r")
}
