if (packageVersion("future") >= "1.14.0-9000") {

make_test(title = "resolved() on lazy futures", tags = c("resolved", "lazy"), {
  f <- future(42, lazy = TRUE)
  while (!resolved(f)) {
    Sys.sleep(0.1)
  }
  v <- value(f)
  stopifnot(identical(v, 42))
})

}
