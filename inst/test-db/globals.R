## https://github.com/HenrikBengtsson/future.tests/issues/14
make_test(title = "future() - non-exported package objects", tags = c("future", "globals"), {
  if (requireNamespace("utils") && require("utils")) {
    ## Find a non-exported 'utils' function
    env <- pos.to.env(match("package:utils", search()))
    ns <- getNamespace("utils")
    privates <- setdiff(names(ns), names(env))
    non_exported <- NULL
    for (name in privates) {
      if (exists(name, envir = ns, mode = "function", inherits = FALSE)) {
        non_exported <- get(name, envir = ns, mode = "function", inherits = FALSE)
      }
    }
    stopifnot(is.function(non_exported))

    ## Use this non-exported function in a future
    f <- future({ non_exported }, lazy = TRUE)

    ## Assert that it is identified as a global
    stopifnot(
      "non_exported" %in% names(f$globals),
      identical(f$globals[["non_exported"]], non_exported)
    )
    v <- value(f)
    stopifnot(identical(v, non_exported))
  }
})



## https://github.com/HenrikBengtsson/future.tests/issues/15
make_test(title = "future() - NSE '...'", tags = c("future", "globals", "..."), {
  my_fcn <- function(...) {
    ## Grab '...' into a Globals object
    globals <- globals::globalsByName("...", envir=environment())

    ## Evaluate an expression with '...' in an environment that does not
    ## have an '...' object - hence the parent.frame().  This will produce
    ## an error unless we pass 'globals' which contains '...'
    
    f <- future({
      fcn <- function() sum(...)
      fcn()
    }, envir = parent.frame(), globals = globals)
    v <- value(f)
    v
  }

  y <- my_fcn()
  stopifnot(y == 0L)  ## sum(c()) is integer, but not sure it's guaranteed

  y <- my_fcn(1:10)
  stopifnot(identical(y, 55L))
})
