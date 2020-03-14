evaluate_expr <- future.tests:::evaluate_expr

message("*** evaluate_expr() ...")

for (output in eval(formals(evaluate_expr)$output)) {
  res <- evaluate_expr(quote({ print(42) }), output = output)
}

message("*** evaluate_expr() ... DONE")
