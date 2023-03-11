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
