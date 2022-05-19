## This is not a valid test; a future does not guarantee that .GlobalEnv$.Random.seed is transferred
## make_test(title = "futureCall() with and without lazy evaluation", args = list(lazy = c(FALSE, TRUE)), tags = c("futureCall", "lazy"), {
##   f1 <- future(do.call(rnorm, args = list(n = 100)), lazy = lazy)
##   f2 <- futureCall(rnorm, args = list(n = 100), lazy = lazy)
## 
##   set.seed(42L)
##   v0 <- rnorm(n = 100)
##   str(list(v0 = v0))
##   
##   set.seed(42L)
##   v1 <- value(f1)
##   str(list(v1 = v1))
##   
##   set.seed(42L)
##   v2 <- value(f2)
##   str(list(v2 = v2))
## 
##   ## Because we use lazy futures and set the
##   ## random seed just before they are resolved
##   stopifnot(all.equal(v1, v0))
##   stopifnot(all.equal(v1, v2))
## })



make_test(title = "futureCall()", args = list(lazy = c(FALSE, TRUE), globals = c(FALSE, TRUE)), tags = c("futureCall", "lazy", "globals", "globals-automatic"),  {
  if (!isTRUE(getOption("future.tests.suppress_messages", TRUE))) {
    options(future.debug = TRUE)
  }
  
  a <- 3
  args <- list(x = 42, y = 12)
  v0 <- do.call(function(x, y) a * (x - y), args = args)
  f <- futureCall(function(x, y) a * (x - y), args = args, globals = globals, lazy = lazy)
  rm(list = c("a", "args"))
  
  print(f)
  str(f$globals)
  cat("- FUN(): --------------------\n")
  FUN <- f$globals$FUN
  print(utils::ls.str(environment(FUN)))
  cat("-----------------------------\n")
  
  res <- tryCatch({
    v <- value(f)
  }, error = identity)
  stopifnot(!inherits(res, "FutureError"))
  if (!inherits(res, "error")) {
    str(list(globals = globals, lazy = lazy, v0 = v0, v = v))
    stopifnot(all.equal(v, v0))
  } else {
    str(list(globals = globals, lazy = lazy, v0 = v0, res = res))
    stopifnot(!globals)
  }
})


make_test(title = 'futureCall() - globals = list(a = 3)', args = list(lazy = c(FALSE, TRUE)), tags = c("futureCall", "lazy", "globals", "globals-by-value"), {
  a <- 3
  args <- list(x = 42, y = 12)
  v0 <- do.call(function(x, y) a * (x - y), args = args)
  
  f <- futureCall(function(x, y) a * (x - y), args = args, globals = list(a = 3), lazy = lazy)
  rm(list = "args")
  print(f)
  
  res <- tryCatch({
    v <- value(f)
  }, error = identity)
  stopifnot(!inherits(res, "FutureError"))
  if (!inherits(res, "error")) {
    str(list(globals = globals, lazy = lazy, v0 = v0, v = v))
    stopifnot(all.equal(v, v0))
  } else {
    stopifnot(!globals)
  }
})


## KNOW ISSUES:
## Global variable 'a' is not found in:
##
##   fcn <- function() a
##   local({ a <- 3; f <- futureCall(fcn, args = list(), globals = TRUE); value(f) })
##   local({ a <- 3; f <- futureCall(fcn, args = list(), globals = "a"); value(f) })
##
## References:
## * https://github.com/HenrikBengtsson/future/issues/262
## * https://github.com/HenrikBengtsson/future/blob/master/R/futureCall.R#L18-L25
make_test(title = 'futureCall() - globals = "a"', args = list(lazy = c(FALSE, TRUE)), tags = c("futureCall", "lazy", "globals", "globals-by-name"), {
  a <- 3
  args <- list(x = 42, y = 12)
  v0 <- do.call(function(x, y) a * (x - y), args = args)

  f <- futureCall(function(x, y) {
    a * (x - y)
  }, args = args, globals = "a", lazy = lazy)
  rm(list = c("a", "args"))
  
  res <- tryCatch({
    v <- value(f)
  }, error = identity)
  stopifnot(!inherits(res, "FutureError"))
  
  if (!inherits(res, "error")) {
    stopifnot(all.equal(v, v0))
  } else {
  }
})
