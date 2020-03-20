evaluate_expr <- future.tests:::evaluate_expr

message("*** evaluate_expr() ...")

for (output in eval(formals(evaluate_expr)$output)) {
  res <- evaluate_expr(quote({ print(42) }), output = output)
  str(res)  
  stopifnot(is.null(res$error), !is.null(res$value), res$value == 42)

  res <- evaluate_expr(quote({ stop(42) }), output = output)
  str(res)
  stopifnot(inherits(res$error, "error"), is.null(res$value))
}

message("*** evaluate_expr() ... DONE")
