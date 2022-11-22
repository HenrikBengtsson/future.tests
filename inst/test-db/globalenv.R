make_test(title = "future() - rm() a global variable", args = list(lazy = c(FALSE, TRUE)), tags = c("future", "globalenv"), {
  a <- 42
  f <- future({
    a
    a <- 3.14
    rm(a)
    a
  }, lazy = lazy)
  rm(list = "a")
  stopifnot(value(f) == 42L)
})
