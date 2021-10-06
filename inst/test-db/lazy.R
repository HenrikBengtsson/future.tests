make_test(title = "resolved() on lazy futures", tags = c("resolved", "lazy"), {
  f <- future(42, lazy = TRUE)
  while (!resolved(f)) {
    Sys.sleep(0.1)
  }
  v <- value(f)
  stopifnot(identical(v, 42))
})

