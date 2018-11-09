make_test(title = "resolve()", args = list(lazy = c(FALSE, TRUE), value = c(FALSE, TRUE), recursive = c(FALSE, TRUE)), tags = c("resolve", "lazy"), {
  f <- future({
    Sys.sleep(0.5)
    list(a = 1, b = 42L)
  }, lazy = lazy)
  res <- resolve(f, value = value, recursive = recursive)
  stopifnot(identical(res, f))
})


make_test(title = "resolve() - run-time exception", args = list(lazy = c(FALSE, TRUE), value = c(FALSE, TRUE), recursive = c(FALSE, TRUE)), tags = c("resolve", "lazy"), {
  f <- future(list(a = 1, b = 42L, c = stop("Nah!")), lazy = lazy)
  res <- resolve(f, value = value, recursive = recursive)
  stopifnot(identical(res, f))
})


make_test(title = "resolve(<list of futures and values>)", args = list(lazy = c(FALSE, TRUE)), tags = c("resolve", "lazy"), {
  x <- list()
  x$a <- future(1, lazy = lazy)
  x$b <- future(2, lazy = lazy)
  x[[3]] <- 3
  y <- resolve(x)
  stopifnot(identical(y, x))
  stopifnot(resolved(x$a))
  stopifnot(resolved(x[["b"]]))
})


make_test(title = "resolve(<list of futures>)", args = list(lazy = c(FALSE, TRUE)), tags = c("resolve", "lazy"), {
  x <- list()
  x$a <- future(1, lazy =  lazy)
  x$b <- future(2, lazy = !lazy)
  x[[3]] <- 3
  y <- resolve(x)
  stopifnot(identical(y, x))
  stopifnot(resolved(x$a))
  stopifnot(resolved(x[["b"]]))
})


make_test(title = "resolve(<named matrix list of futures and values>) - time ordering", tags = c("resolve", "lazy"), {
  x <- list()
  x$a <- future(1)
  x$b <- future({Sys.sleep(0.5); 2})
  x[[4]] <- 4
  dim(x) <- c(2, 2)
  
  y <- resolve(x, idxs = 1)
  stopifnot(identical(y, x))
  stopifnot(resolved(x[[1]]))
  
  y <- resolve(x, idxs = 2)
  stopifnot(identical(y, x))
  stopifnot(resolved(x[[2]]))
  
  y <- resolve(x, idxs = 3)
  stopifnot(identical(y, x))
  y <- resolve(x, idxs = seq_along(x))
  
  stopifnot(identical(y, x))
  y <- resolve(x, idxs = names(x))
  stopifnot(identical(y, x))
})


make_test(title = "resolve(<list of futures>)", args = list(lazy = c(FALSE, TRUE)), tags = c("resolve", "lazy"), {
  x <- list()
  x$a <- future(1, lazy =  lazy)
  x$b <- future(2, lazy = !lazy)
  x[[3]] <- 3
  y <- resolve(x)
  stopifnot(identical(y, x))
  stopifnot(resolved(x$a))
  stopifnot(resolved(x[["b"]]))
})
