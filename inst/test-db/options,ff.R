## https://github.com/HenrikBengtsson/future.tests/issues/20
make_test(title = "future() - 'data.table' inject", tags = c("future", "options", "reset", "ff"), {
  if (!requireNamespace("data.table")) {
    future.tests::skip_test("Test requires the 'data.table' package")
  }
  
  dt <- data.table::data.table
  f <- future(dt, packages = "data.table")
  r <- result(f)
})

## https://github.com/HenrikBengtsson/future.tests/issues/20
make_test(title = "future() - can load 'ff' package", tags = c("future", "options", "reset", "ff"), {
  if (!requireNamespace("ff")) {
    future.tests::skip_test("Test requires the 'ff' package")
  }

  f <- future(requireNamespace("ff"))
  v <- value(f)
  message(sprintf("Package 'ff' loaded on worker: %s", v))
  if (!isTRUE(v)) stop("Failed to load 'ff' package")
})

## https://github.com/HenrikBengtsson/future.tests/issues/20
make_test(title = "future() - can attach 'ff' package", tags = c("future", "options", "reset", "ff"), {
  if (!requireNamespace("ff")) {
    future.tests::skip_test("Test requires the 'ff' package")
  }

  f <- future(require("ff"))
  v <- value(f)
  message(sprintf("Package 'ff' attached on worker: %s", v))
  if (!isTRUE(v)) stop("Failed to attach 'ff' package")
})


## https://github.com/HenrikBengtsson/future.tests/issues/20
make_test(title = "future() - preserve R options (ff)", tags = c("future", "options", "reset", "ff"), {
  if (!requireNamespace("ff")) {
    future.tests::skip_test("Test requires the 'ff' package")
  }

  ## AD HOC: Skip if not parallelizing on localhost
  info <- Sys.info()
  is_localhost <- value(future(identical(Sys.info(), info)))
  if (!is_localhost) {
    future.tests::skip_test("Test only valid on localhost workers")
  }    

  data <- ff::ff(1:12)
  for (kk in 1:2) {
    cat(sprintf("kk = %d ...\n", kk))
    stopifnot(is.character(getOption("fftempdir")))

    ## WORKAROUND: For this to work with kk == 2, the 'ff' package
    ## must be loaded. This does not happen automatically for
    ## all backends. /HB 2023-05-01
    cat("Future #1:\n")
    f <- future({
      if (! "ff" %in% loadedNamespaces()) loadNamespace("ff")
      ns <- loadedNamespaces()
      cat(sprintf("loadedNamespaces(): [n=%d] %s\n", length(ns), paste(sQuote(ns), collapse = ", ")))
      data[4]
    })
    v <- value(f)
    message(sprintf("v = %s", v))
    stopifnot(is.character(getOption("fftempdir")))

    cat("Future #2:\n")
    f <- future(requireNamespace("ff"))
    v <- value(f)
    message(sprintf("Package 'ff' loaded on worker: %s", v))
    if (!isTRUE(v)) stop("Failing to load 'ff' package in future")
    stopifnot(is.character(getOption("fftempdir")))

    cat("Future #3:\n")
    f <- future(require("ff"))
    v <- value(f)
    message(sprintf("Package 'ff' attached on worker: %s", v))
    if (!isTRUE(v)) stop("Failing to attach 'ff' package in future")
    stopifnot(is.character(getOption("fftempdir")))

    cat("Future #4:\n")
    f <- future(data[4], packages = "ff")
    v <- value(f)
    message(sprintf("v = %s", v))
    stopifnot(
      is.integer(v),
      length(v) == 1L,
      identical(v, 4L)
    )
    cat(sprintf("kk = %d ... done\n", kk))
  }
})
