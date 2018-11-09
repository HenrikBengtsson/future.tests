make_test(title = "futureAssign() - lazy evaluation", args = list(lazy = c(FALSE, TRUE)), tags = c("futureAssign", "lazy"), {
  delayedAssign("a", {
    cat("Delayed assignment evaluated\n")
    1
  })
  
  futureAssign("b", {
    cat("Future assignment evaluated\n")
    2
  }, lazy = lazy)
  
  ## Because "lazy future" is used, theexpression/value
  ## for 'b' will be not resolved at the point.  For other
  ## types of futures, it may already have been resolved
  cat(sprintf("b = %s\n", b))
  
  ## Theexpression/value of 'a' is resolved at this point,
  ## because a delayed assignment (promise) was used.
  cat(sprintf("a = %s\n", a))
  
  stopifnot(identical(a, 1))
  stopifnot(identical(b, 2))
})


make_test(title = "futureAssign() - potential task name clashes", tags = c("futureAssign"), {
  ## Potential task name clashes
  u <- new.env()
  v <- new.env()
  futureAssign("a", { 2 }, assign.env = u)
  futureAssign("a", { 4 }, assign.env = v)
  
  cat(sprintf("u$a = %s\n", u$a))
  cat(sprintf("v$a = %s\n", v$a))
  
  stopifnot(identical(u$a, 2))
  stopifnot(identical(v$a, 4))
})



make_test(title = "futureAssign() - global variables with and without lazy evaluation", args = list(lazy = c(FALSE, TRUE)), tags = c("futureAssign", "lazy"), {
  ## Global variables
  a <- 1
  futureAssign("b", { 2 * a })
  a <- 2
  stopifnot(b == 2)

  ## Explicit lazy evaluation
  a <- 1
  f <- futureAssign("b", { 2 + a }, lazy = lazy)
  a <- 2
  stopifnot(b == 3)
  print(f)
})


make_test(title = "futureAssign() - lazy evaluation via disposable option", args = list(lazy = c(FALSE, TRUE)), tags = c("futureAssign", "lazy"), {
  ## Set 'lazy' via disposable option
  options(future.disposable = list(lazy = lazy))
  ## FIXME: Automatically undo
  on.exit(options(future.disposable = NULL))
  
  a <- 1
  f <- futureAssign("b", { 4 / a })
  a <- 2
  
  stopifnot(b == 4)
})
