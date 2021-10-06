make_test(title = "value() - visibility", tags = c("value", "visibility"), {
  f <- future(42)
  res <- withVisible({
    value(f)
  })
  v <- res$value
  stopifnot(identical(v, 42))
  stopifnot(res$visible)

  f <- future(invisible(42))
  res <- withVisible({
    value(f)
  })
  v <- res$value
  stopifnot(identical(v, 42))
  stopifnot(!res$visible)
})
