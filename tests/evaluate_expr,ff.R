evaluate_expr <- future.tests:::evaluate_expr

if (requireNamespace("ff")) {
  message("* evaluate_expr() - 'ff' package ...")
  
  data <- ff::ff(1:12)
  stopifnot(data[4] == 4L)
  names <- grep("^ff[[:alpha:]]+$", names(options()), value = TRUE)
  oopts <- options()[names]
  
  res <- evaluate_expr(quote({ requireNamespace("ff") }))
  str(res)  
  stopifnot(is.null(res$error), is.logical(res$value), isTRUE(res$value))
  stopifnot(identical(options()[names], oopts))

  res <- evaluate_expr(quote({ require("ff") }))
  str(res)  
  stopifnot(is.null(res$error), is.logical(res$value), isTRUE(res$value))
  stopifnot(identical(options()[names], oopts))

  message("* evaluate_expr() - 'ff' package ... DONE")
}
