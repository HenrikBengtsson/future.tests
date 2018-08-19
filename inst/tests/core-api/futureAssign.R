future.tests::begin("Core API: futureAssign()", package = "future")

future.tests::along_cores({
  future.tests::along_strategies({
    strategy <- plan()
    cores <- nbrOfWorkers()
    for (lazy in c(FALSE, TRUE)) {
      for (globals in c(FALSE, TRUE)) {
        delayedAssign("a", {
          cat("Delayed assignment evaluated\n")
          1
        })
        
        futureAssign("b", {
          cat("Future assignment evaluated\n")
          2
        }, lazy = TRUE)
        
        ## Because "lazy future" is used, the expression/value
        ## for 'b' will be not resolved at the point.  For other
        ## types of futures, it may already have been resolved
        cat(sprintf("b = %s\n", b))
        
        ## The expression/value of 'a' is resolved at this point,
        ## because a delayed assignment (promise) was used.
        cat(sprintf("a = %s\n", a))
        
        stopifnot(identical(a, 1))
        stopifnot(identical(b, 2))
        
        ## Potential task name clashes
        u <- new.env()
        v <- new.env()
        futureAssign("a", { 2 }, assign.env = u)
        futureAssign("a", { 4 }, assign.env = v)
        
        cat(sprintf("u$a = %s\n", u$a))
        cat(sprintf("v$a = %s\n", v$a))
        
        stopifnot(identical(u$a, 2))
        stopifnot(identical(v$a, 4))
        
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
	## EXCEPTION: multiprocess futures may fall back to lazy sequential evaluation
        stopifnot(f$lazy == lazy || (inherits(strategy, "multiprocess") && cores == 1L))

        ## Set 'lazy' via disposable option
        options(future.disposable = list(lazy = lazy))
        a <- 1
        f <- futureAssign("b", { 4 / a })
        a <- 2
        stopifnot(b == 4)
	## EXCEPTION: multiprocess futures may fall back to lazy sequential evaluation
        stopifnot(f$lazy == lazy || (inherits(strategy, "multiprocess") && cores == 1L))

        ## FIXME: Automatically undo
        options(future.disposable = NULL)
      } ## for (globals ...)
    }
  })
})

future.tests::end()
