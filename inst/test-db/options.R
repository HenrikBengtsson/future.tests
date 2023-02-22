## https://github.com/HenrikBengtsson/future.tests/issues/20
make_test(title = "future() - preserve R options (data.table)", tags = c("future", "options", "reset", "data.table"), {
  if (requireNamespace("data.table")) {
    data.table <- data.table::data.table
    for (kk in 1:2) {
      f <- future(data.table())
      v <- value(f)
      print(v)
      stopifnot(
        inherits(v, "data.frame"),
        inherits(v, "data.table"),
        nrow(v) == 0L,
        ncol(v) == 0L
      )
    }
  }
})



## https://github.com/HenrikBengtsson/future.tests/issues/20
make_test(title = "future() - preserve R options (ff)", tags = c("future", "options", "reset", "ff"), {
  ## AD HOC: Skip if not parallelizing on localhost
  info <- Sys.info()
  is_localhost <- value(future(identical(Sys.info(), info)))
  if (is_localhost && requireNamespace("ff")) {
    library("ff")
    data <- ff::ff(1:12)
    names <- grep("^ff", names(options()), value = TRUE)
    for (kk in 1:2) {
      stopifnot(is.character(getOption("fftempdir")))
      
      f <- future(data[4])
      v <- value(f)
      print(v)
      stopifnot(is.character(getOption("fftempdir")))
      
      f <- future(requireNamespace("ff"))
      v <- value(f)
      print(v)
      if (!isTRUE(v)) stop("Failing to load 'ff' package in future")
      stopifnot(is.character(getOption("fftempdir")))
      
      f <- future(require("ff"))
      v <- value(f)
      print(v)
      if (!isTRUE(v)) stop("Failing to attach 'ff' package in future")
      stopifnot(is.character(getOption("fftempdir")))
      
      f <- future(data[4], packages = "ff")
      v <- value(f)
      print(v)
      stopifnot(
        is.integer(v),
        length(v) == 1L,
        identical(v, 4L)
      )
    }
  }
})

