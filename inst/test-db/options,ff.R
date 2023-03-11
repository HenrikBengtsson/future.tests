## https://github.com/HenrikBengtsson/future.tests/issues/20
make_test(title = "future() - can load 'ff' package", tags = c("future", "options", "reset", "ff"), {
  if (requireNamespace("ff")) {
    res <- requireNamespace("ff")
    if (!isTRUE(res)) stop("Failed to load 'ff' package")
  }
})

## https://github.com/HenrikBengtsson/future.tests/issues/20
make_test(title = "future() - 'data.table' inject", tags = c("future", "options", "reset", "ff"), {
  if (requireNamespace("data.table")) {
    dt <- data.table::data.table
    f <- future(dt, packages = "data.table")
    r <- result(f)
  }
})

## https://github.com/HenrikBengtsson/future.tests/issues/20
make_test(title = "future() - can attach 'ff' package", tags = c("future", "options", "reset", "ff"), {
  if (requireNamespace("ff")) {
    library("ff")
  }
})


## https://github.com/HenrikBengtsson/future.tests/issues/20
make_test(title = "future() - preserve R options (ff)", tags = c("future", "options", "reset", "ff"), {
  ## AD HOC: Skip if not parallelizing on localhost
  info <- Sys.info()
  is_localhost <- value(future(identical(Sys.info(), info)))
  if (is_localhost && requireNamespace("ff")) {
    data <- ff::ff(1:12)
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
